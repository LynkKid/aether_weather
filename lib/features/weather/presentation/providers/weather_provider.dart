import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether_weather/core/atmospheric_theme.dart';
import 'package:aether_weather/core/calculators/climate_calculator.dart';
import 'package:aether_weather/core/calculators/moon_calculator.dart';
import 'package:aether_weather/core/calculators/solar_calculator.dart';
import 'package:aether_weather/core/constants/app_constants.dart';
import 'package:aether_weather/core/logging/app_logger.dart';
import 'package:aether_weather/core/night_mode_utils.dart';
import 'package:aether_weather/core/services/location_service.dart';
import 'package:aether_weather/core/services/notification_service.dart';
import 'package:aether_weather/core/theme/app_theme.dart';
import 'package:aether_weather/features/weather/data/repositories/weather_repository.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class WeatherProvider with ChangeNotifier {
  final IWeatherRepository _repository;
  final LocationService _locationService;
  final NotificationService _notificationService;

  WeatherProvider({
    IWeatherRepository? repository,
    LocationService? locationService,
    NotificationService? notificationService,
  })  : _repository = repository ?? WeatherRepository(),
        _locationService = locationService ?? LocationService.instance,
        _notificationService = notificationService ?? NotificationService.instance;

  WeatherData? _weather;
  CityLocation? _currentCity;
  List<CityLocation> _savedCities = [];
  List<CityLocation> _searchResults = [];
  final List<SevereAlert> _alertHistory = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  UserSettings _settings = const UserSettings();

  // Getters
  WeatherData? get weather => _weather;
  CityLocation? get currentCity => _currentCity;
  List<CityLocation> get savedCities => _savedCities;
  List<CityLocation> get searchResults => _searchResults;
  List<SevereAlert> get alertHistory => _alertHistory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  UserSettings get settings => _settings;

  bool get isFahrenheit => _settings.tempUnit == 'F';
  bool get isMph => _settings.windUnit == 'mph';
  bool get notificationsEnabled => _settings.notificationsEnabled;

  bool get isNightModeActive {
    return _settings.nightModeAutomation &&
        NightModeUtils.isCurrentlyInSleepHours(
          _settings.sleepStartTime,
          _settings.sleepEndTime,
        );
  }

  String get effectiveThemeMode =>
      isNightModeActive ? _settings.nightTheme : _settings.themeMode;

  AppThemeMode get themeMode => switch (effectiveThemeMode) {
        'oled' => AppThemeMode.oled,
        'light' => AppThemeMode.light,
        'dark' => AppThemeMode.dark,
        _ => AppThemeMode.system,
      };

  ThemeMode get materialThemeMode => switch (effectiveThemeMode) {
        'light' => ThemeMode.light,
        'dark' || 'oled' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  ThemeData get activeThemeData => switch (effectiveThemeMode) {
        'light' => AppTheme.lightTheme,
        'oled' => AppTheme.oledTheme,
        _ => AppTheme.darkTheme,
      };

  AtmosphericTheme get atmosphericTheme {
    return AtmosphericTheme.getTheme(
      weatherCode: _weather?.weatherCode ?? 1,
      isDay: _weather?.isDay ?? true,
      themeMode: effectiveThemeMode,
    );
  }

  SolarEfficiencyMetrics get solarEfficiency {
    if (_weather == null) {
      return const SolarEfficiencyMetrics(
        efficiencyPct: 0,
        sunAngleDeg: 0,
        isSunUp: false,
        irradianceWm2: 0,
        estimatedKw5kWArray: 0,
        cloudLossPct: 0,
        efficiencyTier: 'Zero (Night)',
        tierColor: Color(0xFF64748B),
        advice: 'No weather telemetry loaded.',
      );
    }
    return SolarCalculator.calculateSolarEfficiency(
      weather: _weather!,
      todayForecast: _weather!.daily.isNotEmpty ? _weather!.daily.first : null,
      latitude: _currentCity?.latitude ?? 35.68,
    );
  }

  SolarCycleProgress get solarCycle {
    if (_weather == null) {
      return const SolarCycleProgress(
        progress: 0.5,
        isDaytime: true,
        sunrise: '06:00',
        sunset: '18:00',
        remainingDaylight: '12h daylight',
        goldenHourStart: '17:00',
        goldenHourEnd: '18:00',
      );
    }
    return SolarCalculator.calculateSolarCycle(_weather!);
  }

  MoonPhaseInfo get moonPhase => MoonCalculator.calculateMoonPhase();

  List<CalendarMoonDay> get lunarCalendar =>
      MoonCalculator.get30DayLunarCalendar();

  ClimateSummary get climateSummary {
    return ClimateCalculator.getClimateComparison(
      _currentCity ??
          const CityLocation(
            name: 'Local Station',
            country: 'Observatory',
            latitude: 35.68,
            longitude: 139.69,
          ),
      _weather?.temperature,
    );
  }

  // Formatting helpers
  String formatTemperature(double celsius) {
    if (isFahrenheit) {
      final f = (celsius * 9 / 5) + 32;
      return '${f.round()}°';
    }
    return '${celsius.round()}°';
  }

  String formatTemperatureValue(double celsius) {
    if (isFahrenheit) {
      final f = (celsius * 9 / 5) + 32;
      return '${f.round()}°F';
    }
    return '${celsius.round()}°C';
  }

  String formatWindSpeed(double kmh) {
    if (_settings.windUnit == 'mph') {
      final mph = kmh * 0.621371;
      return '${mph.round()} mph';
    }
    if (_settings.windUnit == 'ms') {
      final ms = kmh / 3.6;
      return '${ms.round()} m/s';
    }
    return '${kmh.round()} km/h';
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repository.getUserSettings();
      _savedCities = await _repository.getSavedCities();

      final prefs = await SharedPreferences.getInstance();
      final lastCityJson = prefs.getString(AppConstants.keyLastSelectedCity);
      if (lastCityJson != null) {
        try {
          final decoded = CityLocation.fromJson(
            json.decode(lastCityJson) as Map<String, dynamic>,
          );
          await fetchWeatherForCity(decoded, isSilent: true);
          return;
        } catch (_) {}
      }

      await useDeviceLocation(isSilent: true);
    } catch (e, stack) {
      AppLogger.instance.error('Initialization error in WeatherProvider', e, stack);
      _errorMessage = 'Failed to load initial meteorological telemetry';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> useDeviceLocation({bool isSilent = false}) async {
    if (!isSilent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final loc = await _locationService.getCurrentCoordinates();
      final city = CityLocation(
        name: loc.isFallback ? AppConstants.defaultCityName : 'Current Location',
        country: loc.isFallback ? AppConstants.defaultCountry : 'GPS Satellite',
        latitude: loc.latitude,
        longitude: loc.longitude,
        isCurrentLocation: !loc.isFallback,
      );

      await fetchWeatherForCity(city, isSilent: true);
    } catch (e, stack) {
      AppLogger.instance.error('GPS positioning failed', e, stack);
      _errorMessage = 'Could not determine position';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeatherForCity(CityLocation city, {bool isSilent = false}) async {
    if (!isSilent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _currentCity = city;
      final result = await _repository.fetchWeather(city: city);
      _weather = result;
      _errorMessage = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyLastSelectedCity,
        json.encode(city.toJson()),
      );

      // Check severe notifications with night mode rules
      if (_settings.notificationsEnabled && result.severeAlerts.isNotEmpty) {
        for (final alert in result.severeAlerts) {
          _alertHistory.insert(0, alert);
        }
        final topAlert = result.severeAlerts.first;
        final shouldSound = NightModeUtils.shouldPlayAlertAudio(
          severity: topAlert.severity.name,
          soundAlertsEnabled: _settings.soundAlertsEnabled,
          nightModeAutomation: _settings.nightModeAutomation,
          silenceNonCriticalSounds: _settings.silenceNonCriticalSounds,
          sleepStartTime: _settings.sleepStartTime,
          sleepEndTime: _settings.sleepEndTime,
        );

        if (!_settings.extremeAlertsOnly || topAlert.isExtreme) {
          await _notificationService.showSevereWeatherAlert(
            title: topAlert.title,
            body: topAlert.description,
            area: city.name,
            isExtreme: topAlert.isExtreme && shouldSound,
          );
        }
      }
    } catch (e, stack) {
      AppLogger.instance.error('Error fetching weather in provider', e, stack);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    if (_currentCity != null) {
      await fetchWeatherForCity(_currentCity!, isSilent: false);
    } else {
      await useDeviceLocation();
    }
  }

  Future<void> searchCities(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await _repository.searchCities(query);
      _searchResults = results;
    } catch (e, stack) {
      AppLogger.instance.error('Search failed in provider', e, stack);
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(CityLocation city) async {
    final isFav = _savedCities.any(
      (c) => c.name.toLowerCase() == city.name.toLowerCase() &&
             (c.latitude - city.latitude).abs() < 0.1,
    );

    if (isFav) {
      await _repository.removeCity(city);
    } else {
      await _repository.saveCity(city.copyWith(isFavorite: true));
    }
    _savedCities = await _repository.getSavedCities();
    notifyListeners();
  }

  Future<void> removeSavedCity(CityLocation city) async {
    await _repository.removeCity(city);
    _savedCities = await _repository.getSavedCities();
    notifyListeners();
  }

  Future<void> updateUserSettings(UserSettings newSettings) async {
    _settings = newSettings;
    await _repository.saveUserSettings(newSettings);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final modeStr = switch (mode) {
      AppThemeMode.light => 'light',
      AppThemeMode.oled => 'oled',
      AppThemeMode.dark => 'dark',
      AppThemeMode.system => 'system',
    };
    await updateUserSettings(_settings.copyWith(themeMode: modeStr));
  }

  Future<void> setTemperatureUnit(bool fahrenheit) async {
    await updateUserSettings(_settings.copyWith(tempUnit: fahrenheit ? 'F' : 'C'));
  }

  Future<void> setWindUnit(String unit) async {
    await updateUserSettings(_settings.copyWith(windUnit: unit));
  }

  Future<void> toggleNotifications(bool enabled) async {
    await updateUserSettings(_settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> triggerSimulatedAlert([SevereAlert? customAlert]) async {
    final cityName = _currentCity?.name ?? 'Local Station';
    final alert = customAlert ??
        SevereAlert(
          id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Tornado Vortex Warning [TEST]',
          area: cityName,
          severity: AlertSeverity.emergency,
          description: 'Doppler radar indicates intense rotational storm structure with severe hail.',
          instruction: 'Take shelter immediately in an interior basement room away from windows.',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          isExtreme: true,
        );

    _alertHistory.insert(0, alert);

    if (_weather != null) {
      final updatedAlerts = [alert, ..._weather!.severeAlerts.where((a) => a.id != alert.id)];
      _weather = WeatherData(
        city: _weather!.city,
        temperature: _weather!.temperature,
        feelsLike: _weather!.feelsLike,
        weatherCode: _weather!.weatherCode,
        humidity: _weather!.humidity,
        windSpeed: _weather!.windSpeed,
        windDirection: _weather!.windDirection,
        windGusts: _weather!.windGusts,
        pressure: _weather!.pressure,
        uvIndex: _weather!.uvIndex,
        visibility: _weather!.visibility,
        dewPoint: _weather!.dewPoint,
        cloudCover: _weather!.cloudCover,
        isDay: _weather!.isDay,
        hourly: _weather!.hourly,
        daily: _weather!.daily,
        severeAlerts: updatedAlerts,
        airQuality: _weather!.airQuality,
        allergy: _weather!.allergy,
        pressureHistory: _weather!.pressureHistory,
        fetchedAt: DateTime.now(),
      );
    }
    notifyListeners();

    final canSound = NightModeUtils.shouldPlayAlertAudio(
      severity: alert.severity.name,
      soundAlertsEnabled: _settings.soundAlertsEnabled,
      nightModeAutomation: _settings.nightModeAutomation,
      silenceNonCriticalSounds: _settings.silenceNonCriticalSounds,
      sleepStartTime: _settings.sleepStartTime,
      sleepEndTime: _settings.sleepEndTime,
    );

    await _notificationService.showSevereWeatherAlert(
      title: alert.title,
      body: alert.description,
      area: cityName,
      isExtreme: alert.isExtreme && canSound,
    );
  }

  Future<void> triggerTestAlert() => triggerSimulatedAlert();

  void clearAlertHistory() {
    _alertHistory.clear();
    notifyListeners();
  }
}

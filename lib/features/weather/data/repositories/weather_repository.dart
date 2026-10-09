import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether_weather/core/constants/app_constants.dart';
import 'package:aether_weather/core/errors/app_failure.dart';
import 'package:aether_weather/core/logging/app_logger.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

abstract class IWeatherRepository {
  Future<WeatherData> fetchWeather({required CityLocation city});
  Future<List<CityLocation>> searchCities(String query);
  Future<WeatherData?> getCachedWeather({required String cityName});
  Future<List<CityLocation>> getSavedCities();
  Future<void> saveCity(CityLocation city);
  Future<void> removeCity(CityLocation city);
  Future<UserSettings> getUserSettings();
  Future<void> saveUserSettings(UserSettings settings);
}

class WeatherRepository implements IWeatherRepository {
  final http.Client _httpClient;

  WeatherRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const List<CityLocation> defaultCities = [
    CityLocation(name: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503, isFavorite: true),
    CityLocation(name: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060, isFavorite: true),
    CityLocation(name: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278, isFavorite: true),
    CityLocation(name: 'Miami', country: 'United States', latitude: 25.7617, longitude: -80.1918, isFavorite: true),
    CityLocation(name: 'Reykjavík', country: 'Iceland', latitude: 64.1466, longitude: -21.9426),
    CityLocation(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
    CityLocation(name: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198),
    CityLocation(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093),
  ];

  static const String _keyUserSettings = 'aether_user_settings';

  @override
  Future<WeatherData> fetchWeather({required CityLocation city}) async {
    final weatherUri = Uri.parse(
      '${AppConstants.weatherApiBaseUrl}/forecast'
      '?latitude=${city.latitude}'
      '&longitude=${city.longitude}'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m,dew_point_2m,uv_index,visibility'
      '&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,precipitation_probability,weather_code,visibility,is_day,uv_index,wind_speed_10m,wind_direction_10m,wind_gusts_10m,surface_pressure'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_sum,precipitation_probability_max'
      '&forecast_days=8'
      '&timezone=auto',
    );

    final aqiUri = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality'
      '?latitude=${city.latitude}'
      '&longitude=${city.longitude}'
      '&current=us_aqi,pm2_5,pm10,nitrogen_dioxide,ozone,alder_pollen,birch_pollen,grass_pollen,mugwort_pollen,ragweed_pollen'
      '&timezone=auto',
    );

    try {
      AppLogger.instance.info('Fetching weather & telemetry for ${city.name} (${city.latitude}, ${city.longitude})');

      final responses = await Future.wait([
        _httpClient.get(weatherUri).timeout(const Duration(seconds: 15)),
        _httpClient.get(aqiUri).timeout(const Duration(seconds: 10)).catchError((_) => http.Response('{}', 500)),
      ]);

      final weatherRes = responses[0];
      final aqiRes = responses[1];

      if (weatherRes.statusCode != 200) {
        throw ServerFailure(
          'Open-Meteo returned status ${weatherRes.statusCode}',
          statusCode: weatherRes.statusCode,
        );
      }

      final dynamic decoded = json.decode(weatherRes.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ServerFailure('Invalid JSON response format from weather server');
      }

      Map<String, dynamic>? aqiDecoded;
      if (aqiRes.statusCode == 200) {
        try {
          final dyn = json.decode(aqiRes.body);
          if (dyn is Map<String, dynamic>) aqiDecoded = dyn;
        } catch (_) {}
      }

      final current = decoded['current'] as Map<String, dynamic>? ?? {};
      final hourly = decoded['hourly'] as Map<String, dynamic>? ?? {};
      final daily = decoded['daily'] as Map<String, dynamic>? ?? {};

      // Determine starting index for hourly forecast matching current time
      final hourlyTimes = (hourly['time'] as List<dynamic>?) ?? [];
      final currentTimeStr = current['time'] as String?;
      int currentHourIndex = 0;
      if (currentTimeStr != null) {
        final parsedCurrentTime = DateTime.tryParse(currentTimeStr);
        if (parsedCurrentTime != null) {
          for (int i = 0; i < hourlyTimes.length; i++) {
            final t = DateTime.tryParse(hourlyTimes[i].toString());
            if (t != null &&
                t.year == parsedCurrentTime.year &&
                t.month == parsedCurrentTime.month &&
                t.day == parsedCurrentTime.day &&
                t.hour == parsedCurrentTime.hour) {
              currentHourIndex = i;
              break;
            }
          }
        }
      }

      // Parse Hourly (24 forward-looking entries from current time)
      final List<HourlyForecast> hourlyList = [];
      final hourlyTemps = (hourly['temperature_2m'] as List<dynamic>?) ?? [];
      final hourlyFeels = (hourly['apparent_temperature'] as List<dynamic>?) ?? [];
      final hourlyHum = (hourly['relative_humidity_2m'] as List<dynamic>?) ?? [];
      final hourlyDew = (hourly['dew_point_2m'] as List<dynamic>?) ?? [];
      final hourlyRain = (hourly['precipitation_probability'] as List<dynamic>?) ?? [];
      final hourlyCodes = (hourly['weather_code'] as List<dynamic>?) ?? [];
      final hourlyWinds = (hourly['wind_speed_10m'] as List<dynamic>?) ?? [];
      final hourlyWindDirs = (hourly['wind_direction_10m'] as List<dynamic>?) ?? [];
      final hourlyGusts = (hourly['wind_gusts_10m'] as List<dynamic>?) ?? [];
      final hourlyPressures = (hourly['surface_pressure'] as List<dynamic>?) ?? [];
      final hourlyIsDay = (hourly['is_day'] as List<dynamic>?) ?? [];

      final int availableHours = hourlyTimes.length - currentHourIndex;
      final int hourlyCount = availableHours > 0 ? availableHours.clamp(0, 24) : hourlyTimes.length.clamp(0, 24);
      final int baseIndex = availableHours > 0 ? currentHourIndex : 0;

      for (int k = 0; k < hourlyCount; k++) {
        final int i = baseIndex + k;
        final parsedTime = DateTime.tryParse(hourlyTimes[i].toString()) ?? DateTime.now();
        final hourStr = DateFormat('ha').format(parsedTime).toLowerCase();
        hourlyList.add(HourlyForecast(
          time: parsedTime,
          hourLabel: k == 0 ? 'Now' : hourStr,
          temperature: (hourlyTemps[i] as num?)?.toDouble() ?? 0.0,
          feelsLike: (hourlyFeels.length > i ? (hourlyFeels[i] as num?)?.toDouble() : null) ?? 0.0,
          precipitationProbability: (hourlyRain[i] as num?)?.toInt() ?? 0,
          weatherCode: (hourlyCodes[i] as num?)?.toInt() ?? 0,
          windSpeed: (hourlyWinds.length > i ? (hourlyWinds[i] as num?)?.toDouble() : null) ?? 10.0,
          windDirection: (hourlyWindDirs.length > i ? (hourlyWindDirs[i] as num?)?.toInt() : null) ?? 180,
          windGusts: (hourlyGusts.length > i ? (hourlyGusts[i] as num?)?.toDouble() : null) ?? 15.0,
          humidity: (hourlyHum.length > i ? (hourlyHum[i] as num?)?.toInt() : null) ?? 60,
          dewPoint: (hourlyDew.length > i ? (hourlyDew[i] as num?)?.toDouble() : null) ?? 15.0,
          pressure: (hourlyPressures.length > i ? (hourlyPressures[i] as num?)?.toDouble() : null) ?? 1013.25,
          isDay: (hourlyIsDay.length > i ? (hourlyIsDay[i] as num?)?.toInt() == 1 : true),
        ));
      }

      // Parse Daily (up to 8 days)
      final List<DailyForecast> dailyList = [];
      final dailyDates = (daily['time'] as List<dynamic>?) ?? [];
      final dailyMaxTemps = (daily['temperature_2m_max'] as List<dynamic>?) ?? [];
      final dailyMinTemps = (daily['temperature_2m_min'] as List<dynamic>?) ?? [];
      final dailyRain = (daily['precipitation_probability_max'] as List<dynamic>?) ?? [];
      final dailyPrecipSums = (daily['precipitation_sum'] as List<dynamic>?) ?? [];
      final dailyCodes = (daily['weather_code'] as List<dynamic>?) ?? [];
      final dailySunrises = (daily['sunrise'] as List<dynamic>?) ?? [];
      final dailySunsets = (daily['sunset'] as List<dynamic>?) ?? [];
      final dailyUvMax = (daily['uv_index_max'] as List<dynamic>?) ?? [];

      final int dailyCount = dailyDates.length.clamp(0, 8);
      for (int i = 0; i < dailyCount; i++) {
        final parsedDate = DateTime.tryParse(dailyDates[i].toString()) ?? DateTime.now();
        final dayStr = i == 0 ? 'Today' : DateFormat('EEE').format(parsedDate);

        String riseTime = '06:00';
        if (dailySunrises.length > i && dailySunrises[i] != null) {
          final dt = DateTime.tryParse(dailySunrises[i].toString());
          if (dt != null) riseTime = DateFormat('HH:mm').format(dt);
        }

        String setTime = '18:00';
        if (dailySunsets.length > i && dailySunsets[i] != null) {
          final dt = DateTime.tryParse(dailySunsets[i].toString());
          if (dt != null) setTime = DateFormat('HH:mm').format(dt);
        }

        dailyList.add(DailyForecast(
          date: parsedDate,
          dayLabel: dayStr,
          maxTemp: (dailyMaxTemps[i] as num?)?.toDouble() ?? 0.0,
          minTemp: (dailyMinTemps[i] as num?)?.toDouble() ?? 0.0,
          precipitationProbability: (dailyRain[i] as num?)?.toInt() ?? 0,
          weatherCode: (dailyCodes[i] as num?)?.toInt() ?? 0,
          precipitationSum: (dailyPrecipSums.length > i ? (dailyPrecipSums[i] as num?)?.toDouble() : null) ?? 0.0,
          sunrise: riseTime,
          sunset: setTime,
          uvIndexMax: (dailyUvMax.length > i ? (dailyUvMax[i] as num?)?.toDouble() : null) ?? 5.0,
        ));
      }

      // UV & Visibility: prioritize current observation, fallback to current hour index in hourly
      final currentUv = (current['uv_index'] as num?)?.toDouble() ??
          ((hourly['uv_index'] as List<dynamic>?)?.isNotEmpty == true &&
                  (hourly['uv_index'] as List<dynamic>).length > currentHourIndex
              ? ((hourly['uv_index'] as List<dynamic>)[currentHourIndex] as num?)?.toDouble() ?? 0.0
              : 0.0);

      final currentVisMeters = (current['visibility'] as num?)?.toDouble() ??
          ((hourly['visibility'] as List<dynamic>?)?.isNotEmpty == true &&
                  (hourly['visibility'] as List<dynamic>).length > currentHourIndex
              ? ((hourly['visibility'] as List<dynamic>)[currentHourIndex] as num?)?.toDouble() ?? 10000.0
              : 10000.0);
      final currentVisKm = currentVisMeters / 1000.0;

      final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
      final feels = (current['apparent_temperature'] as num?)?.toDouble() ?? 0.0;
      final code = (current['weather_code'] as num?)?.toInt() ?? 0;
      final humidity = (current['relative_humidity_2m'] as num?)?.toInt() ?? 0;
      final wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
      final windDir = (current['wind_direction_10m'] as num?)?.toInt() ?? 0;
      final windGusts = (current['wind_gusts_10m'] as num?)?.toDouble() ?? (wind * 1.35);
      final pressure = (current['surface_pressure'] as num?)?.toDouble() ?? 1013.25;
      final dew = (current['dew_point_2m'] as num?)?.toDouble() ?? 0.0;
      final cloudCover = (current['cloud_cover'] as num?)?.toInt() ?? 25;
      final isDay = (current['is_day'] as num?)?.toInt() == 1;

      // 6-hour pressure history trend leading up to current hour
      final List<PressureTrendPoint> pressureHistory = [];
      final int startHistory = (currentHourIndex - 5).clamp(0, hourlyPressures.length);
      for (int i = startHistory; i <= currentHourIndex && i < hourlyPressures.length; i++) {
        final parsedTime = DateTime.tryParse(hourlyTimes[i].toString()) ?? DateTime.now();
        final hourStr = i == currentHourIndex ? 'Now' : DateFormat('ha').format(parsedTime).toLowerCase();
        final p = (hourlyPressures[i] as num?)?.toDouble() ?? 1013.25;
        pressureHistory.add(PressureTrendPoint(
          time: parsedTime,
          hourLabel: hourStr,
          pressure: p,
        ));
      }

      // Air Quality & Pollen Parsing
      AirQuality airQuality;
      AllergyForecast allergy;

      final aqiCurr = aqiDecoded?['current'] as Map<String, dynamic>?;
      if (aqiCurr != null) {
        final aqiVal = (aqiCurr['us_aqi'] as num?)?.toInt() ?? 35;
        String cat = 'Good';
        if (aqiVal > 300) {
          cat = 'Hazardous';
        } else if (aqiVal > 200) {
          cat = 'Very Unhealthy';
        } else if (aqiVal > 150) {
          cat = 'Unhealthy';
        } else if (aqiVal > 100) {
          cat = 'Unhealthy for Sensitive';
        } else if (aqiVal > 50) {
          cat = 'Moderate';
        }

        airQuality = AirQuality(
          aqi: aqiVal,
          category: cat,
          pm25: (aqiCurr['pm2_5'] as num?)?.toDouble() ?? 8.5,
          pm10: (aqiCurr['pm10'] as num?)?.toDouble() ?? 15.0,
          no2: (aqiCurr['nitrogen_dioxide'] as num?)?.toDouble() ?? 12.0,
          o3: (aqiCurr['ozone'] as num?)?.toDouble() ?? 25.0,
        );

        final grassVal = ((aqiCurr['grass_pollen'] as num?)?.toDouble() ?? 15.0).clamp(0.0, 100.0);
        final birchVal = ((aqiCurr['birch_pollen'] as num?)?.toDouble() ?? 25.0).clamp(0.0, 100.0);
        final weedVal = ((aqiCurr['ragweed_pollen'] as num?)?.toDouble() ?? 45.0).clamp(0.0, 100.0);

        String getLevel(double v) => v > 70 ? 'Very High' : v > 50 ? 'High' : v > 25 ? 'Moderate' : 'Low';

        allergy = AllergyForecast(
          grass: PollenItem(
            type: 'grass',
            name: 'Grass Pollen',
            value: grassVal,
            level: getLevel(grassVal),
            color: const Color(0xFF10B981),
          ),
          tree: PollenItem(
            type: 'tree',
            name: 'Tree Pollen',
            value: birchVal,
            level: getLevel(birchVal),
            color: const Color(0xFF38BDF8),
          ),
          weed: PollenItem(
            type: 'weed',
            name: 'Weed Pollen',
            value: weedVal,
            level: getLevel(weedVal),
            color: const Color(0xFFF97316),
          ),
          overallRisk: weedVal > 50 ? 'High' : (grassVal > 25 || birchVal > 25 ? 'Moderate' : 'Low'),
          primaryAllergen: weedVal >= birchVal && weedVal >= grassVal ? 'Weed Pollen (Ragweed)' : 'Tree Pollen',
          advisory: weedVal > 50
              ? 'Weed pollen counts are elevated; consider closing windows in early afternoon.'
              : 'Airborne pollen levels are in standard acceptable ranges.',
        );
      } else {
        // Realistic synthetic estimation based on weather conditions
        final estAqi = (30 + (100 - humidity) * 0.35 + (wind < 5 ? 20 : 0)).round().clamp(15, 180);
        final String cat = estAqi > 150 ? 'Unhealthy' : estAqi > 100 ? 'Unhealthy for Sensitive' : estAqi > 50 ? 'Moderate' : 'Good';
        airQuality = AirQuality(
          aqi: estAqi,
          category: cat,
          pm25: (estAqi * 0.28).clamp(3.0, 80.0),
          pm10: (estAqi * 0.45).clamp(5.0, 120.0),
          no2: 12.0,
          o3: 25.0,
        );
        allergy = const AllergyForecast(
          grass: PollenItem(type: 'grass', name: 'Grass Pollen', value: 25, level: 'Low', color: Color(0xFF10B981)),
          tree: PollenItem(type: 'tree', name: 'Tree Pollen', value: 40, level: 'Moderate', color: Color(0xFF38BDF8)),
          weed: PollenItem(type: 'weed', name: 'Weed Pollen', value: 65, level: 'High', color: Color(0xFFF97316)),
          overallRisk: 'Moderate',
          primaryAllergen: 'Weed Pollen',
          advisory: 'Pollen counts are moderate; sensitive groups take precautionary care.',
        );
      }

      // Severe Warnings
      final nowTime = DateTime.now();
      final List<SevereAlert> alerts = [];
      if ([95, 96, 99].contains(code) || wind >= 60.0) {
        alerts.add(SevereAlert(
          id: 'storm_${nowTime.millisecondsSinceEpoch}',
          title: code == 99 ? 'Extreme Hailstorm & Severe Convective Watch' : 'Severe Thunderstorm Warning',
          area: city.name,
          severity: AlertSeverity.warning,
          description: 'Intense convective cells detected with gusts reaching ${windGusts.round()} km/h.',
          instruction: 'Remain indoors away from windows. Unplug sensitive electronics and avoid travel.',
          issuedAt: nowTime,
          expiresAt: nowTime.add(const Duration(hours: 4)),
          isExtreme: true,
        ));
      }

      if (temp >= 38.0) {
        alerts.add(SevereAlert(
          id: 'heat_${nowTime.millisecondsSinceEpoch}',
          title: 'Excessive Heat Advisory',
          area: city.name,
          severity: AlertSeverity.advisory,
          description: 'Thermal index of ${temp.round()}°C exceeding normal seasonal thresholds.',
          instruction: 'Hydrate frequently and avoid strenuous outdoor activity during peak sun hours.',
          issuedAt: nowTime,
          expiresAt: nowTime.add(const Duration(hours: 6)),
          isExtreme: false,
        ));
      }

      final weatherData = WeatherData(
        city: city,
        temperature: temp,
        feelsLike: feels,
        weatherCode: code,
        humidity: humidity,
        windSpeed: wind,
        windDirection: windDir,
        windGusts: windGusts,
        pressure: pressure,
        uvIndex: currentUv,
        visibility: currentVisKm,
        dewPoint: dew,
        cloudCover: cloudCover,
        isDay: isDay,
        hourly: hourlyList,
        daily: dailyList,
        severeAlerts: alerts,
        airQuality: airQuality,
        allergy: allergy,
        pressureHistory: pressureHistory,
        fetchedAt: DateTime.now(),
      );

      // Persist into cache
      await _cacheWeatherData(weatherData);

      return weatherData;
    } catch (e, stack) {
      AppLogger.instance.error('Network error fetching weather, checking cache', e, stack);

      // Offline fallback: try cache
      final cached = await getCachedWeather(cityName: city.name);
      if (cached != null) {
        AppLogger.instance.info('Loaded weather from local cache for ${city.name}');
        return cached;
      }

      if (e is AppFailure) rethrow;
      throw NetworkFailure('Unable to reach meteorological satellite network: $e', cause: e);
    }
  }

  @override
  Future<List<CityLocation>> searchCities(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final uri = Uri.parse(
      '${AppConstants.geocodingApiBaseUrl}/search?name=${Uri.encodeComponent(cleanQuery)}&count=10&language=en&format=json',
    );

    try {
      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw ServerFailure('Geocoding search failed with status ${response.statusCode}');
      }

      final dynamic data = json.decode(response.body);
      if (data is! Map<String, dynamic> || !data.containsKey('results')) {
        return [];
      }

      final List<dynamic> results = data['results'] as List<dynamic>;
      return results.map((item) {
        final map = item as Map<String, dynamic>;
        return CityLocation(
          name: map['name'] as String? ?? 'Unknown',
          country: map['country'] as String? ?? (map['admin1'] as String? ?? ''),
          latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e, stack) {
      AppLogger.instance.error('Error during city search', e, stack);
      return [];
    }
  }

  Future<void> _cacheWeatherData(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${AppConstants.keyWeatherCache}_${data.city.name.toLowerCase()}',
        data.toRawJson(),
      );
    } catch (e, stack) {
      AppLogger.instance.warning('Could not save weather cache', e, stack);
    }
  }

  @override
  Future<WeatherData?> getCachedWeather({required String cityName}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('${AppConstants.keyWeatherCache}_${cityName.toLowerCase()}');
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return WeatherData.fromRawJson(jsonStr);
    } catch (e, stack) {
      AppLogger.instance.warning('Failed to deserialize weather cache', e, stack);
      return null;
    }
  }

  @override
  Future<List<CityLocation>> getSavedCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(AppConstants.keySavedCities);
      if (listJson == null || listJson.isEmpty) {
        return defaultCities;
      }
      return listJson
          .map((item) => CityLocation.fromJson(json.decode(item) as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      AppLogger.instance.warning('Error loading saved cities, falling back to defaults', e, stack);
      return defaultCities;
    }
  }

  @override
  Future<void> saveCity(CityLocation city) async {
    try {
      final currentList = await getSavedCities();
      final exists = currentList.any(
        (c) => c.name.toLowerCase() == city.name.toLowerCase() &&
               (c.latitude - city.latitude).abs() < 0.1,
      );

      final updated = exists
          ? currentList.map((c) => c.name == city.name ? city : c).toList()
          : [...currentList, city];

      final prefs = await SharedPreferences.getInstance();
      final encoded = updated.map((c) => json.encode(c.toJson())).toList();
      await prefs.setStringList(AppConstants.keySavedCities, encoded);
    } catch (e, stack) {
      AppLogger.instance.error('Error saving city to persistent store', e, stack);
    }
  }

  @override
  Future<void> removeCity(CityLocation city) async {
    try {
      final currentList = await getSavedCities();
      final updated = currentList
          .where((c) => !(c.name.toLowerCase() == city.name.toLowerCase() &&
                          (c.latitude - city.latitude).abs() < 0.1))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final encoded = updated.map((c) => json.encode(c.toJson())).toList();
      await prefs.setStringList(AppConstants.keySavedCities, encoded);
    } catch (e, stack) {
      AppLogger.instance.error('Error removing city from persistent store', e, stack);
    }
  }

  @override
  Future<UserSettings> getUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyUserSettings);
      if (jsonStr == null || jsonStr.isEmpty) {
        return const UserSettings();
      }
      return UserSettings.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e, stack) {
      AppLogger.instance.warning('Error loading user settings, using defaults', e, stack);
      return const UserSettings();
    }
  }

  @override
  Future<void> saveUserSettings(UserSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserSettings, json.encode(settings.toJson()));
    } catch (e, stack) {
      AppLogger.instance.error('Error saving user settings', e, stack);
    }
  }
}

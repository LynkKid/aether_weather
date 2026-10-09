import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether_weather/core/theme/app_theme.dart';
import 'package:aether_weather/features/weather/data/repositories/weather_repository.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';

class FakeWeatherRepository implements IWeatherRepository {
  @override
  Future<WeatherData> fetchWeather({required CityLocation city}) async {
    final now = DateTime.now();
    return WeatherData(
      city: city,
      temperature: 20.0,
      feelsLike: 20.0,
      weatherCode: 0,
      humidity: 50,
      windSpeed: 20.0,
      windDirection: 90,
      pressure: 1013.0,
      uvIndex: 3.0,
      visibility: 10.0,
      dewPoint: 10.0,
      hourly: const [],
      daily: const [],
      severeAlerts: const [],
      airQuality: const AirQuality(
        aqi: 25,
        category: 'Good',
        pm25: 5.0,
        pm10: 10.0,
        no2: 8.0,
        o3: 30.0,
      ),
      allergy: const AllergyForecast(
        grass: PollenItem(type: 'grass', name: 'Grass', value: 10.0, level: 'Low', color: Color(0xFF10B981)),
        tree: PollenItem(type: 'tree', name: 'Tree', value: 5.0, level: 'Low', color: Color(0xFF10B981)),
        weed: PollenItem(type: 'weed', name: 'Weed', value: 2.0, level: 'Low', color: Color(0xFF10B981)),
        overallRisk: 'Low',
        primaryAllergen: 'Grass',
        advisory: 'Low pollen risk.',
      ),
      pressureHistory: const [],
      fetchedAt: now,
    );
  }

  @override
  Future<List<CityLocation>> searchCities(String query) async {
    return [
      CityLocation(name: query, country: 'TestLand', latitude: 10.0, longitude: 20.0),
    ];
  }

  @override
  Future<WeatherData?> getCachedWeather({required String cityName}) async => null;

  @override
  Future<List<CityLocation>> getSavedCities() async => const [];

  @override
  Future<void> saveCity(CityLocation city) async {}

  @override
  Future<void> removeCity(CityLocation city) async {}

  @override
  Future<UserSettings> getUserSettings() async => const UserSettings();

  @override
  Future<void> saveUserSettings(UserSettings settings) async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WeatherProvider Unit Tests', () {
    test('formatTemperature converts Celsius to Fahrenheit accurately', () async {
      final provider = WeatherProvider(repository: FakeWeatherRepository());

      // Default is Celsius
      expect(provider.formatTemperature(0.0), '0°');
      expect(provider.formatTemperature(25.0), '25°');

      // Switch to Fahrenheit
      await provider.setTemperatureUnit(true);
      expect(provider.isFahrenheit, true);
      expect(provider.formatTemperature(0.0), '32°');
      expect(provider.formatTemperature(100.0), '212°');
    });

    test('formatWindSpeed converts km/h to mph accurately', () async {
      final provider = WeatherProvider(repository: FakeWeatherRepository());

      // Default is km/h
      expect(provider.formatWindSpeed(50.0), '50 km/h');

      // Switch to mph
      await provider.setWindUnit('mph');
      expect(provider.isMph, true);
      expect(provider.formatWindSpeed(100.0), '62 mph');
    });

    test('setThemeMode updates themeMode state and activeThemeData', () async {
      final provider = WeatherProvider(repository: FakeWeatherRepository());

      await provider.setThemeMode(AppThemeMode.light);
      expect(provider.themeMode, AppThemeMode.light);
      expect(provider.activeThemeData.brightness, Brightness.light);

      await provider.setThemeMode(AppThemeMode.oled);
      expect(provider.themeMode, AppThemeMode.oled);
      expect(provider.activeThemeData.scaffoldBackgroundColor, AppTheme.oledBg);
    });

    test('triggerTestAlert injects simulated severe alert into weather state', () async {
      final provider = WeatherProvider(repository: FakeWeatherRepository());

      const city = CityLocation(name: 'Tokyo', country: 'Japan', latitude: 35.6, longitude: 139.6);
      await provider.fetchWeatherForCity(city);

      expect(provider.weather?.severeAlerts.isEmpty, true);

      await provider.triggerTestAlert();
      expect(provider.weather?.severeAlerts.isNotEmpty, true);
      expect(provider.weather?.severeAlerts.first.title, contains('Tornado'));
    });

    test('searchCities updates searchResults list', () async {
      final provider = WeatherProvider(repository: FakeWeatherRepository());

      await provider.searchCities('Sydney');
      expect(provider.searchResults.length, 1);
      expect(provider.searchResults.first.name, 'Sydney');

      provider.clearSearchResults();
      expect(provider.searchResults.isEmpty, true);
    });
  });
}

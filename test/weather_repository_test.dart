import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether_weather/core/errors/app_failure.dart';
import 'package:aether_weather/features/weather/data/repositories/weather_repository.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WeatherRepository Tests', () {
    const testCity = CityLocation(
      name: 'Tokyo',
      country: 'Japan',
      latitude: 35.6762,
      longitude: 139.6503,
    );

    test('fetchWeather returns WeatherData when HTTP status is 200', () async {
      final mockClient = MockHttpClient((request) async {
        final mockResponse = {
          'current': {
            'temperature_2m': 19.4,
            'apparent_temperature': 18.2,
            'weather_code': 1,
            'relative_humidity_2m': 62,
            'wind_speed_10m': 15.5,
            'wind_direction_10m': 210,
            'surface_pressure': 1012.0,
            'dew_point_2m': 11.5,
          },
          'hourly': {
            'time': ['2026-10-09T00:00', '2026-10-09T01:00'],
            'temperature_2m': [19.0, 18.5],
            'apparent_temperature': [18.0, 17.5],
            'precipitation_probability': [10, 20],
            'weather_code': [1, 2],
            'uv_index': [0.0, 0.0],
            'visibility': [10000.0, 10000.0],
          },
          'daily': {
            'time': ['2026-10-09', '2026-10-10'],
            'weather_code': [1, 2],
            'temperature_2m_max': [23.0, 22.0],
            'temperature_2m_min': [15.0, 14.0],
            'precipitation_probability_max': [15, 30],
          },
        };

        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = WeatherRepository(httpClient: mockClient);
      final result = await repository.fetchWeather(city: testCity);

      expect(result.city.name, 'Tokyo');
      expect(result.temperature, 19.4);
      expect(result.humidity, 62);
      expect(result.hourly.length, 2);
      expect(result.daily.length, 2);
      expect(result.conditionText, 'Mostly Clear');
    });

    test('fetchWeather triggers SevereAlert when storm code 99 is returned', () async {
      final mockClient = MockHttpClient((request) async {
        final mockResponse = {
          'current': {
            'temperature_2m': 28.0,
            'apparent_temperature': 31.0,
            'weather_code': 99, // Severe thunderstorm with hail
            'relative_humidity_2m': 85,
            'wind_speed_10m': 75.0, // Severe wind
            'wind_direction_10m': 270,
            'surface_pressure': 995.0,
            'dew_point_2m': 24.0,
          },
          'hourly': {
            'time': ['2026-10-09T00:00'],
            'temperature_2m': [28.0],
            'apparent_temperature': [31.0],
            'precipitation_probability': [90],
            'weather_code': [99],
            'uv_index': [1.0],
            'visibility': [2000.0],
          },
          'daily': {
            'time': ['2026-10-09'],
            'weather_code': [99],
            'temperature_2m_max': [29.0],
            'temperature_2m_min': [20.0],
            'precipitation_probability_max': [95],
          },
        };

        return http.Response(json.encode(mockResponse), 200);
      });

      final repository = WeatherRepository(httpClient: mockClient);
      final result = await repository.fetchWeather(city: testCity);

      expect(result.isSevere, true);
      expect(result.severeAlerts.length, 1);
      expect(result.severeAlerts.first.isExtreme, true);
      expect(result.severeAlerts.first.title, contains('Hailstorm'));
    });

    test('fetchWeather throws ServerFailure when API responds with error code', () async {
      final mockClient = MockHttpClient((request) async {
        return http.Response('Server Error', 500);
      });

      final repository = WeatherRepository(httpClient: mockClient);

      expect(
        () async => repository.fetchWeather(city: testCity),
        throwsA(isA<ServerFailure>()),
      );
    });

    test('searchCities parses geocoding API results correctly', () async {
      final mockClient = MockHttpClient((request) async {
        final mockResults = {
          'results': [
            {
              'name': 'Paris',
              'country': 'France',
              'latitude': 48.8534,
              'longitude': 2.3488,
            },
            {
              'name': 'Paris',
              'country': 'United States',
              'latitude': 33.6609,
              'longitude': -95.5555,
            },
          ],
        };
        return http.Response(json.encode(mockResults), 200);
      });

      final repository = WeatherRepository(httpClient: mockClient);
      final cities = await repository.searchCities('Paris');

      expect(cities.length, 2);
      expect(cities.first.name, 'Paris');
      expect(cities.first.country, 'France');
      expect(cities.first.latitude, 48.8534);
    });

    test('getSavedCities returns default cities initially', () async {
      final repository = WeatherRepository();
      final cities = await repository.getSavedCities();

      expect(cities.isNotEmpty, true);
      expect(cities.any((c) => c.name == 'Tokyo'), true);
    });

    test('saveCity and removeCity persist into local storage', () async {
      final repository = WeatherRepository();
      const newCity = CityLocation(
        name: 'Berlin',
        country: 'Germany',
        latitude: 52.52,
        longitude: 13.405,
      );

      await repository.saveCity(newCity);
      var cities = await repository.getSavedCities();
      expect(cities.any((c) => c.name == 'Berlin'), true);

      await repository.removeCity(newCity);
      cities = await repository.getSavedCities();
      expect(cities.any((c) => c.name == 'Berlin'), false);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';
import 'package:aether_weather/features/weather/presentation/providers/radar_provider.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:aether_weather/features/weather/presentation/screens/main_navigation_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Aether Weather MainNavigationScreen smoke test', (WidgetTester tester) async {
    final weatherProvider = WeatherProvider();
    final radarProvider = RadarProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ChangeNotifierProvider<RadarProvider>.value(value: radarProvider),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    // Initial check: app bar title
    expect(find.text('Aether Weather'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
    expect(find.text('Radar'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Cities'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Radar Tab
    await tester.tap(find.text('Radar'));
    await tester.pump();
    expect(find.textContaining('Precipitation'), findsOneWidget);

    // Tap Alerts Tab
    await tester.tap(find.text('Alerts'));
    await tester.pump();
    expect(find.text('EMERGENCY WARNING DISPATCHER'), findsOneWidget);

    // Tap Settings Tab
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(find.text('DISPLAY & ATMOSPHERIC THEME'), findsOneWidget);

    // Tap Cities Tab
    await tester.tap(find.text('Cities'));
    await tester.pump();
    expect(find.text('Use GPS Live Coordinates'), findsOneWidget);

    // Clean up
    radarProvider.dispose();
  });

  test('WeatherData JSON serialization test', () {
    const city = CityLocation(
      name: 'Tokyo',
      country: 'Japan',
      latitude: 35.6762,
      longitude: 139.6503,
    );

    final now = DateTime.now();
    final weather = WeatherData(
      city: city,
      temperature: 22.5,
      feelsLike: 23.0,
      weatherCode: 0,
      humidity: 55,
      windSpeed: 14.2,
      windDirection: 180,
      pressure: 1013.2,
      uvIndex: 4.5,
      visibility: 10.0,
      dewPoint: 12.0,
      hourly: [
        HourlyForecast(
          time: now,
          hourLabel: 'Now',
          temperature: 22.5,
          feelsLike: 23.0,
          precipitationProbability: 0,
          weatherCode: 0,
        ),
      ],
      daily: [
        DailyForecast(
          date: now,
          dayLabel: 'Today',
          maxTemp: 24.0,
          minTemp: 18.0,
          precipitationProbability: 10,
          weatherCode: 0,
        ),
      ],
      severeAlerts: const [],
      airQuality: const AirQuality(
        aqi: 42,
        category: 'Good',
        pm25: 8.0,
        pm10: 15.0,
        no2: 12.0,
        o3: 25.0,
      ),
      allergy: const AllergyForecast(
        grass: PollenItem(type: 'grass', name: 'Grass', value: 10.0, level: 'Low', color: Color(0xFF10B981)),
        tree: PollenItem(type: 'tree', name: 'Tree', value: 5.0, level: 'Low', color: Color(0xFF10B981)),
        weed: PollenItem(type: 'weed', name: 'Weed', value: 2.0, level: 'Low', color: Color(0xFF10B981)),
        overallRisk: 'Low',
        primaryAllergen: 'Grass',
        advisory: 'Pollen levels are low.',
      ),
      pressureHistory: const [],
      fetchedAt: now,
    );

    final jsonMap = weather.toJson();
    final reconstructed = WeatherData.fromJson(jsonMap);

    expect(reconstructed.city.name, 'Tokyo');
    expect(reconstructed.temperature, 22.5);
    expect(reconstructed.hourly.length, 1);
    expect(reconstructed.daily.length, 1);
    expect(reconstructed.conditionText, 'Sunny');
    expect(reconstructed.isSevere, false);
  });
}

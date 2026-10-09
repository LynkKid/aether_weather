import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:aether_weather/features/weather/presentation/widgets/daily_forecast_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/hourly_forecast_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/meteorological_grid_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/severe_alert_banner.dart';
import 'package:aether_weather/features/weather/presentation/widgets/weather_hero_card.dart';

class ForecastTab extends StatelessWidget {
  final VoidCallback? onOpenAlerts;
  final VoidCallback? onOpenSettings;

  const ForecastTab({
    super.key,
    this.onOpenAlerts,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.weather;
    final atmTheme = weatherProvider.atmosphericTheme;

    if (weatherProvider.isLoading && weather == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Acquiring Doppler radar & synoptic telemetry...',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                weatherProvider.errorMessage ?? 'Unable to acquire meteorological telemetry',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => weatherProvider.refreshWeather(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => weatherProvider.refreshWeather(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Active Severe Weather Banner (if any)
          if (weather.severeAlerts.isNotEmpty) ...[
            SevereAlertBanner(alerts: weather.severeAlerts),
            const SizedBox(height: 12),
          ],

          // Current Weather Hero
          WeatherHeroCard(
            weather: weather,
            formattedTemp: weatherProvider.formatTemperature(weather.temperature),
            formattedFeelsLike: weatherProvider.formatTemperature(weather.feelsLike),
            formattedWind: weatherProvider.formatWindSpeed(weather.windSpeed),
            atmosphericTheme: atmTheme,
            onOpenAlerts: onOpenAlerts,
          ),
          const SizedBox(height: 16),

          // 24-Hour Forecast Scrubber
          if (weather.hourly.isNotEmpty) ...[
            HourlyForecastCard(
              hourly: weather.hourly,
              formatTemp: weatherProvider.formatTemperature,
              atmosphericTheme: atmTheme,
            ),
            const SizedBox(height: 16),
          ],

          // 7-Day Synoptic Outlook
          if (weather.daily.isNotEmpty) ...[
            DailyForecastCard(
              daily: weather.daily,
              formatTemp: weatherProvider.formatTemperature,
              atmosphericTheme: atmTheme,
            ),
            const SizedBox(height: 16),
          ],

          // Atmospheric Telemetry Grid with 17 specialized components
          MeteorologicalGridCard(
            weather: weather,
            formattedWind: weatherProvider.formatWindSpeed(weather.windSpeed),
            formattedGusts: weatherProvider.formatWindSpeed(weather.windGusts),
            isFahrenheit: weatherProvider.isFahrenheit,
            isMph: weatherProvider.isMph,
            atmosphericTheme: atmTheme,
            solarEfficiency: weatherProvider.solarEfficiency,
            solarCycle: weatherProvider.solarCycle,
            moonPhase: weatherProvider.moonPhase,
            lunarCalendar: weatherProvider.lunarCalendar,
            climateSummary: weatherProvider.climateSummary,
            settings: weatherProvider.settings,
            onOpenSettings: onOpenSettings ?? () {},
            onManualRefresh: () => weatherProvider.refreshWeather(),
            isRefreshing: weatherProvider.isLoading,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

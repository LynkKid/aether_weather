import 'package:flutter/material.dart';
import 'package:aether_weather/core/atmospheric_theme.dart';
import 'package:aether_weather/core/calculators/climate_calculator.dart';
import 'package:aether_weather/core/calculators/moon_calculator.dart';
import 'package:aether_weather/core/calculators/solar_calculator.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';
import 'package:aether_weather/features/weather/presentation/widgets/adaptive_refresh_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/air_quality_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/allergy_forecast_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/apparent_temperature_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/climate_comparison_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/humidity_trend_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/lunar_calendar_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/moon_phase_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/night_mode_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/precipitation_area_chart_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/pressure_gauge_trend_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/solar_cycle_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/solar_efficiency_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/uv_forecast_chart_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/visibility_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/wind_compass_card.dart';
import 'package:aether_weather/features/weather/presentation/widgets/wind_rose_chart_card.dart';

class MeteorologicalGridCard extends StatelessWidget {
  final WeatherData weather;
  final String formattedWind;
  final String formattedGusts;
  final bool isFahrenheit;
  final bool isMph;
  final AtmosphericTheme atmosphericTheme;
  final SolarEfficiencyMetrics solarEfficiency;
  final SolarCycleProgress solarCycle;
  final MoonPhaseInfo moonPhase;
  final List<CalendarMoonDay> lunarCalendar;
  final ClimateSummary climateSummary;
  final UserSettings settings;
  final VoidCallback onOpenSettings;
  final VoidCallback onManualRefresh;
  final bool isRefreshing;

  const MeteorologicalGridCard({
    super.key,
    required this.weather,
    required this.formattedWind,
    required this.formattedGusts,
    required this.isFahrenheit,
    required this.isMph,
    required this.atmosphericTheme,
    required this.solarEfficiency,
    required this.solarCycle,
    required this.moonPhase,
    required this.lunarCalendar,
    required this.climateSummary,
    required this.settings,
    required this.onOpenSettings,
    required this.onManualRefresh,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = atmosphericTheme.cardBg;
    final cardBorder = atmosphericTheme.cardBorder;
    final textColor = atmosphericTheme.textColor;
    final subtitleColor = atmosphericTheme.subtitleColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.sensors_rounded, size: 16, color: subtitleColor),
            const SizedBox(width: 8),
            Text(
              'DEEP METEOROLOGICAL TELEMETRY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 1. 24-Hour Precipitation Probability Area Chart
        PrecipitationAreaChartCard(
          hourly: weather.hourly,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 2. Wind Compass Card
        WindCompassCard(
          windSpeed: weather.windSpeed,
          windGusts: weather.windGusts,
          windDirection: weather.windDirection,
          formattedSpeed: formattedWind,
          formattedGusts: formattedGusts,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 3. 7-Day Peak UV Radiation Forecast Chart
        UvForecastChartCard(
          currentUv: weather.uvIndex,
          daily: weather.daily,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 4. Air Quality Index Card
        AirQualityCard(
          airQuality: weather.airQuality,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 5. 24H Humidity & Moisture Trend
        HumidityTrendCard(
          currentHumidity: weather.humidity,
          dewPoint: weather.dewPoint,
          hourly: weather.hourly,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 6. Actual Air Temp vs Feels-Like Comparison Gap
        ApparentTemperatureCard(
          currentTemp: weather.temperature,
          currentFeelsLike: weather.feelsLike,
          hourly: weather.hourly,
          isFahrenheit: isFahrenheit,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 7. Wind Rose Vector Distribution
        WindRoseChartCard(
          weather: weather,
          formattedWind: formattedWind,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 8. Solar Cycle & Daylight Progress Arc
        SolarCycleCard(
          cycle: solarCycle,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 9. Solar Photovoltaic Efficiency Card
        SolarEfficiencyCard(
          efficiency: solarEfficiency,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 10. Barometer Pressure & 6-Hour Trend Gauge
        PressureGaugeTrendCard(
          currentPressure: weather.pressure,
          pressureHistory: weather.pressureHistory,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 11. Optical Visibility Card
        VisibilityCard(
          visibilityKm: weather.visibility,
          isMph: isMph,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 12. Allergy & Airborne Pollen Forecast
        AllergyForecastCard(
          allergy: weather.allergy,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 13. 30-Year Climate Norms Comparison
        ClimateComparisonCard(
          climate: climateSummary,
          isFahrenheit: isFahrenheit,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 14. Lunar Phase & Illumination
        MoonPhaseCard(
          moon: moonPhase,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 15. 30-Day Lunar Cycle Calendar
        LunarCalendarCard(
          days: lunarCalendar,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 16. Night Mode Sleep Automation Card
        NightModeCard(
          settings: settings,
          onOpenSettings: onOpenSettings,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        const SizedBox(height: 12),

        // 17. Intelligent Adaptive Telemetry Refresh Card
        AdaptiveRefreshCard(
          onRefresh: onManualRefresh,
          isRefreshing: isRefreshing,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
      ],
    );
  }
}

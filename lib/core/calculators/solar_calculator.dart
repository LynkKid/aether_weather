import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class SolarEfficiencyMetrics {
  final int efficiencyPct; // 0 to 100
  final int sunAngleDeg; // 0 to 90 degrees above horizon
  final bool isSunUp;
  final int irradianceWm2; // W/m² (0 to 1050)
  final double estimatedKw5kWArray; // kW output for typical 5kW rooftop system
  final int cloudLossPct;
  final String efficiencyTier; // 'Peak', 'High', 'Moderate', 'Low', 'Zero (Night)'
  final Color tierColor;
  final String advice;

  const SolarEfficiencyMetrics({
    required this.efficiencyPct,
    required this.sunAngleDeg,
    required this.isSunUp,
    required this.irradianceWm2,
    required this.estimatedKw5kWArray,
    required this.cloudLossPct,
    required this.efficiencyTier,
    required this.tierColor,
    required this.advice,
  });
}

class SolarCycleProgress {
  final double progress; // 0.0 to 1.0 (portion of daytime elapsed)
  final bool isDaytime;
  final String sunrise;
  final String sunset;
  final String remainingDaylight;
  final String goldenHourStart;
  final String goldenHourEnd;

  const SolarCycleProgress({
    required this.progress,
    required this.isDaytime,
    required this.sunrise,
    required this.sunset,
    required this.remainingDaylight,
    required this.goldenHourStart,
    required this.goldenHourEnd,
  });
}

class SolarCalculator {
  static SolarEfficiencyMetrics calculateSolarEfficiency({
    required WeatherData weather,
    DailyForecast? todayForecast,
    double latitude = 35.68,
  }) {
    final now = DateTime.now();
    final isDay = weather.isDay;
    final forecast = todayForecast ?? (weather.daily.isNotEmpty ? weather.daily.first : null);

    int sunAngleDeg = 0;

    if (isDay && forecast != null) {
      try {
        final riseParts = forecast.sunrise.split(':').map(int.parse).toList();
        final setParts = forecast.sunset.split(':').map(int.parse).toList();

        final nowMinutes = now.hour * 60 + now.minute;
        final riseMinutes = riseParts[0] * 60 + riseParts[1];
        final setMinutes = setParts[0] * 60 + setParts[1];

        if (nowMinutes >= riseMinutes && nowMinutes <= setMinutes) {
          final dayLength = setMinutes - riseMinutes;
          final prog = (nowMinutes - riseMinutes) / math.max(1, dayLength);
          final maxMiddayAngle = math.max(30, math.min(85, 90 - latitude.abs().round() + 15));
          sunAngleDeg = (maxMiddayAngle * math.sin(prog * math.pi)).round();
        }
      } catch (_) {
        sunAngleDeg = 45;
      }
    } else if (isDay) {
      final hour = now.hour;
      if (hour >= 6 && hour <= 18) {
        final prog = (hour - 6) / 12.0;
        sunAngleDeg = (60 * math.sin(prog * math.pi)).round();
      }
    }

    if (!isDay || sunAngleDeg <= 0) {
      return const SolarEfficiencyMetrics(
        efficiencyPct: 0,
        sunAngleDeg: 0,
        isSunUp: false,
        irradianceWm2: 0,
        estimatedKw5kWArray: 0.0,
        cloudLossPct: 0,
        efficiencyTier: 'Zero (Night)',
        tierColor: Color(0xFF64748B),
        advice: 'Solar panels in dark standby mode. Generation resumes at sunrise.',
      );
    }

    final angleRad = (sunAngleDeg * math.pi) / 180.0;
    final geometricFactor = math.sin(angleRad);

    final cloudFraction = math.max(0, math.min(100, weather.cloudCover)) / 100.0;
    final cloudTransmission = 1.0 - 0.72 * math.pow(cloudFraction, 1.8);
    final cloudLossPct = ((1.0 - cloudTransmission) * 100).round();

    final uvFactor = math.min(1.15, math.max(0.4, 0.45 + (weather.uvIndex / 10.0) * 0.6));
    final rawEfficiency = geometricFactor * cloudTransmission * uvFactor * 100.0;
    final efficiencyPct = math.min(100, math.max(0, rawEfficiency.round()));

    final irradianceWm2 = ((efficiencyPct / 100.0) * 980).round();
    final estimatedKw5kWArray = (((efficiencyPct / 100.0) * 5.0) * 10).round() / 10.0;

    String tier;
    Color color;
    String advice;

    if (efficiencyPct >= 80) {
      tier = 'Peak';
      color = const Color(0xFF10B981);
      advice = 'Optimal generation conditions. Perfect for high-demand appliance cycles.';
    } else if (efficiencyPct >= 55) {
      tier = 'High';
      color = const Color(0xFF06B6D4);
      advice = 'Strong solar harvesting. Battery reserves will charge efficiently.';
    } else if (efficiencyPct >= 25) {
      tier = 'Moderate';
      color = const Color(0xFFF59E0B);
      advice = 'Cloud attenuation present. Reduced energy output expected.';
    } else {
      tier = 'Low';
      color = const Color(0xFFEF4444);
      advice = 'Heavy overcast or low angle. Minimal rooftop energy harvest.';
    }

    return SolarEfficiencyMetrics(
      efficiencyPct: efficiencyPct,
      sunAngleDeg: sunAngleDeg,
      isSunUp: true,
      irradianceWm2: irradianceWm2,
      estimatedKw5kWArray: estimatedKw5kWArray,
      cloudLossPct: cloudLossPct,
      efficiencyTier: tier,
      tierColor: color,
      advice: advice,
    );
  }

  static SolarCycleProgress calculateSolarCycle(WeatherData weather) {
    final now = DateTime.now();
    final forecast = weather.daily.isNotEmpty ? weather.daily.first : null;
    final sunriseStr = forecast?.sunrise ?? '06:00';
    final sunsetStr = forecast?.sunset ?? '18:00';

    double prog = 0.5;
    bool isDay = weather.isDay;
    String remaining = '0h 0m';
    String goldenStart = '17:00';
    String goldenEnd = '18:00';

    try {
      final riseParts = sunriseStr.split(':').map(int.parse).toList();
      final setParts = sunsetStr.split(':').map(int.parse).toList();

      final nowMin = now.hour * 60 + now.minute;
      final riseMin = riseParts[0] * 60 + riseParts[1];
      final setMin = setParts[0] * 60 + setParts[1];

      final goldenStartMin = setMin - 60;
      goldenStart = '${(goldenStartMin ~/ 60).toString().padLeft(2, '0')}:${(goldenStartMin % 60).toString().padLeft(2, '0')}';
      goldenEnd = sunsetStr;

      if (nowMin < riseMin) {
        prog = 0.0;
        isDay = false;
        final diff = riseMin - nowMin;
        remaining = '${diff ~/ 60}h ${diff % 60}m until dawn';
      } else if (nowMin > setMin) {
        prog = 1.0;
        isDay = false;
        remaining = 'Nightfall (Sun below horizon)';
      } else {
        prog = (nowMin - riseMin) / math.max(1, setMin - riseMin);
        isDay = true;
        final leftMin = setMin - nowMin;
        remaining = '${leftMin ~/ 60}h ${leftMin % 60}m daylight remaining';
      }
    } catch (_) {
      prog = isDay ? 0.5 : 0.0;
    }

    return SolarCycleProgress(
      progress: prog.clamp(0.0, 1.0),
      isDaytime: isDay,
      sunrise: sunriseStr,
      sunset: sunsetStr,
      remainingDaylight: remaining,
      goldenHourStart: goldenStart,
      goldenHourEnd: goldenEnd,
    );
  }
}

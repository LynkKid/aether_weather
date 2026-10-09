import 'package:flutter/material.dart';
import 'package:aether_weather/core/atmospheric_theme.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class WeatherHeroCard extends StatelessWidget {
  final WeatherData weather;
  final String formattedTemp;
  final String formattedFeelsLike;
  final String formattedWind;
  final AtmosphericTheme atmosphericTheme;
  final VoidCallback? onOpenAlerts;

  const WeatherHeroCard({
    super.key,
    required this.weather,
    required this.formattedTemp,
    required this.formattedFeelsLike,
    required this.formattedWind,
    required this.atmosphericTheme,
    this.onOpenAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;
    final textColor = atmosphericTheme.textColor;
    final subtextColor = atmosphericTheme.subtitleColor;
    final hasAlerts = weather.severeAlerts.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: atmosphericTheme.cardBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: atmosphericTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // City header and badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      weather.city.isCurrentLocation
                          ? Icons.near_me_rounded
                          : Icons.location_on_rounded,
                      size: 16,
                      color: atmosphericTheme.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        weather.city.country.isNotEmpty
                            ? '${weather.city.name}, ${weather.city.country}'
                            : weather.city.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      size: 12,
                      color: weather.isDay ? Colors.amber : Colors.indigoAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      weather.isDay ? 'DAY' : 'NIGHT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Active Severe Alert Banner inside hero if any
          if (hasAlerts) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onOpenAlerts,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x33DC2626),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x66DC2626)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        weather.severeAlerts.first.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFCA5A5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFFCA5A5)),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Center Temperature & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                weather.conditionIcon,
                size: 72,
                color: atmosphericTheme.accentColor,
              ),
              const SizedBox(width: 14),
              Text(
                formattedTemp,
                style: TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -3,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            weather.conditionText,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(height: 8),

          // High / Low and Feels Like
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (today != null) ...[
                Text(
                  'H: ${today.maxTemp.round()}°  L: ${today.minTemp.round()}°',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text('•', style: TextStyle(color: subtextColor)),
                const SizedBox(width: 12),
              ],
              Text(
                'Feels like $formattedFeelsLike',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

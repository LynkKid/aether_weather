import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class AirQualityCard extends StatelessWidget {
  final AirQuality airQuality;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const AirQualityCard({
    super.key,
    required this.airQuality,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality.aqi;
    final color = airQuality.statusColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.grain_rounded, size: 16, color: color),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'AIR QUALITY INDEX',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  airQuality.category,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$aqi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'US AQI',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // AQI bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (aqi / 300.0).clamp(0.05, 1.0),
              backgroundColor: Colors.white.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          // Pollutants breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PollutantItem(label: 'PM2.5', value: '${airQuality.pm25.toStringAsFixed(1)} µg/m³', subtitleColor: subtitleColor, textColor: textColor),
              _PollutantItem(label: 'PM10', value: '${airQuality.pm10.toStringAsFixed(1)} µg/m³', subtitleColor: subtitleColor, textColor: textColor),
              _PollutantItem(label: 'NO₂', value: '${airQuality.no2.toStringAsFixed(1)} ppb', subtitleColor: subtitleColor, textColor: textColor),
              _PollutantItem(label: 'O₃', value: '${airQuality.o3.toStringAsFixed(1)} ppb', subtitleColor: subtitleColor, textColor: textColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _PollutantItem extends StatelessWidget {
  final String label;
  final String value;
  final Color subtitleColor;
  final Color textColor;

  const _PollutantItem({
    required this.label,
    required this.value,
    required this.subtitleColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: subtitleColor)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
      ],
    );
  }
}

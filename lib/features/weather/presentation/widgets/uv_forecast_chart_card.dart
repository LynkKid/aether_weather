import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class UvForecastChartCard extends StatelessWidget {
  final double currentUv;
  final List<DailyForecast> daily;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const UvForecastChartCard({
    super.key,
    required this.currentUv,
    required this.daily,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  Color _getUvColor(double uv) {
    if (uv <= 2) return const Color(0xFF10B981); // Low
    if (uv <= 5) return const Color(0xFFFBBF24); // Moderate
    if (uv <= 7) return const Color(0xFFF97316); // High
    if (uv <= 10) return const Color(0xFFEF4444); // Very High
    return const Color(0xFF8B5CF6); // Extreme
  }

  String _getUvLabel(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  @override
  Widget build(BuildContext context) {
    final days = daily.take(7).toList();

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
                    const Icon(Icons.wb_sunny_rounded, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '7-DAY PEAK UV FORECAST',
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
                  color: _getUvColor(currentUv).withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current: ${currentUv.toStringAsFixed(1)} · ${_getUvLabel(currentUv)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getUvColor(currentUv),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 7-day UV Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final uv = d.uvIndexMax;
              final barHeight = ((uv / 12.0) * 60).clamp(6.0, 60.0);
              final col = _getUvColor(uv);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    uv.toStringAsFixed(0),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 14,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: col,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.dayLabel.substring(0, d.dayLabel.length >= 3 ? 3 : d.dayLabel.length),
                    style: TextStyle(fontSize: 10, color: subtitleColor),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            currentUv >= 6 ? 'Midday protection required: wear SPF 50 & seek shade.' : 'Minimal danger for average exposure times.',
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

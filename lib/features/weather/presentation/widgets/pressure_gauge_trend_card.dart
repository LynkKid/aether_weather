import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class PressureGaugeTrendCard extends StatelessWidget {
  final double currentPressure;
  final List<PressureTrendPoint> pressureHistory;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const PressureGaugeTrendCard({
    super.key,
    required this.currentPressure,
    required this.pressureHistory,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  String _getTrend() {
    if (pressureHistory.length < 2) return 'Steady Barometer';
    final diff = currentPressure - pressureHistory.last.pressure;
    if (diff > 1.5) return 'Rising Rapidly (+${diff.toStringAsFixed(1)} hPa)';
    if (diff < -1.5) return 'Falling (Front Approaching)';
    return 'Stable Atmospheric System';
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = currentPressure >= 1013.25;

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
                    const Icon(Icons.speed_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'ATMOSPHERIC PRESSURE',
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
                  color: isHigh ? const Color(0x3310B981) : const Color(0x33F97316),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isHigh ? 'High Pressure' : 'Low Depression',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isHigh ? const Color(0xFF10B981) : const Color(0xFFF97316),
                  ),
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
                '${currentPressure.round()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'hPa',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getTrend(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 12),
          // Micro history bar representation
          if (pressureHistory.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: pressureHistory.map((p) {
                return Column(
                  children: [
                    Text(
                      '${p.pressure.round()}',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.hourLabel,
                      style: TextStyle(fontSize: 9, color: subtitleColor),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

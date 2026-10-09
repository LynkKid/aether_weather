import 'dart:math' as math;
import 'package:flutter/material.dart';

class WindCompassCard extends StatelessWidget {
  final double windSpeed;
  final double windGusts;
  final int windDirection;
  final String formattedSpeed;
  final String formattedGusts;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const WindCompassCard({
    super.key,
    required this.windSpeed,
    required this.windGusts,
    required this.windDirection,
    required this.formattedSpeed,
    required this.formattedGusts,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  String _getWindDirectionName(int deg) {
    const dirs = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final idx = ((deg % 360) / 22.5).round() % 16;
    return dirs[idx];
  }

  @override
  Widget build(BuildContext context) {
    final cardinal = _getWindDirectionName(windDirection);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.air_rounded, size: 16, color: Color(0xFF38BDF8)),
              const SizedBox(width: 6),
              Text(
                'WIND & GUSTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedSpeed,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gusts to $formattedGusts',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
              // Rotating Compass Dial
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(50),
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 3,
                      child: Text(
                        'N',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: (windDirection * math.pi) / 180.0,
                      child: const Icon(
                        Icons.navigation_rounded,
                        size: 24,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Heading: $cardinal ($windDirection°)',
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

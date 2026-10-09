import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:aether_weather/core/calculators/solar_calculator.dart';

class SolarCycleCard extends StatelessWidget {
  final SolarCycleProgress cycle;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const SolarCycleCard({
    super.key,
    required this.cycle,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.wb_twilight_rounded, size: 16, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'SOLAR CYCLE & DAYLIGHT',
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
              Text(
                cycle.remainingDaylight,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sun Arc Graphic
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunArcPainter(progress: cycle.progress, isDaytime: cycle.isDaytime),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sunrise', style: TextStyle(fontSize: 10, color: subtitleColor)),
                  const SizedBox(height: 1),
                  Text(cycle.sunrise, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              Column(
                children: [
                  Text('Golden Hour', style: TextStyle(fontSize: 10, color: subtitleColor)),
                  const SizedBox(height: 1),
                  Text('${cycle.goldenHourStart} - ${cycle.goldenHourEnd}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sunset', style: TextStyle(fontSize: 10, color: subtitleColor)),
                  const SizedBox(height: 1),
                  Text(cycle.sunset, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final bool isDaytime;

  _SunArcPainter({required this.progress, required this.isDaytime});

  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = Rect.fromLTWH(20, 6, size.width - 40, (size.height - 10) * 2);

    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(arcRect, math.pi, math.pi, false, dashPaint);

    // Active path
    if (isDaytime && progress > 0) {
      final activePaint = Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawArc(arcRect, math.pi, math.pi * progress, false, activePaint);

      // Sun dot
      final angle = math.pi + (math.pi * progress);
      final rx = (size.width - 40) / 2;
      final ry = size.height - 10;
      final cx = size.width / 2;
      final cy = size.height - 4;

      final sunX = cx + rx * math.cos(angle);
      final sunY = cy + ry * math.sin(angle);

      final glowPaint = Paint()..color = const Color(0x66FBBF24);
      final sunPaint = Paint()..color = const Color(0xFFFBBF24);

      canvas.drawCircle(Offset(sunX, sunY), 9, glowPaint);
      canvas.drawCircle(Offset(sunX, sunY), 5, sunPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) => true;
}

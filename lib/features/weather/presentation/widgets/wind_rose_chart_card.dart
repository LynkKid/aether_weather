import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class WindRoseChartCard extends StatelessWidget {
  final WeatherData weather;
  final String formattedWind;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const WindRoseChartCard({
    super.key,
    required this.weather,
    required this.formattedWind,
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
                    const Icon(Icons.explore_rounded, size: 16, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'WIND VECTOR DISTRIBUTION',
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
                'Direction: ${weather.windDirection}°',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _WindRosePainter(
                activeDegrees: weather.windDirection.toDouble(),
                windSpeed: weather.windSpeed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindRosePainter extends CustomPainter {
  final double activeDegrees;
  final double windSpeed;

  _WindRosePainter({required this.activeDegrees, required this.windSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = math.min(cx, cy) - 14;

    final circlePaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Range concentric rings
    canvas.drawCircle(Offset(cx, cy), maxR * 0.35, circlePaint);
    canvas.drawCircle(Offset(cx, cy), maxR * 0.7, circlePaint);
    canvas.drawCircle(Offset(cx, cy), maxR, circlePaint);

    // 8 Cardinal spokes
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 8; i++) {
      final rad = (i * 45 - 90) * math.pi / 180.0;
      final x2 = cx + maxR * math.cos(rad);
      final y2 = cy + maxR * math.sin(rad);

      canvas.drawLine(Offset(cx, cy), Offset(x2, y2), circlePaint);

      // Label
      final lx = cx + (maxR + 10) * math.cos(rad);
      final ly = cy + (maxR + 10) * math.sin(rad);

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white54),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(lx - textPainter.width / 2, ly - textPainter.height / 2),
      );
    }

    // Active wind vector petal
    final activeRad = (activeDegrees - 90) * math.pi / 180.0;
    final vectorLen = (maxR * (windSpeed / 50.0).clamp(0.2, 1.0));
    final vx = cx + vectorLen * math.cos(activeRad);
    final vy = cy + vectorLen * math.sin(activeRad);

    final vectorPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy), Offset(vx, vy), vectorPaint);

    final dotPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(Offset(vx, vy), 5, dotPaint);
    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _WindRosePainter oldDelegate) => true;
}

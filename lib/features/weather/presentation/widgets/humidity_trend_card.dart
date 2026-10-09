import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class HumidityTrendCard extends StatelessWidget {
  final int currentHumidity;
  final double dewPoint;
  final List<HourlyForecast> hourly;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const HumidityTrendCard({
    super.key,
    required this.currentHumidity,
    required this.dewPoint,
    required this.hourly,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  String _getComfortLevel(int h) {
    if (h < 30) return 'Dry Atmospheric Baseline';
    if (h <= 60) return 'Comfortable Relative Moisture';
    if (h <= 80) return 'Humid: Sticky & Dense';
    return 'Very Humid: High Saturation';
  }

  @override
  Widget build(BuildContext context) {
    final points = hourly.take(24).toList();

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
                    const Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFF06B6D4)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '24H HUMIDITY & MOISTURE',
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
                'Dew Pt: ${dewPoint.round()}°',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currentHumidity%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getComfortLevel(currentHumidity),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF06B6D4),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: _HumidityCurvePainter(
                values: points.map((e) => e.humidity.toDouble()).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HumidityCurvePainter extends CustomPainter {
  final List<double> values;

  _HumidityCurvePainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final stepX = size.width / (values.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final norm = (values[i] / 100.0).clamp(0.0, 1.0);
      final x = i * stepX;
      final y = size.height - (norm * (size.height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNorm = (values[i - 1] / 100.0).clamp(0.0, 1.0);
        final prevY = size.height - (prevNorm * (size.height - 8)) - 4;

        final cx = (prevX + x) / 2;
        path.cubicTo(cx, prevY, cx, y, x, y);
        fillPath.cubicTo(cx, prevY, cx, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x6606B6D4), Color(0x000284C7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _HumidityCurvePainter oldDelegate) => true;
}

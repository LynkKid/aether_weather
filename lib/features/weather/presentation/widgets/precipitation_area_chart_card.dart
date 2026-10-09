import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class PrecipitationAreaChartCard extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const PrecipitationAreaChartCard({
    super.key,
    required this.hourly,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final points = hourly.take(24).toList();
    if (points.isEmpty) return const SizedBox.shrink();

    int maxProb = 0;
    String maxHour = 'Now';
    for (final p in points) {
      if (p.precipitationProbability > maxProb) {
        maxProb = p.precipitationProbability;
        maxHour = p.hourLabel;
      }
    }

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
                    const Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFF22D3EE)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'PRECIPITATION PROBABILITY',
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
                maxProb > 0 ? 'Peak: $maxProb% ($maxHour)' : '0% · Dry',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22D3EE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _PrecipChartPainter(
                data: points.map((e) => e.precipitationProbability.toDouble()).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0% Dry Baseline', style: TextStyle(fontSize: 10, color: subtitleColor)),
              Text('50% Showers', style: TextStyle(fontSize: 10, color: subtitleColor)),
              Text('100% Torrential', style: TextStyle(fontSize: 10, color: subtitleColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrecipChartPainter extends CustomPainter {
  final List<double> data;

  _PrecipChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paintLine = Paint()
      ..color = const Color(0xFF22D3EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final norm = (data[i] / 100.0).clamp(0.0, 1.0);
      final x = i * stepX;
      final y = size.height - (norm * (size.height - 12)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNorm = (data[i - 1] / 100.0).clamp(0.0, 1.0);
        final prevY = size.height - (prevNorm * (size.height - 12)) - 4;

        final cx = (prevX + x) / 2;
        path.cubicTo(cx, prevY, cx, y, x, y);
        fillPath.cubicTo(cx, prevY, cx, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x8006B6D4), Color(0x003B82F6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paintLine);

    // Draw peak dot if max > 0
    double maxVal = 0;
    int maxIdx = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] > maxVal) {
        maxVal = data[i];
        maxIdx = i;
      }
    }

    if (maxVal > 0) {
      final peakX = maxIdx * stepX;
      final peakY = size.height - ((maxVal / 100.0) * (size.height - 12)) - 4;

      final dotPaint = Paint()..color = const Color(0xFF67E8F9);
      final glowPaint = Paint()..color = const Color(0x6606B6D4);

      canvas.drawCircle(Offset(peakX, peakY), 6, glowPaint);
      canvas.drawCircle(Offset(peakX, peakY), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PrecipChartPainter oldDelegate) => true;
}

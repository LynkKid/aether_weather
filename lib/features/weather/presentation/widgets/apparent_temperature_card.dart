import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class ApparentTemperatureCard extends StatelessWidget {
  final double currentTemp;
  final double currentFeelsLike;
  final List<HourlyForecast> hourly;
  final bool isFahrenheit;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const ApparentTemperatureCard({
    super.key,
    required this.currentTemp,
    required this.currentFeelsLike,
    required this.hourly,
    required this.isFahrenheit,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  String _format(double c) {
    if (isFahrenheit) {
      return '${((c * 9 / 5) + 32).round()}°';
    }
    return '${c.round()}°';
  }

  @override
  Widget build(BuildContext context) {
    final diff = currentFeelsLike - currentTemp;
    final diffStr = diff.abs() < 0.5
        ? 'Equal to actual air temp'
        : diff > 0
            ? 'Feels +${diff.toStringAsFixed(1)}° warmer (Heat Index effect)'
            : 'Feels ${diff.toStringAsFixed(1)}° colder (Wind Chill effect)';

    final points = hourly.take(16).toList();

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
                    const Icon(Icons.thermostat_rounded, size: 16, color: Color(0xFFF97316)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'AIR TEMP VS FEELS LIKE',
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
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF38BDF8), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Air', style: TextStyle(fontSize: 10, color: subtitleColor)),
                  const SizedBox(width: 8),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF97316), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Feels', style: TextStyle(fontSize: 10, color: subtitleColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _format(currentFeelsLike),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Actual: ${_format(currentTemp)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            diffStr,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF97316),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 75,
            width: double.infinity,
            child: CustomPaint(
              painter: _DualTempChartPainter(
                temps: points.map((e) => e.temperature).toList(),
                feels: points.map((e) => e.feelsLike).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DualTempChartPainter extends CustomPainter {
  final List<double> temps;
  final List<double> feels;

  _DualTempChartPainter({required this.temps, required this.feels});

  @override
  void paint(Canvas canvas, Size size) {
    if (temps.length < 2) return;

    double minVal = 100.0;
    double maxVal = -100.0;

    for (final v in [...temps, ...feels]) {
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    final range = math.max(2.0, maxVal - minVal);
    final stepX = size.width / (temps.length - 1);

    final pathTemp = Path();
    final pathFeels = Path();

    for (int i = 0; i < temps.length; i++) {
      final x = i * stepX;
      final normT = (temps[i] - minVal) / range;
      final yT = size.height - (normT * (size.height - 12)) - 6;

      final normF = (feels[i] - minVal) / range;
      final yF = size.height - (normF * (size.height - 12)) - 6;

      if (i == 0) {
        pathTemp.moveTo(x, yT);
        pathFeels.moveTo(x, yF);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNormT = (temps[i - 1] - minVal) / range;
        final prevYT = size.height - (prevNormT * (size.height - 12)) - 6;

        final prevNormF = (feels[i - 1] - minVal) / range;
        final prevYF = size.height - (prevNormF * (size.height - 12)) - 6;

        final cx = (prevX + x) / 2;
        pathTemp.cubicTo(cx, prevYT, cx, yT, x, yT);
        pathFeels.cubicTo(cx, prevYF, cx, yF, x, yF);
      }
    }

    final paintT = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintF = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(pathTemp, paintT);
    canvas.drawPath(pathFeels, paintF);
  }

  @override
  bool shouldRepaint(covariant _DualTempChartPainter oldDelegate) => true;
}

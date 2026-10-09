import 'package:flutter/material.dart';
import 'package:aether_weather/core/calculators/climate_calculator.dart';

class ClimateComparisonCard extends StatelessWidget {
  final ClimateSummary climate;
  final bool isFahrenheit;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const ClimateComparisonCard({
    super.key,
    required this.climate,
    required this.isFahrenheit,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  String _formatDiff(double c) {
    final val = isFahrenheit ? c * 1.8 : c;
    final prefix = val > 0 ? '+' : '';
    return '$prefix${val.toStringAsFixed(1)}°${isFahrenheit ? 'F' : 'C'}';
  }

  @override
  Widget build(BuildContext context) {
    final isWarmer = climate.currentMonthTempAnomaly >= 0;

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
                    const Icon(Icons.public_rounded, size: 16, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '30-YEAR CLIMATE NORMALS',
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
                  color: const Color(0x3338BDF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  climate.classificationCode,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDiff(climate.currentMonthTempAnomaly),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isWarmer ? const Color(0xFFF97316) : const Color(0xFF38BDF8),
                    ),
                  ),
                  Text(
                    '${climate.currentMonthName} Temp Anomaly',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${climate.currentMonthPrecipAnomalyPct >= 0 ? '+' : ''}${climate.currentMonthPrecipAnomalyPct}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF22D3EE),
                    ),
                  ),
                  Text(
                    'Rainfall vs Baseline',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 12-month bar trend
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: climate.data.map((m) {
                final isCurr = m.isCurrentMonth;
                final barH = ((m.histTempC + 15) / 50.0 * 36).clamp(6.0, 36.0);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: barH,
                      decoration: BoxDecoration(
                        color: isCurr ? const Color(0xFFF97316) : Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.month[0],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isCurr ? FontWeight.bold : FontWeight.normal,
                        color: isCurr ? const Color(0xFFF97316) : subtitleColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

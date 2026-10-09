import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class AllergyForecastCard extends StatelessWidget {
  final AllergyForecast allergy;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const AllergyForecastCard({
    super.key,
    required this.allergy,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Very High':
        return const Color(0xFFEF4444);
      case 'High':
        return const Color(0xFFF97316);
      case 'Moderate':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallCol = _getRiskColor(allergy.overallRisk);

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
                    Icon(Icons.local_florist_rounded, size: 16, color: overallCol),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'ALLERGY & AIRBORNE POLLEN',
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
                  color: overallCol.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${allergy.overallRisk} Risk',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: overallCol),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Pollen Meters
          _PollenBar(item: allergy.grass, subtitleColor: subtitleColor, textColor: textColor),
          const SizedBox(height: 8),
          _PollenBar(item: allergy.tree, subtitleColor: subtitleColor, textColor: textColor),
          const SizedBox(height: 8),
          _PollenBar(item: allergy.weed, subtitleColor: subtitleColor, textColor: textColor),
          const SizedBox(height: 12),
          Text(
            allergy.advisory,
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

class _PollenBar extends StatelessWidget {
  final PollenItem item;
  final Color subtitleColor;
  final Color textColor;

  const _PollenBar({
    required this.item,
    required this.subtitleColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
            Row(
              children: [
                Text(
                  '${item.value.round()} / 100',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor),
                ),
                const SizedBox(width: 6),
                Text(
                  item.level,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.color),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (item.value / 100.0).clamp(0.05, 1.0),
            backgroundColor: Colors.white.withAlpha(20),
            valueColor: AlwaysStoppedAnimation<Color>(item.color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

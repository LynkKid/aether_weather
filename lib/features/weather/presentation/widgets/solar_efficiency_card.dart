import 'package:flutter/material.dart';
import 'package:aether_weather/core/calculators/solar_calculator.dart';

class SolarEfficiencyCard extends StatelessWidget {
  final SolarEfficiencyMetrics efficiency;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const SolarEfficiencyCard({
    super.key,
    required this.efficiency,
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
                    const Icon(Icons.solar_power_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'SOLAR PHOTOVOLTAIC HARVEST',
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
                  color: efficiency.tierColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  efficiency.efficiencyTier,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: efficiency.tierColor),
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
                    '${efficiency.efficiencyPct}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Efficiency Rating',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${efficiency.estimatedKw5kWArray} kW',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    '5kW Array Output',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: efficiency.efficiencyPct / 100.0,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(efficiency.tierColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Irradiance: ${efficiency.irradianceWm2} W/m²', style: TextStyle(fontSize: 10, color: subtitleColor)),
              Text('Cloud Loss: -${efficiency.cloudLossPct}%', style: TextStyle(fontSize: 10, color: subtitleColor)),
              Text('Sun Angle: ${efficiency.sunAngleDeg}°', style: TextStyle(fontSize: 10, color: subtitleColor)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            efficiency.advice,
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

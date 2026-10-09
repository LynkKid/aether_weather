import 'package:flutter/material.dart';
import 'package:aether_weather/core/calculators/moon_calculator.dart';

class MoonPhaseCard extends StatelessWidget {
  final MoonPhaseInfo moon;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const MoonPhaseCard({
    super.key,
    required this.moon,
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
                    const Icon(Icons.nightlight_round, size: 16, color: Color(0xFF818CF8)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'LUNAR PHASE & ILLUMINATION',
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
                moon.nextPhaseText,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF818CF8)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moon.phaseName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${moon.illumination}% Illumination · Age: ${moon.moonAgeDays}d',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
              // Moon graphic representation
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1E293B),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                    ),
                    Icon(
                      moon.stage == 'full'
                          ? Icons.circle
                          : moon.stage == 'new'
                              ? Icons.circle_outlined
                              : Icons.brightness_3_rounded,
                      size: 32,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

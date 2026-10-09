import 'package:flutter/material.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class NightModeCard extends StatelessWidget {
  final UserSettings settings;
  final VoidCallback onOpenSettings;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const NightModeCard({
    super.key,
    required this.settings,
    required this.onOpenSettings,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = settings.nightModeAutomation;

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
                    const Icon(Icons.bedtime_rounded, size: 16, color: Color(0xFFA855F7)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'NIGHT MODE SLEEP AUTOMATION',
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
                  color: enabled ? const Color(0x33A855F7) : Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  enabled ? 'Active Scheduled' : 'Disabled',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: enabled ? const Color(0xFFA855F7) : subtitleColor,
                  ),
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
                    '${settings.sleepStartTime} – ${settings.sleepEndTime}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sleep schedule · Auto-${settings.nightTheme.toUpperCase()} Black',
                    style: TextStyle(fontSize: 11, color: subtitleColor),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: onOpenSettings,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: BorderSide(color: cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Edit', style: TextStyle(fontSize: 11, color: textColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            settings.silenceNonCriticalSounds
                ? 'Non-critical alert audio is silenced during sleep. Emergency alerts remain audible.'
                : 'All notification sounds active during sleep hours.',
            style: TextStyle(fontSize: 11, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

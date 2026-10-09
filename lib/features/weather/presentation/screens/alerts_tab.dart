import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.weather;
    final atmTheme = weatherProvider.atmosphericTheme;
    final isDark = atmTheme.isDarkTheme;

    final alerts = weather?.severeAlerts ?? [];
    final history = weatherProvider.alertHistory;

    final cardBg = atmTheme.cardBg;
    final cardBorder = atmTheme.cardBorder;
    final textColor = atmTheme.textColor;
    final subtitleColor = atmTheme.subtitleColor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Test Push Dispatcher Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notification_important_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMERGENCY WARNING DISPATCHER',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Simulate Severe Weather Warnings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Test sirens, local notification banners, and emergency instructions across multiple severe weather scenarios.',
                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Simulation trigger chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSimChip(
                    context,
                    label: '🌪️ Tornado Warning',
                    onTap: () async {
                      await weatherProvider.triggerSimulatedAlert(
                        SevereAlert(
                          id: 'tornado_${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Tornado Vortex Warning',
                          area: weather?.city.name ?? 'Metropolitan Area',
                          severity: AlertSeverity.emergency,
                          description: 'Violent rotational tornado vortex confirmed on Doppler radar moving NE at 45 mph.',
                          instruction: 'Take shelter immediately in a reinforced basement room away from windows and exterior walls.',
                          issuedAt: DateTime.now(),
                          expiresAt: DateTime.now().add(const Duration(hours: 2)),
                          isExtreme: true,
                        ),
                      );
                    },
                  ),
                  _buildSimChip(
                    context,
                    label: '🌊 Flash Flood',
                    onTap: () async {
                      await weatherProvider.triggerSimulatedAlert(
                        SevereAlert(
                          id: 'flood_${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Flash Flood Emergency',
                          area: weather?.city.name ?? 'Valley Basin',
                          severity: AlertSeverity.warning,
                          description: 'Torrential convective rainfall exceeding 80mm/h. Rapid rising water threatening low ground.',
                          instruction: 'Move immediately to higher ground. Turn around, do not drown when encountering flooded roadways.',
                          issuedAt: DateTime.now(),
                          expiresAt: DateTime.now().add(const Duration(hours: 4)),
                          isExtreme: true,
                        ),
                      );
                    },
                  ),
                  _buildSimChip(
                    context,
                    label: '🔥 Heat Emergency',
                    onTap: () async {
                      await weatherProvider.triggerSimulatedAlert(
                        SevereAlert(
                          id: 'heat_${DateTime.now().millisecondsSinceEpoch}',
                          title: 'Extreme Heat Warning',
                          area: weather?.city.name ?? 'District Area',
                          severity: AlertSeverity.advisory,
                          description: 'Dangerous heat index values approaching 42°C. Elevated risk of heat stroke.',
                          instruction: 'Drink plenty of fluids, stay in air-conditioned spaces, and check on elderly neighbors.',
                          issuedAt: DateTime.now(),
                          expiresAt: DateTime.now().add(const Duration(hours: 6)),
                          isExtreme: false,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Active Alerts Section
        Row(
          children: [
            const Icon(Icons.crisis_alert_rounded, size: 20, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'ACTIVE WARNINGS (${alerts.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (alerts.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF10B981)),
                const SizedBox(height: 12),
                Text(
                  'No Active Severe Warnings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Atmospheric conditions are stable. Continuous satellite monitoring remains in effect.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
          ),
        ] else ...[
          ...alerts.map((alert) => _buildAlertCard(context, alert, isDark, cardBg, cardBorder, textColor, subtitleColor)),
        ],

        const SizedBox(height: 24),

        // Alert History Log
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 20, color: subtitleColor),
                const SizedBox(width: 8),
                Text(
                  'ALERT LOG & HISTORY (${history.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            if (history.isNotEmpty)
              TextButton(
                onPressed: () => weatherProvider.clearAlertHistory(),
                child: const Text('Clear Log', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Center(
              child: Text(
                'No recorded alerts in session history.',
                style: TextStyle(fontSize: 12, color: subtitleColor),
              ),
            ),
          )
        else
          ...history.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: a.badgeColor, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          Text('${a.area} · ${DateFormat('HH:mm').format(a.issuedAt)}', style: TextStyle(fontSize: 10, color: subtitleColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _buildSimChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: () {
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 $label dispatched!'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF991B1B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    SevereAlert alert,
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textColor,
    Color subtitleColor,
  ) {
    final dateFormat = DateFormat('MMM d, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: alert.badgeColor.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: alert.badgeColor.withAlpha(25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: alert.badgeColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alert.severity.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: alert.badgeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                'Expires ${dateFormat.format(alert.expiresAt)}',
                style: TextStyle(fontSize: 11, color: subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            alert.description,
            style: TextStyle(fontSize: 13, height: 1.4, color: textColor),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert.badgeColor.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_rounded, size: 18, color: alert.badgeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.instruction,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

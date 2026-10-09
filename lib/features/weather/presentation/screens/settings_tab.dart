import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/core/constants/app_constants.dart';
import 'package:aether_weather/core/theme/app_theme.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final settings = weatherProvider.settings;
    final atmTheme = weatherProvider.atmosphericTheme;

    final cardBg = atmTheme.cardBg;
    final cardBorder = atmTheme.cardBorder;
    final textColor = atmTheme.textColor;
    final subtitleColor = atmTheme.subtitleColor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Theme Selection Card
        _buildSectionHeader('DISPLAY & ATMOSPHERIC THEME', subtitleColor),
        _buildCard(
          cardBg: cardBg,
          cardBorder: cardBorder,
          child: Column(
            children: [
              _buildThemeOption(
                title: 'Deep Night Dark',
                subtitle: 'Twilight navy slate, reduced eye strain',
                selected: settings.themeMode == 'dark',
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => weatherProvider.setThemeMode(AppThemeMode.dark),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              _buildThemeOption(
                title: 'Pure OLED Midnight',
                subtitle: 'True black #000000 for maximum AMOLED battery savings',
                selected: settings.themeMode == 'oled',
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => weatherProvider.setThemeMode(AppThemeMode.oled),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              _buildThemeOption(
                title: 'Daylight Light',
                subtitle: 'Crisp sky blue with high outdoor contrast',
                selected: settings.themeMode == 'light',
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => weatherProvider.setThemeMode(AppThemeMode.light),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              _buildThemeOption(
                title: 'System Automatic',
                subtitle: 'Synchronize with operating system appearance',
                selected: settings.themeMode == 'system',
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () => weatherProvider.setThemeMode(AppThemeMode.system),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Night Mode Sleep Automation
        _buildSectionHeader('NIGHT MODE SLEEP AUTOMATION', subtitleColor),
        _buildCard(
          cardBg: cardBg,
          cardBorder: cardBorder,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Automate Night Theme during Sleep', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text(
                  'Switches to ${settings.nightTheme.toUpperCase()} automatically between sleep hours',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
                value: settings.nightModeAutomation,
                onChanged: (val) => weatherProvider.updateUserSettings(settings.copyWith(nightModeAutomation: val)),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Sleep Schedule Window', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text('Start: ${settings.sleepStartTime}  ·  End: ${settings.sleepEndTime}', style: TextStyle(fontSize: 12, color: subtitleColor)),
                trailing: TextButton(
                  onPressed: () async {
                    final start = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 22, minute: 0),
                    );
                    if (start != null && context.mounted) {
                      final end = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 7, minute: 0),
                      );
                      if (end != null) {
                        final sStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                        final eStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                        await weatherProvider.updateUserSettings(settings.copyWith(
                          sleepStartTime: sStr,
                          sleepEndTime: eStr,
                        ));
                      }
                    }
                  },
                  child: const Text('Change Hours'),
                ),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Silence Non-Critical Alert Sounds', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text(
                  'Only life-threatening extreme warnings bypass do-not-disturb',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
                value: settings.silenceNonCriticalSounds,
                onChanged: (val) => weatherProvider.updateUserSettings(settings.copyWith(silenceNonCriticalSounds: val)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Meteorological Units Card
        _buildSectionHeader('METEOROLOGICAL UNITS', subtitleColor),
        _buildCard(
          cardBg: cardBg,
          cardBorder: cardBorder,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Fahrenheit Scale (°F)', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text(
                  weatherProvider.isFahrenheit ? 'Currently displaying in Fahrenheit (°F)' : 'Currently displaying in Celsius (°C)',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
                value: weatherProvider.isFahrenheit,
                onChanged: (val) => weatherProvider.setTemperatureUnit(val),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Wind Speed Unit', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text('Current unit: ${settings.windUnit}', style: TextStyle(fontSize: 12, color: subtitleColor)),
                trailing: DropdownButton<String>(
                  value: settings.windUnit,
                  dropdownColor: cardBg,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'kmh', child: Text('km/h')),
                    DropdownMenuItem(value: 'mph', child: Text('mph')),
                    DropdownMenuItem(value: 'ms', child: Text('m/s')),
                  ],
                  onChanged: (val) {
                    if (val != null) weatherProvider.setWindUnit(val);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. Emergency Warnings & Push Configuration
        _buildSectionHeader('PUSH NOTIFICATIONS & SIRENS', subtitleColor),
        _buildCard(
          cardBg: cardBg,
          cardBorder: cardBorder,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Severe Weather Siren Alerts', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text(
                  'Local notifications for tornadic activity, hail, and flash floods',
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
                value: settings.notificationsEnabled,
                onChanged: (val) => weatherProvider.toggleNotifications(val),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Audio Siren Chimes', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text('Play loud alert tone on warning dispatch', style: TextStyle(fontSize: 12, color: subtitleColor)),
                value: settings.soundAlertsEnabled,
                onChanged: (val) => weatherProvider.updateUserSettings(settings.copyWith(soundAlertsEnabled: val)),
              ),
              Divider(height: 16, color: cardBorder.withAlpha(80)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Filter Extreme Emergencies Only', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text('Mute minor watch advisories', style: TextStyle(fontSize: 12, color: subtitleColor)),
                value: settings.extremeAlertsOnly,
                onChanged: (val) => weatherProvider.updateUserSettings(settings.copyWith(extremeAlertsOnly: val)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 5. Adaptive Telemetry Refresh
        _buildSectionHeader('ADAPTIVE TELEMETRY & BATTERY', subtitleColor),
        _buildCard(
          cardBg: cardBg,
          cardBorder: cardBorder,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Intelligent Volatility Polling', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
            subtitle: Text(
              'Polls every 5 minutes during storm activity; conserves battery during stable weather',
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
            value: settings.adaptiveRefresh,
            onChanged: (val) => weatherProvider.updateUserSettings(settings.copyWith(adaptiveRefresh: val)),
          ),
        ),
        const SizedBox(height: 24),

        // 6. System Telemetry & Attribution
        _buildSectionHeader('SYSTEM TELEMETRY & ATTRIBUTION', subtitleColor),
        _buildCard(
          cardBg: cardBg,
          cardBorder: cardBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.satellite_alt_rounded, color: Color(0xFF0284C7)),
                  const SizedBox(width: 10),
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Complete meteorological workstation suite with 18+ analytical cards, 30-year climate baselines, astronomical calculations, and Doppler radar.',
                style: TextStyle(fontSize: 13, height: 1.4, color: subtitleColor),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.public_rounded, size: 16, color: subtitleColor),
                  const SizedBox(width: 6),
                  Text(
                    'Data: Open-Meteo REST & Air Quality API',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subtitleColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    required Color cardBg,
    required Color cardBorder,
  }) {
    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required bool selected,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7), size: 22)
            else
              Icon(Icons.radio_button_unchecked_rounded, color: subtitleColor, size: 22),
          ],
        ),
      ),
    );
  }
}

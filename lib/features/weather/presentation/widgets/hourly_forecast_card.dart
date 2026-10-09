import 'package:flutter/material.dart';
import 'package:aether_weather/core/atmospheric_theme.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> hourly;
  final String Function(double) formatTemp;
  final AtmosphericTheme? atmosphericTheme;

  const HourlyForecastCard({
    super.key,
    required this.hourly,
    required this.formatTemp,
    this.atmosphericTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = atmosphericTheme?.cardBg ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    final cardBorder = atmosphericTheme?.cardBorder ?? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final textColor = atmosphericTheme?.textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    final subtitleColor = atmosphericTheme?.subtitleColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: subtitleColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '24-HOUR FORECAST SCRUBBER',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = hourly[index];
                final isCurrent = index == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? (atmosphericTheme?.accentColor.withAlpha(40) ?? Colors.blue.withAlpha(40))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isCurrent
                        ? Border.all(color: atmosphericTheme?.accentColor ?? Colors.blue)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.hourLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent ? (atmosphericTheme?.accentColor ?? Colors.blue) : subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        _getWeatherIcon(item.weatherCode),
                        size: 24,
                        color: _getWeatherColor(item.weatherCode, isDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatTemp(item.temperature),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      if (item.precipitationProbability > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${item.precipitationProbability}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22D3EE),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.blur_on_rounded;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.grain_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  Color _getWeatherColor(int code, bool isDark) {
    if ([95, 96, 99].contains(code)) return const Color(0xFFEF4444);
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return const Color(0xFF0284C7);
    if ([71, 73, 75, 77, 85, 86].contains(code)) return const Color(0xFF38BDF8);
    if ([0, 1].contains(code)) return const Color(0xFFF59E0B);
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }
}

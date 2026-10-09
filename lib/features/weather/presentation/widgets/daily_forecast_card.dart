import 'package:flutter/material.dart';
import 'package:aether_weather/core/atmospheric_theme.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> daily;
  final String Function(double) formatTemp;
  final AtmosphericTheme? atmosphericTheme;

  const DailyForecastCard({
    super.key,
    required this.daily,
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
              Icon(Icons.calendar_month_rounded, size: 16, color: subtitleColor),
              const SizedBox(width: 8),
              Text(
                '7-DAY SYNOPTIC FORECAST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, index) => Divider(
              color: cardBorder.withAlpha(80),
              height: 18,
            ),
            itemBuilder: (context, index) {
              final item = daily[index];
              return Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      item.dayLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getWeatherIcon(item.weatherCode),
                    size: 22,
                    color: _getWeatherColor(item.weatherCode, isDark),
                  ),
                  const SizedBox(width: 8),
                  if (item.precipitationProbability > 10) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.precipitationProbability}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 32),
                  ],
                  const Spacer(),
                  Text(
                    formatTemp(item.minTemp),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Temperature Range bar
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ((item.maxTemp - item.minTemp) / 15.0).clamp(0.2, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFFF59E0B)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      formatTemp(item.maxTemp),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              );
            },
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

import 'package:flutter/material.dart';
import 'package:aether_weather/core/calculators/moon_calculator.dart';

class LunarCalendarCard extends StatelessWidget {
  final List<CalendarMoonDay> days;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const LunarCalendarCard({
    super.key,
    required this.days,
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
                    const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF818CF8)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '30-DAY LUNAR CYCLE CALENDAR',
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
                'Next 30 Days',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 30-day horizontal scroll or wrap
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final d = days[index];
                return Container(
                  width: 44,
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: d.isToday
                        ? const Color(0x33818CF8)
                        : Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: d.isToday
                          ? const Color(0xFF818CF8)
                          : (d.isMajorMilestone
                              ? const Color(0x66FBBF24)
                              : Colors.transparent),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        d.dayOfWeek,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: d.isToday ? const Color(0xFF818CF8) : subtitleColor,
                        ),
                      ),
                      Icon(
                        d.moon.stage == 'full'
                            ? Icons.circle
                            : d.moon.stage == 'new'
                                ? Icons.circle_outlined
                                : Icons.brightness_3_rounded,
                        size: 14,
                        color: d.isMajorMilestone
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFE2E8F0),
                      ),
                      Text(
                        '${d.dayOfMonth}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
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
}

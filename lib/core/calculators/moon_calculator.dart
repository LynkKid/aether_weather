import 'dart:math' as math;

class MoonPhaseInfo {
  final String phaseName;
  final double phaseNormalized; // 0 to 1
  final int illumination; // 0 to 100 percentage
  final double moonAgeDays; // 0 to 29.53
  final String nextPhaseText;
  final String stage;

  const MoonPhaseInfo({
    required this.phaseName,
    required this.phaseNormalized,
    required this.illumination,
    required this.moonAgeDays,
    required this.nextPhaseText,
    required this.stage,
  });
}

class CalendarMoonDay {
  final DateTime date;
  final String dateStr;
  final int dayOfMonth;
  final String dayOfWeek;
  final bool isToday;
  final MoonPhaseInfo moon;
  final bool isMajorMilestone;
  final String? milestoneTitle;

  const CalendarMoonDay({
    required this.date,
    required this.dateStr,
    required this.dayOfMonth,
    required this.dayOfWeek,
    required this.isToday,
    required this.moon,
    required this.isMajorMilestone,
    this.milestoneTitle,
  });
}

class MoonCalculator {
  static const double lunarMonth = 29.53058770576; // days in average synodic month

  // Known reference New Moon epoch: 2000-01-06 18:14 UTC
  static final int knownNewMoonEpoch =
      DateTime.utc(2000, 1, 6, 18, 14).millisecondsSinceEpoch;

  static MoonPhaseInfo calculateMoonPhase([DateTime? targetDate]) {
    final date = targetDate ?? DateTime.now();
    final diffMs = date.millisecondsSinceEpoch - knownNewMoonEpoch;
    final diffDays = diffMs / (1000 * 60 * 60 * 24);

    final moonAge = ((diffDays % lunarMonth) + lunarMonth) % lunarMonth;
    final normalized = moonAge / lunarMonth;

    final illumination =
        (((1 - math.cos(normalized * 2 * math.pi)) / 2) * 100).round();

    String phaseName;
    String stage;
    String nextPhaseText;

    if (normalized < 0.03 || normalized >= 0.97) {
      phaseName = 'New Moon';
      stage = 'new';
      final daysToFirstQ =
          (((0.25 - (normalized >= 0.97 ? normalized - 1 : normalized)) *
                      lunarMonth) *
                  10)
              .round() /
              10;
      nextPhaseText = 'First Quarter in ${daysToFirstQ}d';
    } else if (normalized < 0.22) {
      phaseName = 'Waxing Crescent';
      stage = 'waxing_crescent';
      final daysToFirstQ =
          (((0.25 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'First Quarter in ${daysToFirstQ}d';
    } else if (normalized < 0.28) {
      phaseName = 'First Quarter';
      stage = 'first_quarter';
      final daysToFull = (((0.5 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'Full Moon in ${daysToFull}d';
    } else if (normalized < 0.47) {
      phaseName = 'Waxing Gibbous';
      stage = 'waxing_gibbous';
      final daysToFull = (((0.5 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'Full Moon in ${daysToFull}d';
    } else if (normalized < 0.53) {
      phaseName = 'Full Moon';
      stage = 'full';
      final daysToLastQ =
          (((0.75 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'Last Quarter in ${daysToLastQ}d';
    } else if (normalized < 0.72) {
      phaseName = 'Waning Gibbous';
      stage = 'waning_gibbous';
      final daysToLastQ =
          (((0.75 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'Last Quarter in ${daysToLastQ}d';
    } else if (normalized < 0.78) {
      phaseName = 'Last Quarter';
      stage = 'last_quarter';
      final daysToNew = (((1.0 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'New Moon in ${daysToNew}d';
    } else {
      phaseName = 'Waning Crescent';
      stage = 'waning_crescent';
      final daysToNew = (((1.0 - normalized) * lunarMonth) * 10).round() / 10;
      nextPhaseText = 'New Moon in ${daysToNew}d';
    }

    return MoonPhaseInfo(
      phaseName: phaseName,
      phaseNormalized: (normalized * 1000).round() / 1000,
      illumination: illumination,
      moonAgeDays: (moonAge * 10).round() / 10,
      nextPhaseText: nextPhaseText,
      stage: stage,
    );
  }

  static List<CalendarMoonDay> get30DayLunarCalendar([DateTime? start]) {
    final startDate = start ?? DateTime.now();
    final days = <CalendarMoonDay>[];
    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    for (int i = 0; i < 30; i++) {
      final d = startDate.add(Duration(days: i));
      final moon = calculateMoonPhase(d);

      bool isMajor = false;
      String? milestone;

      if (moon.stage == 'new' && moon.phaseNormalized < 0.04) {
        isMajor = true;
        milestone = 'New Moon';
      } else if (moon.stage == 'first_quarter' &&
          (moon.phaseNormalized - 0.25).abs() < 0.03) {
        isMajor = true;
        milestone = 'First Qtr';
      } else if (moon.stage == 'full' &&
          (moon.phaseNormalized - 0.5).abs() < 0.03) {
        isMajor = true;
        milestone = 'Full Moon';
      } else if (moon.stage == 'last_quarter' &&
          (moon.phaseNormalized - 0.75).abs() < 0.03) {
        isMajor = true;
        milestone = 'Last Qtr';
      }

      days.add(CalendarMoonDay(
        date: d,
        dateStr: '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        dayOfMonth: d.day,
        dayOfWeek: daysOfWeek[d.weekday % 7],
        isToday: i == 0,
        moon: moon,
        isMajorMilestone: isMajor,
        milestoneTitle: milestone,
      ));
    }

    return days;
  }
}

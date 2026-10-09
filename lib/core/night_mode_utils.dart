class NightModeUtils {
  static bool isCurrentlyInSleepHours(String startTime, String endTime, [DateTime? testNow]) {
    final now = testNow ?? DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    try {
      final startParts = startTime.split(':').map(int.parse).toList();
      final endParts = endTime.split(':').map(int.parse).toList();

      final startMin = startParts[0] * 60 + startParts[1];
      final endMin = endParts[0] * 60 + endParts[1];

      if (startMin > endMin) {
        // Over midnight, e.g., 22:00 to 07:00
        return nowMin >= startMin || nowMin < endMin;
      } else {
        // Same day, e.g., 13:00 to 15:00
        return nowMin >= startMin && nowMin < endMin;
      }
    } catch (_) {
      return false;
    }
  }

  static bool shouldPlayAlertAudio({
    required String severity, // 'emergency', 'warning', 'watch', 'advisory'
    required bool soundAlertsEnabled,
    required bool nightModeAutomation,
    required bool silenceNonCriticalSounds,
    required String sleepStartTime,
    required String sleepEndTime,
  }) {
    if (!soundAlertsEnabled) return false;

    final inSleep = nightModeAutomation &&
        isCurrentlyInSleepHours(sleepStartTime, sleepEndTime);

    if (inSleep) {
      if (silenceNonCriticalSounds) {
        // Only wake for emergency / extreme life-threatening events
        return severity == 'emergency' || severity == 'extreme';
      }
    }

    return true;
  }
}

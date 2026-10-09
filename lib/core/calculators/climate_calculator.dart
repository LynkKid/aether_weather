import 'dart:math' as math;
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';

class MonthlyClimatePoint {
  final String month;
  final int monthIdx;
  final bool isCurrentMonth;
  final double histTempC;
  final double currTempC;
  final double tempDiffC;
  final double histPrecipMm;
  final double currPrecipMm;
  final double precipDiffMm;

  const MonthlyClimatePoint({
    required this.month,
    required this.monthIdx,
    required this.isCurrentMonth,
    required this.histTempC,
    required this.currTempC,
    required this.tempDiffC,
    required this.histPrecipMm,
    required this.currPrecipMm,
    required this.precipDiffMm,
  });
}

class ClimateSummary {
  final String climateClassification;
  final String classificationCode;
  final String currentMonthName;
  final double currentMonthTempAnomaly;
  final int currentMonthPrecipAnomalyPct;
  final double annualMeanTemp;
  final double annualPrecipTotalMm;
  final List<MonthlyClimatePoint> data;

  const ClimateSummary({
    required this.climateClassification,
    required this.classificationCode,
    required this.currentMonthName,
    required this.currentMonthTempAnomaly,
    required this.currentMonthPrecipAnomalyPct,
    required this.annualMeanTemp,
    required this.annualPrecipTotalMm,
    required this.data,
  });
}

class ClimateCalculator {
  static const List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static ClimateSummary getClimateComparison(
    CityLocation location, [
    double? currentTempC,
  ]) {
    final lat = location.latitude;
    final lon = location.longitude;
    final isNorthern = lat >= 0;
    final absLat = lat.abs();
    final currentMonthIdx = DateTime.now().month - 1; // 0 to 11

    String classificationCode = 'Cfb';
    String climateClassification = 'Temperate Oceanic';

    if (absLat < 12) {
      classificationCode = 'Af';
      climateClassification = 'Tropical Rainforest';
    } else if (absLat < 23.5) {
      classificationCode = 'Aw';
      climateClassification = 'Tropical Wet & Dry';
    } else if (absLat < 35) {
      if (lon.abs() < 20 || (lon > 100 && lon < 140)) {
        classificationCode = 'Cfa';
        climateClassification = 'Humid Subtropical';
      } else {
        classificationCode = 'Csa';
        climateClassification = 'Mediterranean';
      }
    } else if (absLat < 55) {
      if (lon.abs() < 20) {
        classificationCode = 'Cfb';
        climateClassification = 'Marine West Coast';
      } else {
        classificationCode = 'Dfb';
        climateClassification = 'Humid Continental';
      }
    } else {
      classificationCode = 'Dfc';
      climateClassification = 'Subarctic Continental';
    }

    final annualBaseTempC = math.max(
        -12.0,
        math.min(28.0,
            28.0 - (absLat * 0.58) + (math.sin(lon * 0.05) * 1.5)));

    final tempAmplitude =
        absLat < 10 ? 2.5 : absLat < 25 ? 6.0 : absLat < 45 ? 12.0 : 18.0;

    final warmPeakMonth = isNorthern ? 6 : 0;

    final data = <MonthlyClimatePoint>[];
    double totalAnnualPrecip = 0;
    double totalAnnualTemp = 0;

    for (int m = 0; m < 12; m++) {
      final phase = ((m - warmPeakMonth) / 12.0) * 2.0 * math.pi;
      final seasonalTempFactor = math.cos(phase);
      final histTemp = ((annualBaseTempC + (seasonalTempFactor * tempAmplitude)) * 10).round() / 10.0;

      final isSummer = isNorthern ? (m >= 4 && m <= 8) : (m < 2 || m >= 10);
      final isMonsoon = absLat < 25 && isSummer;
      final basePrecip = isMonsoon
          ? 160.0
          : absLat < 12
              ? 210.0
              : 65.0 + math.sin(phase) * 25.0;
      final histPrecip = (basePrecip * 10).round() / 10.0;

      totalAnnualPrecip += histPrecip;
      totalAnnualTemp += histTemp;

      final isCurrent = m == currentMonthIdx;
      double currTemp = histTemp;
      if (isCurrent && currentTempC != null) {
        currTemp = (currentTempC * 10).round() / 10.0;
      } else {
        final mockWarming = 0.6 + (math.sin(m * 0.9) * 0.5);
        currTemp = ((histTemp + mockWarming) * 10).round() / 10.0;
      }

      final currPrecip = ((histPrecip * (0.92 + (math.cos(m * 1.1) * 0.18))) * 10).round() / 10.0;

      data.add(MonthlyClimatePoint(
        month: monthNames[m],
        monthIdx: m,
        isCurrentMonth: isCurrent,
        histTempC: histTemp,
        currTempC: currTemp,
        tempDiffC: ((currTemp - histTemp) * 10).round() / 10.0,
        histPrecipMm: histPrecip,
        currPrecipMm: currPrecip,
        precipDiffMm: ((currPrecip - histPrecip) * 10).round() / 10.0,
      ));
    }

    final currMonthData = data[currentMonthIdx];
    final precipRatio = currMonthData.histPrecipMm > 0
        ? ((currMonthData.currPrecipMm / currMonthData.histPrecipMm) * 100).round() - 100
        : 0;

    return ClimateSummary(
      climateClassification: climateClassification,
      classificationCode: classificationCode,
      currentMonthName: monthNames[currentMonthIdx],
      currentMonthTempAnomaly: currMonthData.tempDiffC,
      currentMonthPrecipAnomalyPct: precipRatio,
      annualMeanTemp: ((totalAnnualTemp / 12.0) * 10).round() / 10.0,
      annualPrecipTotalMm: (totalAnnualPrecip * 10).round() / 10.0,
      data: data,
    );
  }
}

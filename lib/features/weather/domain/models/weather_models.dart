import 'dart:convert';
import 'package:flutter/material.dart';

enum AlertSeverity {
  advisory,
  watch,
  warning,
  emergency,
}

class SevereAlert {
  final String id;
  final String title;
  final String area;
  final AlertSeverity severity;
  final String description;
  final String instruction;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool isExtreme;

  const SevereAlert({
    required this.id,
    required this.title,
    required this.area,
    required this.severity,
    required this.description,
    required this.instruction,
    required this.issuedAt,
    required this.expiresAt,
    this.isExtreme = false,
  });

  Color get badgeColor => switch (severity) {
        AlertSeverity.emergency => const Color(0xFFDC2626),
        AlertSeverity.warning => const Color(0xFFEA580C),
        AlertSeverity.watch => const Color(0xFFD97706),
        AlertSeverity.advisory => const Color(0xFF2563EB),
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'area': area,
        'severity': severity.name,
        'description': description,
        'instruction': instruction,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isExtreme': isExtreme,
      };

  factory SevereAlert.fromJson(Map<String, dynamic> json) => SevereAlert(
        id: json['id'] as String,
        title: json['title'] as String,
        area: json['area'] as String,
        severity: AlertSeverity.values.firstWhere(
          (e) => e.name == json['severity'],
          orElse: () => AlertSeverity.advisory,
        ),
        description: json['description'] as String,
        instruction: json['instruction'] as String,
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        isExtreme: json['isExtreme'] as bool? ?? false,
      );
}

class CityLocation {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final bool isCurrentLocation;
  final bool isFavorite;

  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isCurrentLocation = false,
    this.isFavorite = false,
  });

  CityLocation copyWith({
    String? name,
    String? country,
    double? latitude,
    double? longitude,
    bool? isCurrentLocation,
    bool? isFavorite,
  }) {
    return CityLocation(
      name: name ?? this.name,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'isCurrentLocation': isCurrentLocation,
        'isFavorite': isFavorite,
      };

  factory CityLocation.fromJson(Map<String, dynamic> json) => CityLocation(
        name: json['name'] as String,
        country: json['country'] as String? ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        isCurrentLocation: json['isCurrentLocation'] as bool? ?? false,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityLocation &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(name, latitude, longitude);
}

class HourlyForecast {
  final DateTime time;
  final String hourLabel;
  final double temperature;
  final double feelsLike;
  final int precipitationProbability;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final int humidity;
  final double dewPoint;
  final double pressure;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.hourLabel,
    required this.temperature,
    required this.feelsLike,
    required this.precipitationProbability,
    required this.weatherCode,
    this.windSpeed = 10.0,
    this.windDirection = 180,
    this.windGusts = 15.0,
    this.humidity = 60,
    this.dewPoint = 15.0,
    this.pressure = 1013.25,
    this.isDay = true,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'hourLabel': hourLabel,
        'temperature': temperature,
        'feelsLike': feelsLike,
        'precipitationProbability': precipitationProbability,
        'weatherCode': weatherCode,
        'windSpeed': windSpeed,
        'windDirection': windDirection,
        'windGusts': windGusts,
        'humidity': humidity,
        'dewPoint': dewPoint,
        'pressure': pressure,
        'isDay': isDay,
      };

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => HourlyForecast(
        time: DateTime.parse(json['time'] as String),
        hourLabel: json['hourLabel'] as String,
        temperature: (json['temperature'] as num).toDouble(),
        feelsLike: (json['feelsLike'] as num).toDouble(),
        precipitationProbability: (json['precipitationProbability'] as num).toInt(),
        weatherCode: (json['weatherCode'] as num).toInt(),
        windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 10.0,
        windDirection: (json['windDirection'] as num?)?.toInt() ?? 180,
        windGusts: (json['windGusts'] as num?)?.toDouble() ?? 15.0,
        humidity: (json['humidity'] as num?)?.toInt() ?? 60,
        dewPoint: (json['dewPoint'] as num?)?.toDouble() ?? 15.0,
        pressure: (json['pressure'] as num?)?.toDouble() ?? 1013.25,
        isDay: json['isDay'] as bool? ?? true,
      );
}

class DailyForecast {
  final DateTime date;
  final String dayLabel;
  final double maxTemp;
  final double minTemp;
  final int precipitationProbability;
  final int weatherCode;
  final double precipitationSum;
  final String sunrise;
  final String sunset;
  final double uvIndexMax;

  const DailyForecast({
    required this.date,
    required this.dayLabel,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
    required this.weatherCode,
    this.precipitationSum = 0.0,
    this.sunrise = '06:00',
    this.sunset = '18:00',
    this.uvIndexMax = 5.0,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'dayLabel': dayLabel,
        'maxTemp': maxTemp,
        'minTemp': minTemp,
        'precipitationProbability': precipitationProbability,
        'weatherCode': weatherCode,
        'precipitationSum': precipitationSum,
        'sunrise': sunrise,
        'sunset': sunset,
        'uvIndexMax': uvIndexMax,
      };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: DateTime.parse(json['date'] as String),
        dayLabel: json['dayLabel'] as String,
        maxTemp: (json['maxTemp'] as num).toDouble(),
        minTemp: (json['minTemp'] as num).toDouble(),
        precipitationProbability: (json['precipitationProbability'] as num).toInt(),
        weatherCode: (json['weatherCode'] as num).toInt(),
        precipitationSum: (json['precipitationSum'] as num?)?.toDouble() ?? 0.0,
        sunrise: json['sunrise'] as String? ?? '06:00',
        sunset: json['sunset'] as String? ?? '18:00',
        uvIndexMax: (json['uvIndexMax'] as num?)?.toDouble() ?? 5.0,
      );
}

class PressureTrendPoint {
  final DateTime time;
  final String hourLabel;
  final double pressure;

  const PressureTrendPoint({
    required this.time,
    required this.hourLabel,
    required this.pressure,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'hourLabel': hourLabel,
        'pressure': pressure,
      };

  factory PressureTrendPoint.fromJson(Map<String, dynamic> json) =>
      PressureTrendPoint(
        time: DateTime.parse(json['time'] as String),
        hourLabel: json['hourLabel'] as String,
        pressure: (json['pressure'] as num).toDouble(),
      );
}

class AirQuality {
  final int aqi;
  final String category;
  final double pm25;
  final double pm10;
  final double no2;
  final double o3;

  const AirQuality({
    required this.aqi,
    required this.category,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.o3,
  });

  Color get statusColor {
    if (aqi <= 50) return const Color(0xFF10B981); // Good
    if (aqi <= 100) return const Color(0xFFF59E0B); // Moderate
    if (aqi <= 150) return const Color(0xFFF97316); // Unhealthy for Sensitive
    if (aqi <= 200) return const Color(0xFFEF4444); // Unhealthy
    if (aqi <= 300) return const Color(0xFF8B5CF6); // Very Unhealthy
    return const Color(0xFF7F1D1D); // Hazardous
  }

  Map<String, dynamic> toJson() => {
        'aqi': aqi,
        'category': category,
        'pm25': pm25,
        'pm10': pm10,
        'no2': no2,
        'o3': o3,
      };

  factory AirQuality.fromJson(Map<String, dynamic> json) => AirQuality(
        aqi: (json['aqi'] as num?)?.toInt() ?? 35,
        category: json['category'] as String? ?? 'Good',
        pm25: (json['pm25'] as num?)?.toDouble() ?? 8.5,
        pm10: (json['pm10'] as num?)?.toDouble() ?? 15.0,
        no2: (json['no2'] as num?)?.toDouble() ?? 12.0,
        o3: (json['o3'] as num?)?.toDouble() ?? 25.0,
      );
}

class PollenItem {
  final String type;
  final String name;
  final double value; // 0 to 100
  final String level; // Low, Moderate, High, Very High
  final Color color;

  const PollenItem({
    required this.type,
    required this.name,
    required this.value,
    required this.level,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'value': value,
        'level': level,
        'color': color.toARGB32(),
      };

  factory PollenItem.fromJson(Map<String, dynamic> json) => PollenItem(
        type: json['type'] as String,
        name: json['name'] as String,
        value: (json['value'] as num).toDouble(),
        level: json['level'] as String,
        color: Color(json['color'] as int? ?? 0xFF10B981),
      );
}

class AllergyForecast {
  final PollenItem grass;
  final PollenItem tree;
  final PollenItem weed;
  final String overallRisk;
  final String primaryAllergen;
  final String advisory;

  const AllergyForecast({
    required this.grass,
    required this.tree,
    required this.weed,
    required this.overallRisk,
    required this.primaryAllergen,
    required this.advisory,
  });

  Map<String, dynamic> toJson() => {
        'grass': grass.toJson(),
        'tree': tree.toJson(),
        'weed': weed.toJson(),
        'overallRisk': overallRisk,
        'primaryAllergen': primaryAllergen,
        'advisory': advisory,
      };

  factory AllergyForecast.fromJson(Map<String, dynamic> json) =>
      AllergyForecast(
        grass: PollenItem.fromJson(json['grass'] as Map<String, dynamic>),
        tree: PollenItem.fromJson(json['tree'] as Map<String, dynamic>),
        weed: PollenItem.fromJson(json['weed'] as Map<String, dynamic>),
        overallRisk: json['overallRisk'] as String? ?? 'Moderate',
        primaryAllergen: json['primaryAllergen'] as String? ?? 'Weed Pollen',
        advisory: json['advisory'] as String? ?? 'Pollen levels are moderate.',
      );
}

class WeatherData {
  final CityLocation city;
  final double temperature;
  final double feelsLike;
  final int weatherCode;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final double pressure;
  final double uvIndex;
  final double visibility;
  final double dewPoint;
  final int cloudCover;
  final bool isDay;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final List<SevereAlert> severeAlerts;
  final AirQuality airQuality;
  final AllergyForecast allergy;
  final List<PressureTrendPoint> pressureHistory;
  final DateTime fetchedAt;

  const WeatherData({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    this.windGusts = 15.0,
    required this.pressure,
    required this.uvIndex,
    required this.visibility,
    required this.dewPoint,
    this.cloudCover = 20,
    this.isDay = true,
    required this.hourly,
    required this.daily,
    required this.severeAlerts,
    required this.airQuality,
    required this.allergy,
    required this.pressureHistory,
    required this.fetchedAt,
  });

  String get conditionText {
    switch (weatherCode) {
      case 0:
        return isDay ? 'Sunny' : 'Clear Sky';
      case 1:
        return isDay ? 'Mainly Clear' : 'Mostly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy Mist';
      case 51:
      case 53:
      case 55:
        return 'Light Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
        return 'Light Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rainstorm';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
        return 'Light Snowfall';
      case 73:
        return 'Moderate Snow';
      case 75:
        return 'Heavy Snow Blizzard';
      case 77:
        return 'Snow Grains';
      case 80:
      case 81:
      case 82:
        return 'Violent Rain Showers';
      case 85:
      case 86:
        return 'Heavy Snow Showers';
      case 95:
        return 'Severe Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Partly Cloudy';
    }
  }

  IconData get conditionIcon {
    switch (weatherCode) {
      case 0:
        return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      case 1:
      case 2:
        return isDay ? Icons.wb_cloudy_rounded : Icons.cloud_outlined;
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

  bool get isSevere =>
      [95, 96, 99].contains(weatherCode) ||
      windSpeed >= 60 ||
      severeAlerts.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'city': city.toJson(),
        'temperature': temperature,
        'feelsLike': feelsLike,
        'weatherCode': weatherCode,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'windDirection': windDirection,
        'windGusts': windGusts,
        'pressure': pressure,
        'uvIndex': uvIndex,
        'visibility': visibility,
        'dewPoint': dewPoint,
        'cloudCover': cloudCover,
        'isDay': isDay,
        'hourly': hourly.map((e) => e.toJson()).toList(),
        'daily': daily.map((e) => e.toJson()).toList(),
        'severeAlerts': severeAlerts.map((e) => e.toJson()).toList(),
        'airQuality': airQuality.toJson(),
        'allergy': allergy.toJson(),
        'pressureHistory': pressureHistory.map((e) => e.toJson()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
        city: CityLocation.fromJson(json['city'] as Map<String, dynamic>),
        temperature: (json['temperature'] as num).toDouble(),
        feelsLike: (json['feelsLike'] as num).toDouble(),
        weatherCode: (json['weatherCode'] as num).toInt(),
        humidity: (json['humidity'] as num).toInt(),
        windSpeed: (json['windSpeed'] as num).toDouble(),
        windDirection: (json['windDirection'] as num).toInt(),
        windGusts: (json['windGusts'] as num?)?.toDouble() ?? 15.0,
        pressure: (json['pressure'] as num).toDouble(),
        uvIndex: (json['uvIndex'] as num).toDouble(),
        visibility: (json['visibility'] as num).toDouble(),
        dewPoint: (json['dewPoint'] as num).toDouble(),
        cloudCover: (json['cloudCover'] as num?)?.toInt() ?? 25,
        isDay: json['isDay'] as bool? ?? true,
        hourly: (json['hourly'] as List<dynamic>)
            .map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        daily: (json['daily'] as List<dynamic>)
            .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        severeAlerts: (json['severeAlerts'] as List<dynamic>)
            .map((e) => SevereAlert.fromJson(e as Map<String, dynamic>))
            .toList(),
        airQuality: json['airQuality'] != null
            ? AirQuality.fromJson(json['airQuality'] as Map<String, dynamic>)
            : const AirQuality(
                aqi: 35,
                category: 'Good',
                pm25: 8.5,
                pm10: 15.0,
                no2: 12.0,
                o3: 25.0,
              ),
        allergy: json['allergy'] != null
            ? AllergyForecast.fromJson(json['allergy'] as Map<String, dynamic>)
            : const AllergyForecast(
                grass: PollenItem(
                    type: 'grass',
                    name: 'Grass Pollen',
                    value: 25,
                    level: 'Low',
                    color: Color(0xFF10B981)),
                tree: PollenItem(
                    type: 'tree',
                    name: 'Tree Pollen',
                    value: 40,
                    level: 'Moderate',
                    color: Color(0xFF38BDF8)),
                weed: PollenItem(
                    type: 'weed',
                    name: 'Weed Pollen',
                    value: 65,
                    level: 'High',
                    color: Color(0xFFF97316)),
                overallRisk: 'Moderate',
                primaryAllergen: 'Weed Pollen',
                advisory: 'Pollen counts are moderate; sensitive groups take care.',
              ),
        pressureHistory: (json['pressureHistory'] as List<dynamic>?)
                ?.map((e) =>
                    PressureTrendPoint.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      );

  String toRawJson() => json.encode(toJson());
  static WeatherData fromRawJson(String str) =>
      WeatherData.fromJson(json.decode(str) as Map<String, dynamic>);
}

class UserSettings {
  final String themeMode; // 'dark', 'light', 'oled', 'system'
  final String tempUnit; // 'C', 'F'
  final String windUnit; // 'kmh', 'mph', 'ms'
  final bool notificationsEnabled;
  final bool soundAlertsEnabled;
  final bool extremeAlertsOnly;
  final bool nightModeAutomation;
  final String sleepStartTime; // "22:00"
  final String sleepEndTime; // "07:00"
  final String nightTheme; // 'oled', 'dark'
  final bool silenceNonCriticalSounds;
  final bool adaptiveRefresh;

  const UserSettings({
    this.themeMode = 'dark',
    this.tempUnit = 'C',
    this.windUnit = 'kmh',
    this.notificationsEnabled = true,
    this.soundAlertsEnabled = true,
    this.extremeAlertsOnly = false,
    this.nightModeAutomation = true,
    this.sleepStartTime = '22:00',
    this.sleepEndTime = '07:00',
    this.nightTheme = 'oled',
    this.silenceNonCriticalSounds = true,
    this.adaptiveRefresh = true,
  });

  UserSettings copyWith({
    String? themeMode,
    String? tempUnit,
    String? windUnit,
    bool? notificationsEnabled,
    bool? soundAlertsEnabled,
    bool? extremeAlertsOnly,
    bool? nightModeAutomation,
    String? sleepStartTime,
    String? sleepEndTime,
    String? nightTheme,
    bool? silenceNonCriticalSounds,
    bool? adaptiveRefresh,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      tempUnit: tempUnit ?? this.tempUnit,
      windUnit: windUnit ?? this.windUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundAlertsEnabled: soundAlertsEnabled ?? this.soundAlertsEnabled,
      extremeAlertsOnly: extremeAlertsOnly ?? this.extremeAlertsOnly,
      nightModeAutomation: nightModeAutomation ?? this.nightModeAutomation,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      sleepEndTime: sleepEndTime ?? this.sleepEndTime,
      nightTheme: nightTheme ?? this.nightTheme,
      silenceNonCriticalSounds:
          silenceNonCriticalSounds ?? this.silenceNonCriticalSounds,
      adaptiveRefresh: adaptiveRefresh ?? this.adaptiveRefresh,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'tempUnit': tempUnit,
        'windUnit': windUnit,
        'notificationsEnabled': notificationsEnabled,
        'soundAlertsEnabled': soundAlertsEnabled,
        'extremeAlertsOnly': extremeAlertsOnly,
        'nightModeAutomation': nightModeAutomation,
        'sleepStartTime': sleepStartTime,
        'sleepEndTime': sleepEndTime,
        'nightTheme': nightTheme,
        'silenceNonCriticalSounds': silenceNonCriticalSounds,
        'adaptiveRefresh': adaptiveRefresh,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        themeMode: json['themeMode'] as String? ?? 'dark',
        tempUnit: json['tempUnit'] as String? ?? 'C',
        windUnit: json['windUnit'] as String? ?? 'kmh',
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        soundAlertsEnabled: json['soundAlertsEnabled'] as bool? ?? true,
        extremeAlertsOnly: json['extremeAlertsOnly'] as bool? ?? false,
        nightModeAutomation: json['nightModeAutomation'] as bool? ?? true,
        sleepStartTime: json['sleepStartTime'] as String? ?? '22:00',
        sleepEndTime: json['sleepEndTime'] as String? ?? '07:00',
        nightTheme: json['nightTheme'] as String? ?? 'oled',
        silenceNonCriticalSounds:
            json['silenceNonCriticalSounds'] as bool? ?? true,
        adaptiveRefresh: json['adaptiveRefresh'] as bool? ?? true,
      );
}

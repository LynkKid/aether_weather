import 'dart:async';
import 'package:flutter/material.dart';

enum WeatherLayerType {
  precip,
  temp,
  clouds,
}

class LayerTelemetryData {
  final double precipCurrentMm;
  final int precipProbability;
  final double tempCurrent;
  final double tempApparent;
  final double tempMin;
  final double tempMax;
  final int cloudCoverTotal;
  final int cloudCoverLow;
  final int cloudCoverHigh;
  final double windSpeed;
  final int windDirection;
  final List<double> hourlyPrecip;
  final List<double> hourlyTemp;
  final List<int> hourlyClouds;
  final String lastFetched;

  const LayerTelemetryData({
    required this.precipCurrentMm,
    required this.precipProbability,
    required this.tempCurrent,
    required this.tempApparent,
    required this.tempMin,
    required this.tempMax,
    required this.cloudCoverTotal,
    required this.cloudCoverLow,
    required this.cloudCoverHigh,
    required this.windSpeed,
    required this.windDirection,
    required this.hourlyPrecip,
    required this.hourlyTemp,
    required this.hourlyClouds,
    required this.lastFetched,
  });

  static const defaultTelemetry = LayerTelemetryData(
    precipCurrentMm: 1.2,
    precipProbability: 45,
    tempCurrent: 28.0,
    tempApparent: 31.0,
    tempMin: 24.0,
    tempMax: 33.0,
    cloudCoverTotal: 65,
    cloudCoverLow: 40,
    cloudCoverHigh: 75,
    windSpeed: 14.0,
    windDirection: 210,
    hourlyPrecip: [0.2, 0.5, 0.8, 1.2, 0.6, 0.3],
    hourlyTemp: [27.0, 28.0, 28.5, 29.0, 28.0, 27.0],
    hourlyClouds: [50, 58, 65, 70, 68, 60],
    lastFetched: 'Live Telemetry Active',
  );
}

class RadarProvider with ChangeNotifier {
  static const List<String> timeLabels = [
    '-90m',
    '-60m',
    '-30m',
    'LIVE NOW',
    '+30m',
    '+60m',
  ];

  bool _isPlaying = true;
  int _timeIndex = 3; // Index 3 is 'LIVE NOW'
  WeatherLayerType _activeLayer = WeatherLayerType.precip;
  double _zoomLevel = 1.0;
  LayerTelemetryData _telemetry = LayerTelemetryData.defaultTelemetry;
  Timer? _timer;

  RadarProvider() {
    _startAnimation();
  }

  bool get isPlaying => _isPlaying;
  int get timeIndex => _timeIndex;
  WeatherLayerType get activeLayer => _activeLayer;
  double get zoomLevel => _zoomLevel;
  LayerTelemetryData get telemetry => _telemetry;

  void _startAnimation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (_isPlaying) {
        _timeIndex = (_timeIndex + 1) % timeLabels.length;
        notifyListeners();
      }
    });
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setTimeIndex(int index) {
    _timeIndex = index.clamp(0, timeLabels.length - 1);
    notifyListeners();
  }

  void setActiveLayer(WeatherLayerType layer) {
    _activeLayer = layer;
    notifyListeners();
  }

  void zoomIn() {
    _zoomLevel = (_zoomLevel + 0.25).clamp(0.75, 2.5);
    notifyListeners();
  }

  void zoomOut() {
    _zoomLevel = (_zoomLevel - 0.25).clamp(0.75, 2.5);
    notifyListeners();
  }

  void updateTelemetryFromWeather({
    required double currentPrecip,
    required int rainProb,
    required double temp,
    required double feelsLike,
    required double minTemp,
    required double maxTemp,
    required int cloudCover,
    required double windSpeed,
    required int windDirection,
    required List<double> hourlyPrecip,
    required List<double> hourlyTemp,
  }) {
    _telemetry = LayerTelemetryData(
      precipCurrentMm: currentPrecip,
      precipProbability: rainProb,
      tempCurrent: temp,
      tempApparent: feelsLike,
      tempMin: minTemp,
      tempMax: maxTemp,
      cloudCoverTotal: cloudCover,
      cloudCoverLow: (cloudCover * 0.6).round(),
      cloudCoverHigh: (cloudCover * 0.9).round().clamp(0, 100),
      windSpeed: windSpeed,
      windDirection: windDirection,
      hourlyPrecip: hourlyPrecip.length >= 6
          ? hourlyPrecip.sublist(0, 6)
          : [0.2, 0.4, 0.8, 1.2, 0.6, 0.2],
      hourlyTemp: hourlyTemp.length >= 6
          ? hourlyTemp.sublist(0, 6)
          : [temp - 1, temp, temp, temp + 1, temp, temp - 1],
      hourlyClouds: [cloudCover - 10, cloudCover - 5, cloudCover, cloudCover + 5, cloudCover, cloudCover - 5]
          .map((e) => e.clamp(0, 100))
          .toList(),
      lastFetched: 'Live Synchronized Station',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

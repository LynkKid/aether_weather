import 'package:geolocator/geolocator.dart';
import 'package:aether_weather/core/constants/app_constants.dart';
import 'package:aether_weather/core/logging/app_logger.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final bool isFallback;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.isFallback = false,
    this.errorMessage,
  });
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<LocationResult> getCurrentCoordinates() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.instance.warning('Location services are disabled by user.');
        return const LocationResult(
          latitude: AppConstants.defaultLat,
          longitude: AppConstants.defaultLon,
          isFallback: true,
          errorMessage: 'Location services are disabled on device.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.instance.warning('Location permission denied.');
          return const LocationResult(
            latitude: AppConstants.defaultLat,
            longitude: AppConstants.defaultLon,
            isFallback: true,
            errorMessage: 'Location permission denied.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.instance.warning('Location permission permanently denied.');
        return const LocationResult(
          latitude: AppConstants.defaultLat,
          longitude: AppConstants.defaultLon,
          isFallback: true,
          errorMessage: 'Location permission permanently denied.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      AppLogger.instance.info(
        'Obtained real location: lat=${position.latitude}, lon=${position.longitude}',
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isFallback: false,
      );
    } catch (e, stack) {
      AppLogger.instance.error('Error fetching GPS coordinates', e, stack);
      return LocationResult(
        latitude: AppConstants.defaultLat,
        longitude: AppConstants.defaultLon,
        isFallback: true,
        errorMessage: e.toString(),
      );
    }
  }
}

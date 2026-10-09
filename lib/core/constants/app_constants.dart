class AppConstants {
  AppConstants._();

  static const String appName = 'Aether Weather';
  static const String appVersion = '1.0.0';

  // API Endpoints (Open-Meteo Open Data - No API Key required)
  static const String weatherApiBaseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingApiBaseUrl = 'https://geocoding-api.open-meteo.com/v1';

  // Storage Keys
  static const String keySavedCities = 'aether_saved_cities';
  static const String keyLastSelectedCity = 'aether_last_selected_city';
  static const String keyTempUnit = 'aether_temp_unit'; // 'c' or 'f'
  static const String keyThemeMode = 'aether_theme_mode'; // 'system', 'light', 'dark', 'oled'
  static const String keyWeatherCache = 'aether_weather_cache';
  static const String keyAlertsEnabled = 'aether_alerts_enabled';

  // Notification Channels
  static const String severeAlertChannelId = 'aether_severe_weather';
  static const String severeAlertChannelName = 'Severe Weather Warnings';
  static const String severeAlertChannelDesc =
      'Emergency notifications for severe meteorological and convective threats';

  // Default Coordinates (Tokyo as fallback standard)
  static const double defaultLat = 35.6762;
  static const double defaultLon = 139.6503;
  static const String defaultCityName = 'Tokyo';
  static const String defaultCountry = 'Japan';
}

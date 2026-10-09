# 🌦️ Aether Weather — Flutter Forecast & Severe Alerts

A production-ready Flutter weather forecast application with clean modern Material 3 design, dynamic theme engine (Light, Dark, and Pure OLED Midnight), real-time Doppler radar simulation, city search, and urgent severe meteorological push alerts.

> **Target Platforms**: Android & iOS only.

---

## 🚀 Key Features

1. **Synoptic & Real-Time Forecast**:
   - Live temperature, feels-like index, weather conditions, humidity, atmospheric pressure, visibility, and wind dynamics.
   - 24-Hour horizontal timeline with precipitation probabilities.
   - 7-Day outlook with min/max thermal indicator gradient bars.
   - Atmospheric Telemetry Grid: UV index, Wind Heading/Gusts, Humidity & Dew Point, Barometric pressure trends.

2. **Severe Meteorological Alerts System**:
   - Convective storm and tornado alert banner with priority badges (Emergency, Warning, Watch, Advisory).
   - Local push notifications powered by `flutter_local_notifications` for life-safety warnings.
   - Emergency Siren & Test Warning Dispatcher to verify siren alert readiness.

3. **Interactive Doppler Radar Simulation**:
   - Custom animated radar sweep canvas with concentric range rings and crosshairs.
   - Real-time simulated convective supercells with dBZ intensity gradients.
   - Layer switcher: Precipitation (dBZ), Wind Streamlines, and Severe Storm Cells.
   - Time scrubber and playback controls.

4. **Location Intelligence & City Management**:
   - Real-time GPS location via `geolocator` with automatic fallback to major weather stations.
   - Global city search powered by Open-Meteo Geocoding API.
   - Favorite cities list with offline persistence via `shared_preferences`.

5. **Display & Unit Customization**:
   - 4 Theme modes: System Default, Daylight Light, Deep Night Dark, Pure OLED Midnight (#000000).
   - Dual Unit Modes: Celsius (°C) / Fahrenheit (°F) and Metric (km/h) / Imperial (mph).

---

## 🏗️ Architecture & Technology Stack

The project strictly follows **Clean Architecture (Feature-First)** and Senior Flutter standards:

- **State Management**: `provider` (ChangeNotifier)
- **Networking**: `http` (Open-Meteo Open API - no API key needed)
- **Local Persistence & Offline Cache**: `shared_preferences`
- **Geolocation**: `geolocator`
- **Notifications**: `flutter_local_notifications`
- **Linter & Code Quality**: `flutter_lints` with strict enterprise rules (0 errors, 0 warnings)
- **Testing**: `flutter_test` suite with Unit & Widget tests

```
lib/
├── core/
│   ├── constants/       # AppConstants & API endpoints
│   ├── errors/          # AppFailure sealed classes
│   ├── logging/         # AppLogger with PII masking
│   ├── services/        # NotificationService & LocationService
│   └── theme/           # Material 3 Light, Dark, and OLED themes
├── features/
│   └── weather/
│       ├── data/repositories/       # WeatherRepository (Open-Meteo & Cache)
│       ├── domain/models/           # WeatherData, SevereAlert, CityLocation
│       └── presentation/
│           ├── providers/           # WeatherProvider & RadarProvider
│           ├── screens/             # MainNavigationScreen & 5 Tabs
│           └── widgets/             # WeatherHeroCard, Hourly/Daily, Radar canvas
└── main.dart
```

---

## 📱 How to Run

### Prerequisites
- Flutter SDK (≥ 3.0.0, tested with Flutter 3.44.4 / Dart 3.12.2)
- Xcode (for iOS)
- Android Studio / Android SDK (for Android)

### Running the App

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run tests**:
   ```bash
   flutter test
   ```

3. **Run on Android**:
   ```bash
   flutter run -d android
   ```

4. **Run on iOS**:
   ```bash
   flutter run -d ios
   ```
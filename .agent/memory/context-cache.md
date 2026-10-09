# ⚡ CONTEXT CACHE: TÓM TẮT NGỮ CẢNH CÁC MODULE PHỨC TẠP

> **HƯỚNG DẪN CHO AGENT**:
> Khi làm việc với một module hoặc tra cứu phụ thuộc, Agent **ĐỌC FILE NÀY TRƯỚC** thay vì quét toàn bộ `lib/features/`.
> Mỗi khi hoàn thành một module độ phức tạp **trung bình đến cao**, Agent có trách nhiệm ghi tóm tắt (10–15 dòng) theo mẫu bên dưới.

---

## 🗄️ DANH MỤC CACHE HIỆN TẠI

### Feature: Weather & Severe Alerts
- **Mức độ phức tạp**: Cao
- **Thực thể cốt lõi**:
  - `WeatherData`: chứa `temperature`, `feelsLike`, `weatherCode`, `humidity`, `windSpeed`, `windDirection`, `pressure`, `uvIndex`, `visibility`, `dewPoint`, `hourly: List<HourlyForecast>`, `daily: List<DailyForecast>`, `severeAlerts: List<SevereAlert>`.
  - `CityLocation`: `name`, `country`, `latitude`, `longitude`, `isCurrentLocation`, `isFavorite`.
  - `SevereAlert`: `id`, `title`, `area`, `severity`, `description`, `instruction`, `issuedAt`, `expiresAt`, `isExtreme`.
- **Lưu trữ cục bộ**: `shared_preferences` với key prefix `aether_weather_cache_<city>`, `aether_saved_cities`, `aether_last_selected_city`.
- **Endpoints API**:
  - Forecast: `https://api.open-meteo.com/v1/forecast?latitude=...&longitude=...`
  - Geocoding: `https://geocoding-api.open-meteo.com/v1/search?name=...`
- **State Manager & State**:
  - `WeatherProvider`: Quản lý nạp thời tiết, chuyển đổi đơn vị (°C/°F, km/h/mph), đổi theme, tìm kiếm thành phố, kích hoạt siren test.
  - `RadarProvider`: Quản lý hoạt cảnh radar doppler 6 frames, layer selection (Precipitation, Wind, Severe Cells).
- **Logic đặc thù / Xử lý ngoại lệ**:
  - Tự động phát hiện mã thời tiết cực đoan (WMO 95, 96, 99) hoặc gió giật ≥ 60km/h để tạo `SevereAlert` và bắn push notification qua `NotificationService`.
  - Fallback thông minh sang cache cục bộ khi mất kết nối mạng.
- **Phụ thuộc quan trọng**:
  - `NotificationService` (flutter_local_notifications)
  - `LocationService` (geolocator)

# 🏛️ NHẬT KÝ QUYẾT ĐỊNH KIẾN TRÚC (ARCHITECTURE DECISION RECORDS — ADR)

> Tài liệu này lưu các quyết định kiến trúc cốt lõi **của dự án hiện tại**. Agent đọc file này trước để hiểu bối cảnh mà không cần quét toàn bộ codebase.
> Khi copy bộ dùng chung vào dự án mới: bắt đầu bằng **ADR-001** ghi lại lựa chọn stack (đối chiếu `PROJECT_STACK.md`).

---

## 📌 ADR-001: Lựa chọn Stack Công nghệ của Dự án
- **Ngày quyết định**: 2026-10-09
- **Trạng thái**: ĐÃ DUYỆT (ACCEPTED)
- **Bối cảnh**: Dự án Aether Weather cần triển khai ứng dụng dự báo thời tiết và cảnh báo thời tiết cực đoan (Severe Alerts).
- **Quyết định**:
  - **Nền tảng**: Flutter (Mobile Android & iOS).
  - **Kiến trúc**: Clean Architecture (Feature-First) phân chia rõ `core/` và `features/weather/` (domain, data, presentation).
  - **Quản lý trạng thái**: `provider` (ChangeNotifier).
  - **Model/Immutability**: Lớp đối tượng bất biến với `final` fields, `copyWith`, serialization JSON.
  - **Local Persistence & Cache**: `shared_preferences` cho cấu hình người dùng, danh sách thành phố lưu trữ và cache dự báo thời tiết offline.
  - **Networking**: `http` kết nối Open-Meteo REST & Geocoding API.
  - **Thông báo khẩn**: `flutter_local_notifications` với kênh ưu tiên cao cho Severe Weather Alerts.
  - **Định vị**: `geolocator` với fallback tọa độ an toàn.
  - **Theme**: Material 3 hỗ trợ Light, Dark, và Pure OLED Midnight (#000000).
- **Hệ quả**: Mọi tính năng tuân thủ nghiêm ngặt stack khai báo trong `PROJECT_STACK.md`.

---

## 📌 ADR-002: Chuyển đổi mã nguồn Web sang Dự án Flutter Thuần (Android & iOS)
- **Ngày quyết định**: 2026-10-09
- **Trạng thái**: ĐÃ DUYỆT (ACCEPTED)
- **Bối cảnh**: Ban đầu repository chứa bản prototype Web / React mô phỏng giao diện Flutter. Người dùng yêu cầu chuyển đổi toàn bộ dự án thành Flutter thuần túy hỗ trợ duy nhất Android và iOS.
- **Quyết định**:
  - Lưu trữ mã web nguyên bản vào `.legacy_web/` để bảo toàn thiết kế và logic tham chiếu.
  - Khởi tạo Flutter project bằng `flutter create --platforms=android,ios`.
  - Không tạo nền tảng Web, macOS, Windows, Linux để tối ưu hóa kích thước và tính tập trung cho di động.
  - Cấu hình permissions cho Android (`AndroidManifest.xml`) và iOS (`Info.plist`) cho Internet, Location và Push Notifications.
  - Thực thi quy trình kiểm thử nghiêm ngặt: `flutter analyze` 0 errors/0 warnings, `flutter test` pass 100%.
- **Hệ quả**: Dự án trở thành codebase Flutter mobile chuyên nghiệp, sẵn sàng build và chạy trực tiếp trên thiết bị/simulator Android & iOS.

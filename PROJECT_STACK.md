# 🧩 PROJECT STACK DECLARATION (KHAI BÁO STACK CỦA DỰ ÁN)

> **CÁCH DÙNG**: File này là **cơ chế cốt lõi** giúp bộ quy tắc dùng chung (`code_base_rules_ai`) áp dụng được cho **mọi dự án Flutter**.
> Bộ rule được viết **trung lập về stack** (chỉ nêu NGUYÊN TẮC), còn **lựa chọn công nghệ cụ thể do từng dự án tự chốt tại đây**.
> Khi bắt đầu một dự án mới: sao chép file này thành `PROJECT_STACK.md` (bỏ hậu tố `.template`), điền đầy đủ, và AI Agent **BẮT BUỘC đọc nó trước tiên** để biết dự án đang dùng gì. Mọi rule dạng *"theo stack đã khai báo"* sẽ trỏ về đây.

---

## 1. THÔNG TIN DỰ ÁN
- **Tên dự án**: `Aether Weather - Flutter Forecast & Severe Alerts`
- **Loại ứng dụng**: `Mobile iOS/Android (Flutter) | Web Companion`
- **Dart/Flutter SDK**: `Dart >=3.0.0 <4.0.0, Flutter >=3.0.0`
- **Ngôn ngữ giao tiếp/comment**: `Tiếng Việt | English`

## 2. LỰA CHỌN KIẾN TRÚC & CÔNG NGHỆ (STACK MATRIX)

> Điền cột "Lựa chọn của dự án". Để trống = dùng nguyên tắc chung, chưa chốt công nghệ.

| Hạng mục | Nguyên tắc (rule liên quan) | Lựa chọn của dự án |
|---|---|---|
| **Kiến trúc tổng thể** | Phân tầng rõ ràng, phụ thuộc hướng vào trong (`rules/01`) | `Clean Architecture Feature-First / Layered` |
| **Quản lý trạng thái** | UI không chứa business logic, state bất biến (`rules/02`) | `Provider` (hoặc BLoC/Riverpod nếu nâng cấp) |
| **Model / Immutability** | Dữ liệu bất biến, `final`, value-equality (`rules/06`) | `manual immutable models (final properties, copyWith)` |
| **Local Database / Persistence** | Nguồn dữ liệu rõ ràng, truy vấn có phân trang (`rules/03`) | `shared_preferences` |
| **Networking / API** | Timeout, interceptor, tách DTO khỏi domain (`rules/04`) | `http` |
| **Dependency Injection** | Không new phụ thuộc trong UI, có thể test (`rules/05`) | `provider` |
| **Điều hướng** | Điều hướng khai báo, tách khỏi widget (`rules/01`) | `Navigator` |
| **Xử lý lỗi (Error type)** | Không để unhandled exception lên UI (`rules/06`) | `Result sealed class / Custom Exception` |
| **Chiến lược ID** | Tránh xung đột ID khi cần (`rules/03`) | `auto-increment / city ID / server-assigned` |
| **Đa ngôn ngữ (l10n)** | Không hardcode chuỗi hiển thị (`rules/10`) | `intl / flutter_localizations` |
| **Design system / Theme** | Design tokens tập trung, Material 3 (`rules/10`) | `Material 3 (Dark / Light dynamic theme)` |
| **Logging** | Cấm `print()`, che PII (`rules/09`) | `AppLogger` wrapper |
| **Code generation** | Không sửa tay file generated (`rules/07`) | `không (hiện tại chưa dùng build_runner)` |
| **Testing** | Verification gate, coverage (`rules/11`) | `flutter_test` |

## 3. MẪU HÌNH KIẾN TRÚC TÙY CHỌN (OPTIONAL PATTERNS)

> Bật/tắt các pattern nâng cao. Nếu bật, tuân thủ tài liệu trong `patterns/`.

| Pattern | Bật? | Ghi chú |
|---|:--:|---|
| **Offline-First + Outbox Sync** (`patterns/offline-first-outbox.md`) | `[x] có / [ ] không` | Cache thời tiết & cấu hình offline qua shared_preferences |
| **Background periodic jobs** | `[x] có / [ ] không` | Background fetch thông tin cảnh báo thời tiết |
| **Push notification / Deep link** | `[x] có / [ ] không` | `flutter_localnotifications` cảnh báo thời tiết cực đoan (Severe Alerts) |
| **Feature flags / Multi-flavor (dev/staging/prod)** | `[ ] có / [x] không` | |

## 4. QUY ƯỚC RIÊNG CỦA DỰ ÁN (PROJECT-SPECIFIC OVERRIDES)
- Ngưỡng coverage tối thiểu: `70% cho business logic & services`
- Geolocation: Sử dụng `geolocator` để lấy tọa độ thời tiết thực tế
- Ràng buộc/nghiệp vụ đặc thù cần Agent biết: Cảnh báo thời tiết xấu tự động gửi notification địa phương, giao diện hỗ trợ Dark/Light mode linh hoạt.

---
> ✅ Sau khi điền xong, ghi lại các lựa chọn quan trọng dưới dạng ADR trong `memory/architecture-decisions.md` của dự án để có dấu vết quyết định.

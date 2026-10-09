# 🧩 PROJECT STACK DECLARATION (KHAI BÁO STACK CỦA DỰ ÁN)

> **CÁCH DÙNG**: File này là **cơ chế cốt lõi** giúp bộ quy tắc dùng chung (`code_base_rules_ai`) áp dụng được cho **mọi dự án Flutter**.
> Bộ rule được viết **trung lập về stack** (chỉ nêu NGUYÊN TẮC), còn **lựa chọn công nghệ cụ thể do từng dự án tự chốt tại đây**.
> Khi bắt đầu một dự án mới: sao chép file này thành `PROJECT_STACK.md` (bỏ hậu tố `.template`), điền đầy đủ, và AI Agent **BẮT BUỘC đọc nó trước tiên** để biết dự án đang dùng gì. Mọi rule dạng *"theo stack đã khai báo"* sẽ trỏ về đây.

---

## 1. THÔNG TIN DỰ ÁN
- **Tên dự án**: `[điền tên]`
- **Loại ứng dụng**: `[Mobile iOS/Android | Web | Desktop | Multi-platform]`
- **Dart/Flutter SDK**: `[ví dụ: Dart >=3.x, Flutter >=3.x]`
- **Ngôn ngữ giao tiếp/comment**: `[Tiếng Việt | English]`

## 2. LỰA CHỌN KIẾN TRÚC & CÔNG NGHỆ (STACK MATRIX)

> Điền cột "Lựa chọn của dự án". Để trống = dùng nguyên tắc chung, chưa chốt công nghệ.

| Hạng mục | Nguyên tắc (rule liên quan) | Lựa chọn của dự án |
|---|---|---|
| **Kiến trúc tổng thể** | Phân tầng rõ ràng, phụ thuộc hướng vào trong (`rules/01`) | `[Clean Architecture Feature-First | MVVM | Layered | ...]` |
| **Quản lý trạng thái** | UI không chứa business logic, state bất biến (`rules/02`) | `[BLoC/Cubit | Riverpod | Provider | GetX | signals | ...]` |
| **Model / Immutability** | Dữ liệu bất biến, `final`, value-equality (`rules/06`) | `[freezed | equatable | built_value | manual | ...]` |
| **Local Database / Persistence** | Nguồn dữ liệu rõ ràng, truy vấn có phân trang (`rules/03`) | `[Drift | Isar | Hive | sqflite | ObjectBox | shared_prefs | none | ...]` |
| **Networking / API** | Timeout, interceptor, tách DTO khỏi domain (`rules/04`) | `[Dio (+Retrofit) | http | chopper | ...]` |
| **Dependency Injection** | Không new phụ thuộc trong UI, có thể test (`rules/05`) | `[get_it (+injectable) | Riverpod | provider | manual | ...]` |
| **Điều hướng** | Điều hướng khai báo, tách khỏi widget (`rules/01`) | `[go_router | auto_route | Navigator 2.0 | ...]` |
| **Xử lý lỗi (Error type)** | Không để unhandled exception lên UI (`rules/06`) | `[Either<Failure,T> (fpdart/dartz) | Result sealed class | exceptions | ...]` |
| **Chiến lược ID** | Tránh xung đột ID khi cần (`rules/03`) | `[UUID v7 | UUID v4 | auto-increment | server-assigned | ...]` |
| **Đa ngôn ngữ (l10n)** | Không hardcode chuỗi hiển thị (`rules/10`) | `[flutter_localizations + .arb | slang | none | ...]` |
| **Design system / Theme** | Design tokens tập trung, Material 3 (`rules/10`) | `[Material 3 tokens | custom | ...]` |
| **Logging** | Cấm `print()`, che PII (`rules/09`) | `[logger | talker | ...]` |
| **Code generation** | Không sửa tay file generated (`rules/07`) | `[build_runner: có/không | các annotation dùng] ` |
| **Testing** | Verification gate, coverage (`rules/11`) | `[flutter_test + mocktail/mockito + ...]` |

## 3. MẪU HÌNH KIẾN TRÚC TÙY CHỌN (OPTIONAL PATTERNS)

> Bật/tắt các pattern nâng cao. Nếu bật, tuân thủ tài liệu trong `patterns/`.

| Pattern | Bật? | Ghi chú |
|---|:--:|---|
| **Offline-First + Outbox Sync** (`patterns/offline-first-outbox.md`) | `[ ] có / [ ] không` | Local DB là SSOT, ghi kèm hàng đợi đồng bộ, sync nền |
| **Background periodic jobs** | `[ ] có / [ ] không` | workmanager / cron-like |
| **Push notification / Deep link** | `[ ] có / [ ] không` | |
| **Feature flags / Multi-flavor (dev/staging/prod)** | `[ ] có / [ ] không` | |

## 4. QUY ƯỚC RIÊNG CỦA DỰ ÁN (PROJECT-SPECIFIC OVERRIDES)
- Ngưỡng coverage tối thiểu: `[ví dụ: 70%]`
- Quy ước đặt tên/scope commit riêng (nếu khác `rules/12`): `[...]`
- Ràng buộc/nghiệp vụ đặc thù cần Agent biết: `[...]`

---
> ✅ Sau khi điền xong, ghi lại các lựa chọn quan trọng dưới dạng ADR trong `memory/architecture-decisions.md` của dự án để có dấu vết quyết định.

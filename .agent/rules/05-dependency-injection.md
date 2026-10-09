# RULE 05: TIÊM PHỤ THUỘC (DEPENDENCY INJECTION — TRUNG LẬP CÔNG CỤ)

> Áp dụng cho **mọi cơ chế DI** (get_it + injectable, Riverpod providers, provider, hoặc thủ công). Cụ thể khai báo trong `PROJECT_STACK.md`.

## 1. NGUYÊN TẮC CỐT LÕI
- Phụ thuộc được **cung cấp từ ngoài vào** (inject), không tự `new` bên trong lớp tiêu thụ → dễ thay thế & test.
- Có một điểm khởi tạo/đăng ký tập trung (service locator, container, hoặc cây provider).

## 2. QUY CHUẨN THEO TẦNG
- **Data**: API client, DAO/datasource, local DB → singleton (một instance dùng chung).
- **Repository Impl**: đăng ký gắn với interface domain (`... as XxxRepository`) → singleton lazy.
- **Domain UseCase**: nhẹ, mỗi lần resolve một instance mới hoặc factory.
- **Presentation (state holder)**: cung cấp đúng phạm vi màn hình; toàn app thì đặt ở root.

```dart
// Ví dụ nếu chọn get_it + injectable:
// @LazySingleton(as: XxxRepository) class XxxRepositoryImpl implements XxxRepository { ... }
// @injectable class GetItemsUseCase { GetItemsUseCase(this._repo); ... }
```

## 3. QUY TẮC CẤM
- ❌ **CẤM** truy cập service locator / khởi tạo phụ thuộc trực tiếp trong `build()` của Widget (khó test, phá cây phụ thuộc). Widget nhận state holder qua provider/context.
- ❌ **CẤM** đăng ký thủ công lộn xộn khi công cụ hỗ trợ sinh mã/khai báo tự động.
- ❌ **CẤM** giữ **mutable state** trong singleton mà không có cơ chế **reset/cleanup khi logout** (rò rỉ dữ liệu người dùng cũ).

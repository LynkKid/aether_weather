# RULE 02: QUẢN LÝ TRẠNG THÁI (STATE MANAGEMENT — TRUNG LẬP GIẢI PHÁP)

> Áp dụng cho **mọi giải pháp** state management (BLoC/Cubit, Riverpod, Provider, GetX, signals...). Giải pháp cụ thể khai báo trong `PROJECT_STACK.md`. Dưới đây là các NGUYÊN TẮC không phụ thuộc thư viện.

## 1. NGUYÊN TẮC BẤT BIẾN CỦA STATE
- State phải **bất biến (immutable)**: mọi trường `final`; cập nhật qua `copyWith`/tạo instance mới, không mutate tại chỗ.
- Mô hình hóa trạng thái rõ ràng: `initial / loading / loaded / error` (union/sealed class hoặc cờ trạng thái), có nhánh xử lý lỗi.
- Value-equality để tránh rebuild thừa (theo cơ chế của giải pháp: freezed/equatable/built_value... — xem `PROJECT_STACK.md`).

```dart
// Ví dụ (bất kể giải pháp): phân biệt trạng thái rõ ràng
// initial | loading | loaded(data) | error(message)
```

## 2. KHÔNG BUSINESS LOGIC TRONG UI
- Widget chỉ render + phát sự kiện/gọi action; **CẤM** HTTP request, khởi tạo nặng, gọi async trong `build()`.
- Truy xuất dữ liệu đi qua UseCase/Repository, không gọi thẳng datasource.

## 3. SIDE-EFFECTS
- Điều hướng, dialog, snackbar, toast: xử lý ở lớp lắng nghe side-effect (ví dụ: `BlocListener`, `ref.listen`, `Consumer` callback) — **tách khỏi phần dựng UI**.
- **CẤM** trigger navigation/dialog bên trong hàm build/rebuild.

## 4. VÒNG ĐỜI & TÀI NGUYÊN (LIFECYCLE)
- Cung cấp state holder đúng phạm vi (theo màn hình vs toàn app) và **giải phóng** khi không dùng (dispose/close, hủy `StreamSubscription`, `Timer`).
- Dùng transformer/debounce/throttle cho input tìm kiếm khi giải pháp hỗ trợ.

## 5. CHỐNG SPAM-CLICK & RACE CONDITION Ở TẦNG LOGIC (MUTATION GUARD)
- Mọi hành vi **mutation** (Create/Update/Delete/Submit/Payment) phải chống double-request ở tầng logic:
  - BLoC: transformer `droppable()` (`bloc_concurrency`).
  - Cubit/Notifier/khác: cờ `isSubmitting` bảo vệ + bỏ qua lời gọi khi đang chạy.
- Kết hợp Fullscreen loading overlay ở UI (xem `rules/16`). **Không** dùng cờ này để nhồi spinner vào button.

---
> Chi tiết rào chắn async & overlay: `rules/16`. Tối ưu rebuild widget: `rules/17`.

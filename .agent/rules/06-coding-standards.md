# RULE 06: TIÊU CHUẨN VIẾT CODE (DART 3 & BEST PRACTICES)

> Phổ quát cho mọi dự án Flutter/Dart. Kiểu bọc lỗi & cơ chế immutability cụ thể do dự án chọn trong `PROJECT_STACK.md`.

## 1. NGÔN NGỮ (DART 3+)
1. **Null-safety tuyệt đối**: Không lạm dụng `!`; dùng `?.`, `??`, kiểm tra null an toàn.
2. **Khai thác Dart 3**: `sealed class`, pattern matching, `switch` expression, `records` khi phân loại lỗi/nhóm dữ liệu tạm.
3. **Immutability**: Trường của Entity/State/Event là `final`; dùng `const` constructor mọi nơi có thể để tối ưu dựng widget.

## 2. ĐẶT TÊN (NAMING)
- File/thư mục: `snake_case.dart`.
- Class/Enum/Typedef: `PascalCase`.
- Biến/hàm/tham số: `camelCase`.
- Hằng số: `lowerCamelCase` (Effective Dart).

## 3. QUẢN LÝ LỖI (ERROR HANDLING)
- **Nguyên tắc bất biến**: Tuyệt đối **không để unhandled exception văng lên UI**.
- **Kiểu bọc lỗi do dự án chọn** (khai báo trong `PROJECT_STACK.md`), ví dụ:
  - `Either<Failure, T>` (fpdart/dartz) — functional, tường minh.
  - `Result<T>` sealed class (`Success`/`Failure`) — thuần Dart, không thêm dependency.
  - Exception có kiểm soát + try/catch tại ranh giới — đơn giản.
- Dù chọn kiểu nào, phải có **phân cấp lỗi rõ ràng** trong `core/error/` (ví dụ `ServerFailure`, `CacheFailure`, `ValidationFailure`, `UnexpectedFailure`) — xem template `templates/app_failure.dart.tpl`.

```dart
// Ví dụ Result sealed class (thuần Dart, không phụ thuộc lib ngoài):
sealed class Result<T> { const Result(); }
class Ok<T> extends Result<T> { final T data; const Ok(this.data); }
class Err<T> extends Result<T> { final AppFailure failure; const Err(this.failure); }
```

## 4. COMMENT & TÀI LIỆU
- Giữ nguyên comment/docstring hiện có không liên quan thay đổi.
- Viết doc comment `///` cho Public API, UseCase, Repository interface.
- Không viết comment thừa mô tả điều code đã thể hiện rõ.

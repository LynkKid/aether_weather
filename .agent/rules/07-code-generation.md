# RULE 07: QUY TRÌNH CODE GENERATION

> **ÁP DỤNG KHI**: Dự án khai báo trong `PROJECT_STACK.md` là có dùng code-gen (`build_runner` + các annotation như `@freezed`, `@JsonSerializable`, `@RestApi`, `@injectable`, `@DriftDatabase`, `@riverpod`...). Nếu dự án KHÔNG dùng code-gen, bỏ qua rule này.

## 1. NGUYÊN TẮC BẤT DI BẤT DỊCH
- **TUYỆT ĐỐI KHÔNG BAO GIỜ** chỉnh sửa bằng tay các file được sinh tự động. Tùy stack, chúng thường có đuôi:
  - `*.g.dart` (json_serializable, retrofit, injectable, riverpod...)
  - `*.freezed.dart` (freezed)
  - `*.config.dart` (injectable)
  - `*.drift.dart` / `*.g.dart` (drift), `*.gr.dart` (auto_route), `*.mocks.dart` (mockito)...
- Mọi sửa đổi trực tiếp vào các file này sẽ bị ghi đè và làm hỏng tính toàn vẹn dự án.

## 2. LỆNH CHẠY SINH MÃ CHUẨN XÁC
Khi thêm mới/sửa bất kỳ class nào có annotation code-gen:

```bash
dart run build_runner build --delete-conflicting-outputs
```
Chế độ theo dõi liên tục khi phát triển:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 3. XỬ LÝ KHI GẶP LỖI XUNG ĐỘT (TROUBLESHOOTING)
1. Kiểm tra cú pháp file nguồn: có khai báo đúng `part 'ten_file.g.dart';` / `part 'ten_file.freezed.dart';` không.
2. Kiểm tra tên class và tên file trong câu lệnh `part` có khớp chính xác hoa/thường không.
3. Nếu cache hỏng:
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Đảm bảo `.gitignore` xử lý file generated đúng theo chiến lược git của dự án (commit hoặc không).

## 4. QUY TẮC BẮT BUỘC
- ✅ Sau khi đổi model/DTO/DI/DB/API có annotation → luôn chạy generator trước khi `analyze`/`test`.
- ✅ CI phải kiểm tra file generated đồng bộ với source (xem `rules/18`).
- ❌ **CẤM** commit khi file generated lệch với source (quên chạy build_runner).

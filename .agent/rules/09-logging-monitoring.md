# RULE 09: GHI LOG & GIÁM SÁT HỆ THỐNG (LOGGING & MONITORING)

## 1. NGUYÊN TẮC VÀNG VỀ LOGGING
1. **Tuyệt đối CẤM dùng `print()` / `debugPrint()` vô tội vạ**:
   - `print()` giảm hiệu năng, không có phân cấp level, có thể rò rỉ dữ liệu nhạy cảm ra logcat/syslog ở bản release.
   - Bắt buộc dùng wrapper `AppLogger` (dựa trên thư viện log đã chọn trong `PROJECT_STACK.md`, ví dụ `logger` hoặc `talker`).
2. **Che giấu dữ liệu nhạy cảm (PII & Token Masking)**:
   - Khi log URL, Request/Response Body: các trường như `password`, `token`, `refreshToken`, `identityNumber`, `creditCard`, `phone` phải được mask thành `***` hoặc cắt ngắn.

## 2. PHÂN CẤP MỨC ĐỘ LOG (LOG LEVELS)
- `AppLogger.d(message)` — **Debug**: trace luồng khi dev; tự tắt ở Production (`kReleaseMode`).
- `AppLogger.i(message)` — **Info**: mốc sự kiện quan trọng ("Đăng nhập thành công", "Bắt đầu tác vụ nền").
- `AppLogger.w(message)` — **Warning**: bất thường nhưng không crash ("Kết nối chập chờn", "Thử lại lần 1").
- `AppLogger.e(message, error, stackTrace)` — **Error**: lỗi nghiêm trọng; gửi báo cáo về dịch vụ crash-reporting nếu đã cấu hình.

## 3. GIÁM SÁT & CRASH REPORTING (TÙY CHỌN)
- Nếu dự án bật giám sát: tích hợp một dịch vụ crash/observability (ví dụ Firebase Crashlytics, Sentry) và gửi kèm ở mức `error`.
- Log cho tác vụ nền/dài hạn phải rõ ràng, có ngữ cảnh:
  - `[Worker] Bắt đầu xử lý: N tác vụ`.
  - `[Worker] Thành công bản ghi ID: xxxx`.
  - `[Worker] Lỗi ID: yyyy. Lý do: 504. Lên lịch retry sau 30s`.

## 4. QUY TẮC BẮT BUỘC
- ✅ Dùng `AppLogger` phân cấp; che PII trước khi log; debug tự tắt ở release.
- ❌ **CẤM** `print()`/`debugPrint()` trong code sản phẩm.
- ❌ **CẤM** in raw body chứa thông tin định danh cá nhân.

# RULE 04: GIAO TIẾP MẠNG & API CLIENT (TRUNG LẬP HTTP CLIENT)

> Áp dụng cho **mọi HTTP client** (Dio, http, chopper...) và cách sinh client (Retrofit/thủ công). Cụ thể khai báo trong `PROJECT_STACK.md`.

## 1. CẤU HÌNH CLIENT TẬP TRUNG
- Một điểm cấu hình HTTP client duy nhất (base URL, timeouts). Khuyến nghị: `connectTimeout`/`receiveTimeout`/`sendTimeout` ~ 15s.
- **Interceptors/middleware bắt buộc** (nếu client hỗ trợ):
  1. **Auth**: tự gắn `Authorization: Bearer <token>` từ secure storage.
  2. **Refresh token**: bắt HTTP 401 → gọi refresh → retry request gốc.
  3. **Logging**: log request/response/error có che token & PII (chỉ bật ở debug).

## 2. TYPE-SAFE ENDPOINTS
- Ưu tiên định nghĩa API type-safe (ví dụ Retrofit) hoặc service class rõ ràng thay vì rải lời gọi HTTP khắp nơi.

```dart
// Ví dụ nếu dự án chọn Dio + Retrofit:
// @RestApi() abstract class XxxApiClient { @GET('/items') Future<List<ItemDto>> getItems(@Query('page') int page); }
```

## 3. DTO & CHUYỂN ĐỔI ENTITY
- Payload gửi/nhận là **DTO** (serialize theo giải pháp đã chọn: json_serializable/freezed/manual).
- DTO nằm ở `data/models/`; Entity ở `domain/entities/`. Bắt buộc mapper `toEntity()`/`fromEntity()`.
- **Domain & Presentation KHÔNG tiếp xúc trực tiếp DTO.**

## 4. XỬ LÝ LỖI MẠNG
- Ánh xạ lỗi HTTP/exception về kiểu lỗi domain (xem `rules/06`): 4xx/5xx/timeout/mất mạng → `ServerFailure`/tương đương.
- Áp dụng retry hợp lý (exponential backoff) cho lỗi tạm thời; **CẤM** retry vô hạn dồn dập.
- Nếu bật đồng bộ nền: dùng `Idempotency-Key` để tránh ghi trùng khi retry (xem `patterns/offline-first-outbox.md`).

---
> Bảo mật token & storage: `rules/08`. Parse JSON lớn chạy nền: `rules/15`.

# RULE 03: DỮ LIỆU & LƯU TRỮ CỤC BỘ (DATA & PERSISTENCE — TRUNG LẬP CÔNG NGHỆ)

> Áp dụng cho **mọi giải pháp lưu trữ** (Drift, Isar, Hive, sqflite, ObjectBox, shared_preferences, hoặc không có local DB). Giải pháp cụ thể khai báo trong `PROJECT_STACK.md`.

## 1. NGUYÊN TẮC CHUNG
1. **Nguồn dữ liệu rõ ràng**: Xác định rõ dữ liệu đến từ đâu (remote, local cache, hay cả hai) để tránh xung đột trạng thái hiển thị.
2. **Tách Model lưu trữ khỏi Entity domain**: Model/DTO của tầng data không rò rỉ ra Domain/Presentation; chuyển đổi qua mapper.
3. **Tính toàn vẹn giao dịch**: Khi cần ghi nhiều bảng/bản ghi liên quan, bọc trong transaction (nếu giải pháp hỗ trợ) để tránh dữ liệu nửa vời.

## 2. PHÂN TRANG DỮ LIỆU LỚN (BẮT BUỘC)
- **CẤM** nạp toàn bộ bảng/collection hàng nghìn bản ghi vào RAM (gây jank, OOM).
- Bắt buộc truy vấn phân trang (`limit`/`offset` hoặc **keyset pagination**) và Infinite Scroll ở tầng trình bày.

```dart
// Ví dụ (nếu chọn giải pháp có query builder): truy vấn phân trang
// watchPaged({required int limit, required int offset}) ...orderBy(updatedAt desc)...limit(limit, offset: offset)
```

## 3. CHIẾN LƯỢC ĐỊNH DANH (ID STRATEGY)
- Chọn ID strategy theo `PROJECT_STACK.md`:
  - **Client-generated UUID** (v7 khuyến nghị vì time-ordered tối ưu index B-tree; v4 nếu chỉ cần ngẫu nhiên) — cần khi tạo bản ghi offline/đa thiết bị.
  - **Server-assigned / auto-increment** — khi luôn online và server là nguồn ID.
- Nếu cần đồng bộ đa thiết bị: ưu tiên UUID (tránh auto-increment gây xung đột).

## 4. XÓA DỮ LIỆU
- Nếu dự án cần dấu vết đồng bộ/khôi phục: dùng **Soft Delete** (cờ `isDeleted`) thay vì xóa vật lý.
- App thuần online, không cần khôi phục: xóa vật lý là chấp nhận được.

## 5. MIGRATIONS (NẾU DÙNG DB CÓ SCHEMA)
- Tăng `schemaVersion` và viết bước migration tăng dần cho mỗi thay đổi cấu trúc.
- **TUYỆT ĐỐI KHÔNG** recreate/drop làm mất dữ liệu người dùng cục bộ.

## 6. PATTERN TÙY CHỌN: OFFLINE-FIRST + SSOT + OUTBOX
- Nếu `PROJECT_STACK.md` bật **Offline-First**: local DB là **Single Source of Truth**, UI đọc từ local qua stream, ghi kèm hàng đợi đồng bộ (Outbox) trong cùng transaction, sync nền khi có mạng.
- Chi tiết đầy đủ: **`patterns/offline-first-outbox.md`**. Nếu KHÔNG bật, bỏ qua pattern này — không áp dụng mặc định.

---
> Xử lý thời gian/múi giờ cho dữ liệu & đồng bộ: `rules/19`. Truy vấn/batch lớn chạy nền: `rules/15`.

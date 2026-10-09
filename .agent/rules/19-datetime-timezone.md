# RULE 19: XỬ LÝ THỜI GIAN & MÚI GIỜ (UTC-FIRST & CLOCK CORRECTNESS)

> **MỤC ĐÍCH**: Chuẩn hóa cách xử lý thời gian để tránh lỗi lệch múi giờ và clock skew — đặc biệt quan trọng với app có đồng bộ dữ liệu, lịch, hẹn giờ, hoặc so sánh/ sắp xếp theo thời gian.

---

## 1. NGUYÊN TẮC VÀNG: LƯU TRỮ & SO SÁNH LUÔN LÀ UTC

1. **Mọi thời điểm lưu xuống DB và gửi lên Server đều là UTC**:
   - Tạo timestamp: dùng `DateTime.now().toUtc()`, **không** dùng `DateTime.now()` (giờ local) cho các trường lưu trữ/đồng bộ.
   - Parse từ chuỗi ISO: `DateTime.parse(value).toUtc()`.
2. **Chỉ đổi sang giờ địa phương tại thời điểm hiển thị (UI Layer)**:
   - Dùng `.toLocal()` **chỉ** khi format text cho người dùng, thông qua `intl` (`DateFormat`). Không lưu ngược giá trị local.

```dart
// ✅ ĐÚNG: ghi UTC
final now = DateTime.now().toUtc();

// ✅ ĐÚNG: hiển thị giờ địa phương tại UI
final display = DateFormat('dd/MM/yyyy HH:mm').format(entity.updatedAt.toLocal());

// ❌ SAI: ghi giờ local xuống DB (lệch khi đa thiết bị/đa múi giờ)
final bad = DateTime.now();
```

---

## 2. SERVER LÀ NGUỒN CHÂN LÝ VỀ THỜI GIAN (khi có đồng bộ)

1. **Không tin tuyệt đối đồng hồ thiết bị**: có thể bị chỉnh sai, lệch vài phút–vài giờ.
2. Khi Server phản hồi (`Date` header hoặc `server_time`), có thể tính độ lệch `clockOffset = serverTime - deviceTime` để hiệu chỉnh.
3. **Nếu dự án bật Offline-First / đồng bộ** (`patterns/offline-first-outbox.md`): chiến lược giải quyết xung đột (LWW theo `updated_at`) **bắt buộc so sánh trên giá trị UTC**, và ưu tiên `updated_at` do Server gán cho bản ghi đã synced. Chi tiết xem tài liệu pattern.

---

## 3. QUY TẮC BẮT BUỘC

- ✅ Trường thời gian lưu trữ ở **UTC**; payload gửi Server ở **ISO 8601 UTC** (`toIso8601String()` trên giá trị `.toUtc()`, hậu tố `Z`).
- ✅ Định dạng hiển thị dùng `intl` + locale hiện tại, đổi `.toLocal()` ngay tại UI.
- ✅ So sánh/sắp xếp theo thời gian thực hiện trên giá trị UTC.
- ❌ **CẤM** dùng `DateTime.now()` (không `.toUtc()`) cho trường lưu trữ/đồng bộ.
- ❌ **CẤM** tự parse/format ngày tháng thủ công bằng chuỗi — dùng `intl` (`rules/13`).
- ❌ **CẤM** so sánh trực tiếp một `DateTime` local với một `DateTime` UTC.

---
*Liên quan: `rules/13` (dùng `intl`), `patterns/offline-first-outbox.md` (conflict resolution nếu bật đồng bộ).*

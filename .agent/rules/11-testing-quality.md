# RULE 11: ĐẢM BẢO CHẤT LƯỢNG & KIỂM THỬ (TESTING & QUALITY GATES)

## 1. CỔNG CHẤT LƯỢNG NGHIÊM NGẶT (VERIFICATION GATE)
Agent không được coi task là hoàn thành nếu chưa vượt qua:
1. **Linter sạch 100%**: `flutter analyze` (hoặc `dart analyze`) → **0 errors, 0 warnings**.
2. **Kiểm thử tự động**: các đơn vị logic mới/sửa phải có test tương ứng; `flutter test` pass 100%.
3. **Ngưỡng coverage**: `flutter test --coverage` đạt ngưỡng khai báo trong `PROJECT_STACK.md` (khuyến nghị ≥70% cho tầng logic/data). CI cưỡng chế (xem `rules/18`).

## 2. TEST THEO TẦNG (LAYERED TESTING)
Test theo tầng kiến trúc dự án (`rules/01`), dùng mock lib đã chọn (ví dụ `mocktail`/`mockito`):
1. **Tầng logic nghiệp vụ** (UseCase/Service/Interactor): unit test thuần, mock repository interface.
2. **Tầng state management**: test theo lib đã chọn (ví dụ `bloc_test` cho BLoC; `ProviderContainer` cho Riverpod). Kiểm tra state ban đầu → chuỗi state phát ra khi có event/action.
3. **Tầng data/persistence** (nếu có): test repository + data source; với local DB dùng instance in-memory của DB đã chọn để kiểm tra truy vấn/ghi.

## 3. NGUYÊN TẮC: TEST TẦNG RỦI RO CAO NHẤT
- **Bắt buộc** ưu tiên phủ test cho phần logic nguy hiểm/dễ mất dữ liệu nhất của dự án, không chỉ UI.
- Nếu dự án bật **Offline-First + Outbox** (`patterns/offline-first-outbox.md`): tầng đồng bộ (transaction atomicity, retry/backoff, idempotency, conflict resolution) là rủi ro cao nhất → **BẮT BUỘC** có test phủ đủ các nhánh (success / lỗi 4xx không retry vô hạn / lỗi mạng-5xx có backoff / gửi lại idempotent / conflict).
- Với các dự án khác: xác định điểm rủi ro cao nhất (thanh toán, tính toán nghiệp vụ, migration...) và phủ test tương ứng.

## 4. CHECKLIST TỰ KIỂM TRƯỚC KHI KẾT THÚC TASK
- [ ] Đã chạy code-gen (nếu dự án dùng) chưa?
- [ ] `flutter analyze` = 0 error / 0 warning chưa?
- [ ] `flutter test` (kèm `--coverage`) pass 100% và đạt ngưỡng chưa?
- [ ] Đã test tầng rủi ro cao nhất (logic/data/sync) chưa?
- [ ] Có import thừa / sai tầng kiến trúc không?
- [ ] Có lộ secret/token hay còn `print()` không?

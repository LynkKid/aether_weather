# RULE 00: BỘ RÀO CHẮN — ĐƯỢC LÀM & KHÔNG ĐƯỢC LÀM (GUARDRAILS: DOS & DON'TS)

> **MỤC ĐÍCH**: Bản quy ước tối thượng phân định ranh giới tuyệt đối giữa việc AI Agent **BẮT BUỘC/NÊN LÀM (DO)** và **TUYỆT ĐỐI CẤM LÀM (DON'T)** trên **mọi dự án Flutter** áp dụng bộ quy tắc dùng chung này.
> Bộ này **trung lập về stack**: nêu nguyên tắc, còn công nghệ cụ thể do dự án khai báo trong `PROJECT_STACK.md`.

---

## 0. TUÂN THỦ KHAI BÁO STACK (PROJECT STACK COMPLIANCE)

| ✅ ĐƯỢC LÀM / BẮT BUỘC (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • **Đọc `PROJECT_STACK.md` đầu tiên** mỗi phiên để biết state management, DB, network, DI, model, error type, ID strategy dự án đã chọn.<br>• Dùng đúng công nghệ đã khai báo. | • ❌ **CẤM** tự ý chọn/đổi sang stack khác với khai báo (ví dụ dự án chốt Riverpod mà lại viết BLoC).<br>• ❌ **CẤM** giả định công nghệ khi `PROJECT_STACK.md` chưa nêu — phải hỏi hoặc dùng nguyên tắc chung. |

---

## 1. KIẾN TRÚC & PHÂN TẦNG (ARCHITECTURE & BOUNDARIES)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Giữ tầng nghiệp vụ (Domain/logic lõi) thuần khiết, độc lập framework.<br>• Định nghĩa Entity, interface Repository, UseCase tách biệt.<br>• Chuyển đổi DTO ↔ Entity qua mapper. | • ❌ **CẤM** import UI/DB/Network framework vào tầng Domain.<br>• ❌ **CẤM** để lộ DTO ra Domain/Presentation.<br>• ❌ **CẤM** gọi UseCase/Repository/DB/API trực tiếp trong Widget hoặc `build()`.<br>• ❌ **CẤM** đổi kiến trúc đã chốt / "tiện tay refactor" code đang chạy tốt khi chưa đo Blast Radius & chưa được duyệt. |

---

## 2. QUẢN LÝ TRẠNG THÁI (STATE MANAGEMENT — MỌI GIẢI PHÁP)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • State bất biến (immutable), phân biệt rõ initial/loading/loaded/error.<br>• Side-effect (navigation, dialog, snackbar) tách khỏi phần build UI.<br>• Chống spam-click ở tầng logic cho thao tác mutation (drop/lock request trùng). | • ❌ **CẤM** đặt mutable state trôi nổi/khó test.<br>• ❌ **CẤM** viết business logic trong Widget.<br>• ❌ **CẤM** quên hủy stream/subscription gây rò rỉ bộ nhớ. |

---

## 3. DỮ LIỆU & LƯU TRỮ (DATA & PERSISTENCE)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Truy vấn danh sách lớn có phân trang (`limit`/`offset` hoặc keyset).<br>• Chọn nguồn dữ liệu rõ ràng; nếu bật Offline-First thì UI đọc từ local (xem `patterns/offline-first-outbox.md`).<br>• Dùng ID strategy theo `PROJECT_STACK.md`. | • ❌ **CẤM** nạp toàn bộ bảng hàng nghìn bản ghi vào RAM.<br>• ❌ **CẤM** trộn nhiều nguồn dữ liệu gây xung đột trạng thái hiển thị. |

---

## 4. SINH MÃ TỰ ĐỘNG (CODE GENERATION) — NẾU DỰ ÁN DÙNG

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Chạy generator (ví dụ `dart run build_runner build --delete-conflicting-outputs`) khi thay đổi model/DI/DB/API.<br>• Khai báo `part` đúng tên file. | • ❌ **TUYỆT ĐỐI CẤM SỬA TAY** file generated (`*.g.dart`, `*.freezed.dart`, `*.*.dart` sinh tự động).<br>• ❌ **CẤM** xóa file generated khi chưa hiểu nguyên nhân lỗi. |

---

## 5. GIAO DIỆN & TÀI NGUYÊN (UI, THEMING & ASSETS)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Dùng design tokens (`AppColors`/`ColorScheme`, `AppSpacing`) & Material 3.<br>• SVG cho icon đơn giản; WebP cho ảnh minh họa phức tạp.<br>• Gom đường dẫn asset vào constants tập trung.<br>• Dùng l10n theo giải pháp đã khai báo. | • ❌ **CẤM** hardcode màu hex, magic-number spacing, chuỗi hiển thị.<br>• ❌ **CẤM** SVG cho tranh phức tạp nhiều gradient (tốn CPU/GPU).<br>• ❌ **CẤM** nhúng PNG lớn chưa nén. |

---

## 6. BẢO MẬT & LƯU TRỮ NHẠY CẢM (SECURITY & STORAGE)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Lưu token/secret trong secure storage (Keychain/Keystore).<br>• Dùng `.env`/`--dart-define`; thêm secret vào `.gitignore`.<br>• Xóa sạch token/cache khi logout. | • ❌ **CẤM** lưu token trong storage thường/không mã hóa.<br>• ❌ **CẤM** hardcode API secret/private key.<br>• ❌ **CẤM** commit secret production lên git. |

---

## 7. GHI LOG & GIÁM SÁT (LOGGING & MONITORING)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Dùng wrapper logger có phân cấp d/i/w/e.<br>• Mask PII/token trước khi log. | • ❌ **TUYỆT ĐỐI CẤM** `print()`/`debugPrint()` vô tội vạ.<br>• ❌ **CẤM** in raw body chứa thông tin định danh cá nhân. |

---

## 8. CHẤT LƯỢNG & TEST (VERIFICATION GATE)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • `flutter analyze` → **0 errors, 0 warnings**.<br>• Viết test cho logic nghiệp vụ mới; `flutter test` pass 100% + đạt ngưỡng coverage. | • ❌ **CẤM** bỏ qua warning/lint.<br>• ❌ **CẤM** kết thúc task khi chưa test business logic mới hoặc test đang fail. |

---

## 9. GIT & KẾ HOẠCH (GIT & PLANNING)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Lập checklist file cần tạo/sửa trước khi code.<br>• Commit theo Conventional Commits. | • ❌ **CẤM** sửa file ngoài phạm vi task.<br>• ❌ **CẤM** tự `git commit`/`push` khi chưa được yêu cầu; **CẤM** lệnh phá hủy (`reset --hard`, `clean -fd`). |

---

## 10. NGHIÊN CỨU & CHỐNG BỊA ĐẶT (RESEARCH-FIRST & ANTI-HALLUCINATION)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Khảo sát codebase + tra cứu pub.dev/docs trước khi code.<br>• Đối chiếu chữ ký API/tham số thực tế.<br>• Ưu tiên package battle-tested. | • ❌ **CẤM** "code mù" theo suy đoán.<br>• ❌ **TUYỆT ĐỐI CẤM** bịa class/hàm/thuộc tính/tham số/thư viện không tồn tại. |

---

## 11. AI MEMORY & HỌC TỪ CON NGƯỜI

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Đọc `memory/context-cache.md` + `architecture-decisions.md` trước khi quét sâu source.<br>• Ghi bài học vào `memory/human-learnings.md` khi Human can thiệp.<br>• Bật Guide Mode khi bài toán mơ hồ. | • ❌ **CẤM** quét lại hàng chục file khi đã có cache.<br>• ❌ **CẤM** lặp lại lỗi Human đã sửa. |

---

## 12. HIỆU NĂNG NỀN & MAIN THREAD

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Đẩy tính toán nặng/parse JSON lớn/mã hóa/xử lý ảnh xuống isolate (`compute`/`Isolate.run`). | • ❌ **TUYỆT ĐỐI CẤM** chạy tác vụ nặng trên Main UI Thread gây jank/ANR. |

---

## 13. RÀO CHẮN ASYNC & CHỐNG SPAM-CLICK

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Mọi tác vụ async khóa tương tác bằng Fullscreen loading overlay (`barrierDismissible: false`, chặn Back).<br>• Chống double-request ở tầng logic (drop/lock). | • ❌ **CẤM** để nút bấm không phản hồi khi async.<br>• ❌ **TUYỆT ĐỐI CẤM** nhồi spinner nhỏ vào button gây giật layout. |

---

## 14. WIDGET MASTERY (FLUTTER)

| ✅ ĐƯỢC LÀM (DO) | ❌ TUYỆT ĐỐI CẤM (DON'T) |
|---|---|
| • Custom topbar trong `Scaffold.appBar` (`PreferredSize`) hoặc `SliverAppBar`.<br>• `ListView.builder`/`SliverList.builder` cho list động (+`itemExtent`).<br>• Tách `StatelessWidget` có `const`; dùng `MediaQuery.sizeOf/paddingOf/viewInsetsOf`.<br>• `InkWell` trong `Material` cho ripple. | • ❌ **CẤM** topbar trong `body: Column`.<br>• ❌ **TUYỆT ĐỐI CẤM** `SafeArea` trong/ngoài `Scaffold`.<br>• ❌ **CẤM** `SingleChildScrollView + Column` cho list lớn; `Expanded`/`Spacer` trong scroll view.<br>• ❌ **CẤM** hàm helper `Widget _buildItem()`; `MediaQuery.of(context)` chung chung. |

---
> Chi tiết từng mục xem các file `rules/01`–`rules/20`. Nguyên tắc là bất biến; công nghệ theo `PROJECT_STACK.md`.

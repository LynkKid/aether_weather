# WORKFLOW: CỔNG KIỂM TRA CHẤT LƯỢNG (CODE-REVIEW-GATE)

Trước khi Agent thông báo "Đã hoàn thành", **BẮT BUỘC** tự rà soát checklist dưới đây.
Các dòng gắn "*(nếu…)*" chỉ áp dụng khi `PROJECT_STACK.md` bật lựa chọn tương ứng.

## 🔍 CHECKLIST BÀN GIAO

| STT | Hạng mục | Trạng thái yêu cầu |
|---|---|---|
| 1 | **Tuân thủ PROJECT_STACK**: Dùng đúng state mgmt/DB/network/DI/model/error type dự án đã khai báo? | ✅ Đúng stack, không tự đổi |
| 2 | **Code Generation** *(nếu dự án dùng)* | ✅ File generated đã cập nhật mới nhất |
| 3 | **Static Analysis**: `flutter analyze` | ✅ 0 Errors, 0 Warnings |
| 4 | **Automated Tests**: `flutter test` (+ `--coverage`) | ✅ Pass 100%, đạt ngưỡng coverage dự án |
| 5 | **Ranh giới Domain**: Tầng nghiệp vụ có dính import UI/DB/Network framework không? | ✅ Domain thuần khiết |
| 6 | **UI không chứa logic**: Có gọi API/DB/UseCase trực tiếp trong Widget/`build()` không? | ✅ UI chỉ giao tiếp qua State Manager |
| 7 | **Hardcoded Values**: Màu/spacing/font/kích thước bị hardcode? | ✅ Dùng Design Tokens |
| 8 | **Localization** *(nếu dùng l10n)*: Có chuỗi hiển thị bị hardcode? | ✅ Qua l10n |
| 9 | **Logging**: Còn `print()`/`debugPrint()`? PII/token có bị lộ? | ✅ Dùng logger + che PII |
| 10 | **Bảo mật**: Có commit secret/key/token? | ✅ Sạch |
| 11 | **Git Diff Scope**: Chỉ sửa file trong phạm vi task? | ✅ Không lan man |
| 12 | **Anti-Hallucination**: Có hàm/thuộc tính/tham số bị bịa đặt? | ✅ Đã đối chiếu chữ ký API thực tế |
| 13 | **Khai thác pub.dev**: Tự chế cho bài toán đã có package chuẩn? | ✅ Ưu tiên package battle-tested |
| 14 | **Bảo toàn Kiến trúc & Blast Radius**: Tự ý đổi kiến trúc/sửa code đang chạy tốt? | ✅ Giữ nguyên; nếu tối ưu đã đo Blast Radius & được duyệt |
| 15 | **Background Isolates**: Tính toán nặng/parse JSON lớn chạy trên Main Thread? | ✅ Đã đẩy xuống `compute()`/`Isolate.run()` |
| 16 | **Async UX Guard**: Thao tác async có overlay khóa tương tác + chống double-click? | ✅ Có fullscreen loading + guard; không button spinner |
| 17 | **Scaffold/TopBar/SafeArea**: TopBar đúng `Scaffold.appBar`? Không dùng SafeArea trong/ngoài Scaffold? | ✅ Đúng nguyên tắc widget |
| 18 | **Ảo hóa Danh sách & Constraints**: List động dùng `.builder`? Có `Expanded` trong scroll view? | ✅ `ListView.builder`; không unbounded height |
| 19 | **Rebuild Optimization**: Dùng `MediaQuery.sizeOf`? Tách `StatelessWidget` `const` thay hàm `_buildItem()`? | ✅ Tối ưu Element Tree |
| 20 | **Error Handling**: Trả về đúng kiểu lỗi chuẩn dự án (Either/Result/exception có kiểm soát)? | ✅ Không để unhandled exception lên UI |
| 21 | **Timezone**: Thời gian lưu/đồng bộ ở UTC, chỉ `toLocal()` khi hiển thị? | ✅ UTC-first |
| 22 | **Accessibility**: Icon-button/ảnh thông tin có nhãn ngữ nghĩa? Chạm ≥48dp? Không khóa cứng `textScaler`? | ✅ Đạt a11y tối thiểu |
| 23 | **Offline-First** *(nếu bật pattern)*: Ghi nghiệp vụ + sync_queue cùng transaction? Idempotency? LWW UTC? | ✅ Tuân thủ `patterns/offline-first-outbox.md` |
| 24 | **Enforcement** *(khi dự án đã init)*: CI xanh, pre-commit hook pass? | ✅ Không `--no-verify` |

> Đạt đủ các mục **không có điều kiện** + các mục *(nếu…)* tương ứng với lựa chọn trong `PROJECT_STACK.md` → mới được báo hoàn thành.

# RULE 01: KIẾN TRÚC MÃ NGUỒN (CLEAN ARCHITECTURE & FEATURE-FIRST)

> Nguyên tắc phân tầng **trung lập về stack**. Mô hình kiến trúc tổng thể dự án chọn (Clean Architecture / MVVM / Layered...) khai báo trong `PROJECT_STACK.md`; nội dung dưới đây mặc định theo Clean Architecture Feature-First — pattern phổ biến & dễ test nhất cho Flutter.

## 1. NGUYÊN TẮC CỐT LÕI
Phân tách theo **Feature-First** (theo từng tính năng) + **phụ thuộc hướng vào trong** (Presentation → Domain ← Data). Mục tiêu: độc lập giữa các lớp, dễ kiểm thử, mở rộng, bảo trì.

## 2. CẤU TRÚC THƯ MỤC CHUẨN (THAM KHẢO)

```
lib/
├── core/                     # Dùng chung: theme, di, error, network, utils, constants, (database nếu có)
├── features/
│   └── [feature_name]/       # Ví dụ: auth, catalog, order
│       ├── data/             # datasources (remote/local), models (DTO), repositories (Impl)
│       ├── domain/           # entities, repositories (interface), usecases  — PURE DART
│       └── presentation/     # state management (theo PROJECT_STACK), pages, widgets
├── l10n/
└── main.dart
```

## 3. RANH GIỚI CÁC TẦNG (LAYER BOUNDARIES)

### Tầng Domain (Pure Dart — trái tim hệ thống)
- Hoàn toàn độc lập Framework/UI/DB/Network.
- **TUYỆT ĐỐI KHÔNG** `import 'package:flutter/...'`, không import DB/Network framework cụ thể.
- Chứa: `entities` (đối tượng nghiệp vụ thuần), `repositories` (interface trừu tượng), `usecases` (một hành vi/`call()`).

### Tầng Data
- Triển khai interface của Domain (`XxxRepositoryImpl implements XxxRepository`).
- Kết nối nguồn dữ liệu (remote API + local persistence — theo `PROJECT_STACK.md`).
- Chuyển đổi `Model/DTO ↔ Entity` qua mapper (`toEntity()`, `toModel()`). **Không để lộ DTO** ra ngoài Data.

### Tầng Presentation
- Chỉ giao tiếp với lớp quản lý trạng thái đã chọn (BLoC/Cubit, Riverpod, Provider... — xem `rules/02`).
- **CẤM** gọi trực tiếp UseCase/Repository/DB/API trong `build()` hoặc Widget.

---

## 4. BẢO TOÀN KIẾN TRÚC & ĐÁNH GIÁ PHẠM VI ẢNH HƯỞNG (BLAST RADIUS PROTOCOL)

1. **Kiến trúc đã chốt là bất khả xâm phạm**: Không tự ý đổi mô hình kiến trúc/stack đã thống nhất (ghi trong ADR & `PROJECT_STACK.md`).
2. **Không phá code đang chạy tốt (Working Code Invariance)**: Cấm "tiện tay refactor", đổi chữ ký hàm, viết lại thuật toán ngoài phạm vi task.
3. **Quy trình 4 bước Blast Radius** khi buộc phải tối ưu code đang chạy:
   1. **Xác định lý do** & giá trị kỹ thuật.
   2. **Đo Blast Radius**: file/module/màn hình bị ảnh hưởng trực/gián tiếp; có breaking change schema/API/state không; mức rủi ro hồi quy (Thấp/TB/Cao).
   3. **Xin phê duyệt Human**: xuất bản báo cáo ngắn gọn + phương án đề xuất.
   4. **Chờ quyết định**: chỉ thực hiện khi Người dùng đồng ý.

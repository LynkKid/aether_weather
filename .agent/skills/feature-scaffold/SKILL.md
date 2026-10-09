---
name: feature-scaffold
description: Sinh trọn bộ khung một Feature mới theo Clean Architecture (Feature-First) TRUNG LẬP STACK — dùng đúng công nghệ dự án khai báo trong PROJECT_STACK.md
---

# SKILL: TẠO KHUNG FEATURE CLEAN ARCHITECTURE (FEATURE-SCAFFOLD)

Khi người dùng yêu cầu *"Tạo tính năng mới [Tên Tính Năng]"*, Agent kích hoạt kỹ năng này để tạo khung chuẩn, tránh thiếu tầng hoặc import lộn xộn.

> ⚠️ **TRUNG LẬP STACK**: Skill này **không ép** state management / DB / network / DI cụ thể.
> **BẮT BUỘC đọc `PROJECT_STACK.md` trước** để biết dự án chọn gì (BLoC/Riverpod/..., Drift/Isar/..., Dio/http/..., freezed/equatable/..., go_router/auto_route/...), rồi dựng đúng theo đó.

## 📋 CÁC BƯỚC THỰC HIỆN

### Bước 0: Đọc cấu hình dự án
- Đọc `PROJECT_STACK.md` → xác định: state management, model/immutability, local DB, network client, DI, router, error type, có/không offline-first (`patterns/offline-first-outbox.md`).
- Khảo sát codebase xem đã có helper/service tương tự chưa (`rules/13`).

### Bước 1: Khởi tạo cấu trúc thư mục
Tạo cấu trúc đầy đủ trong `lib/features/[feature_name]/`:
```
lib/features/[feature_name]/
├── data/
│   ├── datasources/        # Local (DB đã chọn) & Remote (network client đã chọn)
│   ├── models/             # DTO (theo lib serialize đã chọn)
│   └── repositories/       # Repository Impl
├── domain/
│   ├── entities/           # Thực thể bất biến ([Entity])
│   ├── repositories/       # Interface trừu tượng
│   └── usecases/           # UseCase độc lập cho từng hành vi
└── presentation/
    ├── state/              # State layer theo stack (bloc/ | cubit/ | notifiers/ | controllers/)
    ├── pages/              # Màn hình chính
    └── widgets/            # Widget con nội bộ
```

### Bước 2: Viết mã theo thứ tự phụ thuộc (Dependency Flow)
1. **Domain Entity**: entity bất biến trong `domain/entities/` (dùng lib immutability đã chọn).
2. **Domain Repository**: interface trong `domain/repositories/`.
3. **Domain UseCases**: mỗi UseCase một hành vi, nhận repository interface; kiểu trả về theo error type đã chọn (`Either<Failure,T>` / `Result<T>` / throw) (`rules/06`).
4. **Data DTO**: model có (de)serialize + mapper `toDomain()`/`toDto()`; DTO KHÔNG lộ ra domain/presentation (`rules/04`).
5. **Data Sources**: DAO/local theo DB đã chọn; API client theo network lib đã chọn.
6. **Data Repository Impl**: implement interface, kết nối local + remote, đăng ký DI theo cơ chế đã chọn (`rules/05`). Nếu bật Offline-First: ghi kèm hàng đợi Outbox trong cùng transaction (`patterns/offline-first-outbox.md`).
7. **Presentation State**: State bất biến + logic theo stack (BLoC/Cubit, Riverpod Notifier, Controller...) (`rules/02`); mutation có chống double-submit (`rules/16`).
8. **Presentation UI**: dựng màn hình, kết nối state layer, không chứa business logic trong `build()`.

### Bước 3: Code Generation (nếu dự án dùng)
- Nếu `PROJECT_STACK.md` khai báo dùng `build_runner`:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- Tuyệt đối không sửa tay file generated (`rules/07`).

### Bước 4: Đăng ký Route & l10n
- Khai báo route theo router đã chọn (`go_router`/`auto_route`/Navigator 2.0).
- Thêm chuỗi hiển thị vào l10n, không hardcode (`rules/10`).

### Bước 5: Test & Verification Gate
- Viết test cho UseCase, state layer và tầng data (`skills/test-writer`, `rules/11`).
- Chạy `flutter analyze` (0/0) + `flutter test` trước khi báo xong (`workflows/code-review-gate.md`).

---
name: test-writer
description: Viết Unit Test / State Test / Data-layer Test chuẩn chỉnh, TRUNG LẬP STACK — dùng framework test & lib mock dự án đã chọn trong PROJECT_STACK.md
---

# SKILL: VIẾT KIỂM THỬ TỰ ĐỘNG (TEST-WRITER)

Kỹ năng đảm bảo mọi logic mới/sửa đều có test tương ứng, đạt Verification Gate (`rules/11`).

> ⚠️ **TRUNG LẬP STACK**: Đọc `PROJECT_STACK.md` để biết framework test (`flutter_test`), lib mock (`mocktail`/`mockito`), và state management (quyết định cách test state layer).

## 1. TEST LOGIC LAYER (UseCase / Service) — mọi dự án
- Test thuần Dart cho UseCase: mock repository, kiểm hành vi & kiểu trả về (`Either`/`Result`/exception theo error type đã chọn).
```dart
class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late MockItemRepository repo;
  late GetItemsUseCase useCase;

  setUp(() {
    repo = MockItemRepository();
    useCase = GetItemsUseCase(repo);
  });

  test('trả về danh sách khi repository thành công', () async {
    when(() => repo.getItems()).thenAnswer((_) async => const [tItem]);
    final result = await useCase();
    expect(result, isNotNull);
    verify(() => repo.getItems()).called(1);
  });
}
```

## 2. TEST STATE LAYER — theo stack đã chọn
- **Nếu dùng BLoC/Cubit** (`bloc_test`):
```dart
blocTest<ItemBloc, ItemState>(
  'phát ra [loading, loaded] khi Started thành công',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) => Stream.value([tItem]));
    return ItemBloc(mockUseCase);
  },
  act: (bloc) => bloc.add(const ItemEvent.started()),
  expect: () => [const ItemState.loading(), ItemState.loaded(items: const [tItem])],
);
```
- **Nếu dùng Riverpod**: dùng `ProviderContainer` + override provider, `container.read(...)` và `listen` để kiểm state chuyển tiếp.
- **Nếu dùng ChangeNotifier/Controller**: khởi tạo với mock, gọi action, `expect` giá trị state/`notifyListeners`.

## 3. TEST TẦNG DATA & PERSISTENCE (tầng rủi ro cao)
- Test Repository Impl: mock data source local + remote, kiểm mapper DTO↔Entity và luồng ưu tiên nguồn dữ liệu.
- Test local DB theo lib đã chọn (ví dụ Drift dùng `NativeDatabase.memory()`; Isar/Hive dùng instance test tương ứng): kiểm transaction/atomicity.
- **Nếu bật Offline-First**: bắt buộc test Sync Worker (thành công / lỗi 4xx không retry vô hạn / 5xx-mạng retry backoff / idempotency / conflict) — xem `patterns/offline-first-outbox.md`.

## 4. NGUYÊN TẮC & NGƯỠNG
- Đặt tên test rõ ràng theo hành vi (given/when/then).
- Đảm bảo `flutter test` pass 100%; đạt ngưỡng coverage khai báo trong `PROJECT_STACK.md` (khuyến nghị ≥70% cho logic + data).
- Dọn tài nguyên trong `tearDown` (đóng bloc/DB/container).

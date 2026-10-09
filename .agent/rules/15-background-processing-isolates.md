# RULE 15: HIỆU NĂNG NỀN & BẢO VỆ MAIN THREAD (BACKGROUND ISOLATES)

> **MỤC ĐÍCH**: Tuyệt đối không để tác vụ tính toán nặng làm giật lag giao diện; giữ ổn định 60–120 FPS trên mọi dự án Flutter.

---

## 1. BẢN CHẤT KỸ THUẬT & NGÂN SÁCH KHUNG HÌNH

- Trong Flutter, toàn bộ quá trình dựng giao diện (build, layout, paint) và nhận diện cảm ứng diễn ra trên **Main UI Isolate** (đơn luồng).
- Một khung hình ở 60Hz chỉ có **16.6ms**, ở 120Hz chỉ có **8.3ms**. Bất kỳ phép tính nào chiếm dụng Main Thread vượt ngưỡng này sẽ gây **Jank (rớt khung hình), đơ cảm ứng hoặc ANR (Application Not Responding)**.

---

## 2. DANH MỤC TÁC VỤ BẮT BUỘC ĐẨY XUỐNG BACKGROUND ISOLATE

Agent **BẮT BUỘC** chuyển các tác vụ sau sang Background Isolate:
1. **Parse / Decode JSON dung lượng lớn**: Phản hồi API > ~50KB hoặc danh sách > vài trăm phần tử.
2. **Xử lý / Lọc / Sắp xếp mảng dữ liệu lớn**: Tìm kiếm, filter đa tiêu chí, tính toán tổng hợp trên hàng ngàn phần tử.
3. **Mã hóa & Bảo mật**: Hashing, mã hóa AES/RSA, tạo chữ ký số.
4. **Xử lý hình ảnh**: Nén/resize/chuyển đổi định dạng ảnh trước khi upload.
5. **Tác vụ I/O nặng lặp lớn**: Batch xử lý dữ liệu cục bộ số lượng lớn.

---

## 3. CHUẨN TRIỂN KHAI (DART 3 & FLUTTER)

### Cách 1: `Isolate.run()` (Dart 2.19+ / Dart 3 — Khuyên dùng)
Dành cho tác vụ tính toán ngắn hạn, tự tạo isolate và dọn dẹp khi kết thúc:
```dart
// ✅ ĐÚNG: Đẩy parse dữ liệu lớn sang Isolate.run()
Future<List<Item>> parseItemsInBackground(String jsonString) async {
  return await Isolate.run(() {
    final List<dynamic> rawList = jsonDecode(jsonString) as List<dynamic>;
    return rawList
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  });
}
```

### Cách 2: `compute()` từ `flutter/foundation.dart`
```dart
// ✅ ĐÚNG: Dùng compute cho hàm top-level hoặc static
Future<List<Item>> filterItems(FilterParams params) async {
  return await compute(_heavyFilterTask, params);
}

List<Item> _heavyFilterTask(FilterParams params) {
  // Logic lọc phức tạp trên hàng ngàn phần tử
  return params.items.where((e) => e.matches(params.criteria)).toList();
}
```

> ⚠️ **Lưu ý**: Hàm chạy trong isolate phải là top-level/static; tham số truyền vào phải serialize được (không chứa closure bắt state, không chứa handle không thể copy).

---

## 📋 4. CHECKLIST TỰ KIỂM TRA

| Tiêu chí | Câu hỏi | Đạt yêu cầu |
|---|---|:---:|
| **Main Thread Safety** | Có tính toán nặng / sort-filter mảng lớn / parse JSON lớn trực tiếp trên Main Thread không? | ❌ KHÔNG (đã dùng `compute`/`Isolate.run`) |
| **Isolate-safe args** | Tham số truyền vào isolate có serialize được không? | ✅ CÓ |

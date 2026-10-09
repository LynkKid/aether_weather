# RULE 20: KHẢ NĂNG TIẾP CẬN (ACCESSIBILITY - A11Y)

> **MỤC ĐÍCH**: Thiết lập chuẩn tối thiểu về khả năng tiếp cận để giao diện dùng được với trình đọc màn hình (TalkBack/VoiceOver), cỡ chữ hệ thống lớn và tương phản đủ — áp dụng cho mọi dự án Flutter.

---

## 1. HỖ TRỢ TRÌNH ĐỌC MÀN HÌNH (SCREEN READERS)

1. **Gán nhãn ngữ nghĩa**: Icon-button, nút chỉ có icon, avatar, ảnh mang thông tin **bắt buộc** có nhãn qua `Semantics(label: ...)`, `tooltip`, hoặc `semanticsLabel`. Nhãn lấy từ l10n (`rules/10`), không hardcode.
```dart
// ✅ Icon-button có nhãn
IconButton(
  icon: const Icon(Icons.filter_list),
  tooltip: context.l10n.filter, // hiển thị + đọc được
  onPressed: _openFilter,
)
```
2. **Ẩn phần tử trang trí thuần túy**: dùng `ExcludeSemantics` hoặc `semanticLabel: ''` để tránh nhiễu.
3. **Gộp ngữ nghĩa hợp lý**: card/list-item nhiều text → `Semantics(container: true, label: ...)` hoặc `MergeSemantics` để đọc thành cụm mạch lạc.
4. **Thông báo trạng thái động**: thay đổi quan trọng → `SemanticsService.announce(message, textDirection)`.

---

## 2. CỠ CHỮ CO GIÃN THEO HỆ THỐNG (DYNAMIC TEXT SCALING)

1. **KHÔNG chặn co giãn cỡ chữ**: **CẤM** ép `TextScaler.noScaling` để "khóa cứng" layout. Người dùng lớn tuổi thường bật cỡ chữ lớn.
2. **Layout chịu được cỡ chữ lớn**: tránh `Container` chiều cao cố định bao text; text dài dùng `maxLines` + `overflow: TextOverflow.ellipsis` chủ đích.
3. **Dùng token typography, không hardcode `fontSize`** (`rules/10`).

---

## 3. TƯƠNG PHẢN & VÙNG CHẠM

1. **Tương phản WCAG AA**: tối thiểu **4.5:1** cho text thường, **3:1** cho text lớn/icon. Ưu tiên cặp màu `on*` của `ColorScheme` Material 3.
2. **Vùng chạm tối thiểu 48x48 dp**: dùng `IconButton` mặc định, `ConstrainedBox`, hoặc `MaterialTapTargetSize.padded`.
3. **Không truyền tải thông tin CHỈ bằng màu sắc**: trạng thái (thành công/lỗi/chờ) phải kèm icon hoặc text cho người mù màu.

---

## 4. QUY TẮC BẮT BUỘC & KIỂM THỬ

- ✅ Nút chỉ có icon phải có `tooltip`/`Semantics(label)`.
- ✅ `TextField` phải có `labelText`/`InputDecoration` rõ ràng, không chỉ dựa `hintText`.
- ✅ Ưu tiên widget Material có sẵn ngữ nghĩa (`ElevatedButton`, `Switch`, `Checkbox`) hơn tự chế bằng `GestureDetector`.
- ✅ Khuyến khích widget test kiểm tra semantics: `expect(find.bySemanticsLabel('...'), findsOneWidget);`.
- ❌ **CẤM** khóa cứng `textScaler` để chống vỡ layout — sửa layout cho co giãn được.
- ❌ **CẤM** icon-button/ảnh mang thông tin mà không có nhãn ngữ nghĩa.

---
*Liên quan: `rules/10` (design tokens & l10n), `rules/17` (widget mastery).*

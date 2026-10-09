# RULE 17: BẢN CHẤT WIDGET & DANH MỤC ANTI-PATTERNS (SENIOR FLUTTER WIDGET MASTERY)

> **MỤC ĐÍCH**: Định hình tư duy Senior Flutter Developer khi dựng giao diện. Không "code đại", không dùng bừa widget. Đây là kiến thức framework Flutter — áp dụng cho **mọi dự án**, độc lập với state management/DB/network.

---

## 🏛️ PHẦN 1: NGUYÊN TẮC CỐT LÕI CỦA RENDER TREE

### 1.1. "Constraints go down. Sizes go up. Parent sets position."
1. **Cha truyền ràng buộc xuống con**: Widget cha truyền `BoxConstraints` (min/max width/height) xuống con.
2. **Con tự quyết kích thước trong giới hạn đó**: Con tính kích thước dựa trên nội dung + ràng buộc, báo lại cho cha.
3. **Cha quyết vị trí đặt con**: Cha xác định tọa độ vẽ con lên Render Tree.
> ⚠️ Không ép widget vi phạm ràng buộc của cha mà không qua widget trung gian (`UnconstrainedBox`, `OverflowBox`, `FittedBox`).

### 1.2. Widget Tree vs Element Tree vs RenderObject Tree
- **Widget**: bản thiết kế bất biến (immutable blueprint), rẻ, tạo mới liên tục mỗi `build()`.
- **Element**: thực thể quản trị vòng đời, giữ vị trí trên cây và quản lý state.
- **RenderObject**: đối tượng thực thi layout, hit-testing, vẽ (CPU/GPU-intensive).
> ⚠️ **Hệ quả**: Tách widget thành class `StatelessWidget` độc lập có `const` giúp Flutter tái dùng `Element` cũ và bỏ qua `build()` khi tham số không đổi. Hàm `Widget _buildX()` KHÔNG tạo Element riêng → cha rebuild là toàn bộ nội dung rebuild theo.

---

## 🛑 PHẦN 2: DANH MỤC ANTI-PATTERNS & GIẢI PHÁP CHUẨN SENIOR

### 2.1. Scaffold, AppBar & TUYỆT ĐỐI CẤM SafeArea trong Scaffold
**Vì sao đã dùng Scaffold thì KHÔNG dùng SafeArea?** Cả hai cùng xử lý bài toán tính khoảng đệm an toàn (Window Insets) cho đỉnh (Status Bar/Notch) và đáy (Home Indicator/Nav Bar). `Scaffold` là widget điều phối insets cấp màn hình toàn diện (qua `appBar`, `bottomNavigationBar`, `resizeToAvoidBottomInset`). Bọc `SafeArea` trong/ngoài `Scaffold` gây xung đột kép, double padding, phá vỡ cuộn tràn viền (edge-to-edge).

```dart
// ❌ SAI: TopBar trong body + SafeArea trong Scaffold
Scaffold(
  body: Column(children: [
    Container(height: 60, child: Text('Custom Header')), // hỏng status bar, đè notch
    Expanded(child: ListView(...)),
  ]),
)

// ✅ ĐÚNG: TopBar ở appBar, không SafeArea
Scaffold(
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(64),
    child: CustomHeaderWidget(),
  ),
  body: ListView.builder(...), // KHÔNG bọc SafeArea
)
```
> Chỉ dùng `SafeArea` cho component/dialog/bottom sheet standalone KHÔNG có `Scaffold`.

### 2.2. Ảo hóa danh sách (Virtualization)
```dart
// ❌ SAI: SingleChildScrollView + Column render toàn bộ vào RAM -> tụt FPS, OOM
SingleChildScrollView(child: Column(children: items.map((e) => ItemCard(e)).toList()))

// ✅ ĐÚNG: ListView.builder kích hoạt ảo hóa
ListView.builder(
  itemCount: items.length,
  itemExtent: 80, // O(1) nếu chiều cao cố định
  itemBuilder: (context, i) => ItemCard(items[i]),
)
```
- Không lạm dụng `shrinkWrap: true` trên danh sách lớn (phá ảo hóa). Nhiều list lồng nhau: dùng `CustomScrollView` + `SliverList`.

### 2.3. Lỗi Ràng Buộc Vô Hạn (Unbounded Height)
```dart
// ❌ SAI: Expanded/Spacer trong SingleChildScrollView -> crash unbounded height
SingleChildScrollView(child: Column(children: [Text('H'), Expanded(child: Container())]))

// ✅ ĐÚNG: đẩy nút xuống đáy form cuộn
LayoutBuilder(builder: (context, c) => SingleChildScrollView(
  child: ConstrainedBox(
    constraints: BoxConstraints(minHeight: c.maxHeight),
    child: IntrinsicHeight(child: Column(children: [/*...*/ const Spacer(), SubmitButton()])),
  ),
))
```

### 2.4. Rebuild thừa với MediaQuery & Element Tree
```dart
// ❌ LẠC HẬU: lắng nghe toàn bộ MediaQueryData -> rebuild khi bàn phím bật/tắt
final w = MediaQuery.of(context).size.width;
// ✅ ĐÚNG: chỉ lắng nghe thuộc tính cần
final w = MediaQuery.sizeOf(context).width;
final padding = MediaQuery.paddingOf(context);
final insets = MediaQuery.viewInsetsOf(context);
```
- Tách `Widget _buildItem()` thành class `StatelessWidget` có `const` constructor.

### 2.5. Cảm ứng & phản hồi Material
- Dùng `InkWell` bọc trong `Material` (ripple chuẩn M3) thay `GestureDetector` thô.
- Thêm `behavior: HitTestBehavior.opaque` khi vùng chạm chứa khoảng trống trong suốt.

---

## 📋 PHẦN 3: BẢNG TRA CỨU NHANH

| Bài toán | ❌ Junior | ✅ Senior | Lý do |
|---|---|---|---|
| TopBar tùy biến | `Container` trong `body: Column` | `Scaffold.appBar: PreferredSize` / `SliverAppBar` | Đúng safe area, status bar, bàn phím |
| Đệm an toàn | `SafeArea` trong/ngoài `Scaffold` | Để `Scaffold` tự điều phối | Tránh double padding, giữ edge-to-edge |
| List dài | `SingleChildScrollView + Column` | `ListView.builder`/`SliverList.builder` | Ảo hóa bộ nhớ, chống OOM |
| Item bằng nhau | `.builder` không set size | thêm `itemExtent`/`prototypeItem` | Scroll offset O(1) |
| Nút xuống đáy form cuộn | `Expanded` trong scroll | `LayoutBuilder`+`ConstrainedBox`+`IntrinsicHeight` | Tránh unbounded height |
| Kích thước màn hình | `MediaQuery.of(context).size` | `MediaQuery.sizeOf(context)` | Tránh rebuild thừa |
| Tách UI component | hàm `_buildRow()` | class `StatelessWidget` const | Tận dụng Element Tree |
| Hiệu ứng chạm | `GestureDetector` thô | `InkWell` trong `Material` | Ripple M3 |

# RULE 10: GIAO DIỆN, DESIGN TOKENS & ĐA NGÔN NGỮ (THEMING, TOKENS & L10N)

## 1. NGUYÊN TẮC THIẾT KẾ GIAO DIỆN
- Ưu tiên tuân thủ **Material Design 3** (`useMaterial3: true`), hỗ trợ đầy đủ **Light** và **Dark Mode**. (Nếu dự án dùng design system riêng, khai báo trong `PROJECT_STACK.md`.)

## 2. QUẢN LÝ DESIGN TOKENS TẬP TRUNG
1. **Tuyệt đối CẤM hardcode màu sắc, font, khoảng cách**:
   - Không viết `Color(0xFF123456)`, không nhét `fontSize`/`padding` magic-number rải rác trong Widget.
   - Dùng `Theme.of(context).colorScheme` / `AppColors`, `AppTypography`, và token khoảng cách (`AppSpacing.xs/sm/md/lg`).
2. **Cấu trúc tokens gợi ý** (đặt tập trung, ví dụ `core/theme/`):
   - `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`.

## 3. ĐA NGÔN NGỮ (LOCALIZATION - L10N)
- Nếu dự án đa ngôn ngữ: dùng giải pháp l10n đã chọn (ví dụ `flutter_localizations` + `.arb`, hoặc `slang`).
- **CẤM hardcode chuỗi hiển thị** trực tiếp trong UI; luôn gọi qua khóa dịch (ví dụ `context.l10n.keyName`). Bổ sung đủ key cho mọi ngôn ngữ được hỗ trợ.

## 4. RESPONSIVE & LAYOUT
- Dùng `MediaQuery`/`LayoutBuilder`/`Flexible` để co giãn hợp lý trên nhiều kích thước (điện thoại, tablet, web/desktop nếu có).
- Tránh lỗi `RenderFlex overflowed`; form/list dài phải nằm trong vùng cuộn phù hợp (xem `rules/17`).

## 5. CHUẨN ĐỊNH DẠNG TÀI NGUYÊN ĐỒ HỌA (ASSETS)
1. **SVG (`.svg`)**: **CHỈ** dùng cho asset độ phức tạp thấp (system/action icons, glyphs đơn sắc/2 màu), qua `flutter_svg`. Không dùng SVG cho tranh minh họa phức tạp (parse runtime tốn CPU/GPU gây jank).
2. **WebP (`.webp`)**: **Ưu tiên** cho asset phức tạp cao (illustrations, banner, background, empty-state). Xuất PNG chất lượng cao rồi convert sang WebP để giảm 30–70% dung lượng và giải mã phần cứng nhanh.
3. **Khai báo tập trung**: gom đường dẫn vào `AppIcons`/`AppImages`/`AppIllustrations` (ví dụ `core/constants/app_assets.dart`); **CẤM** hardcode chuỗi path trong Widget.

## 6. QUY TẮC BẮT BUỘC
- ✅ Dùng design tokens & l10n keys; asset đúng định dạng & khai báo tập trung.
- ❌ **CẤM** hardcode màu/spacing/font/chuỗi hiển thị/đường dẫn asset.

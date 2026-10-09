# 🧩 PATTERNS — MẪU HÌNH KIẾN TRÚC TÙY CHỌN (OPT-IN)

> Thư mục này chứa các **mẫu hình kiến trúc nâng cao**, **KHÔNG bật mặc định**. Mỗi dự án tự quyết định bật hay không thông qua khai báo trong `PROJECT_STACK.md` (mục **3. MẪU HÌNH KIẾN TRÚC TÙY CHỌN**).

## 📌 Nguyên tắc

- Bộ `rules/` là **nguyên tắc phổ quát** áp dụng cho mọi dự án Flutter.
- `patterns/` là **lựa chọn kiến trúc** chỉ áp dụng khi dự án thực sự cần → tránh áp đặt phức tạp không cần thiết lên dự án nhỏ/đơn giản.
- Khi một pattern được bật trong `PROJECT_STACK.md`, AI Agent **BẮT BUỘC** tuân thủ đầy đủ tài liệu pattern tương ứng và ghi lại quyết định thành ADR trong `memory/architecture-decisions.md`.

## 📚 Danh mục Pattern

| Pattern | File | Khi nào bật? |
|---|---|---|
| **Offline-First + Outbox Sync** | [offline-first-outbox.md](offline-first-outbox.md) | Ứng dụng phải hoạt động mượt khi mất mạng, cần đồng bộ hai chiều an toàn giữa Local DB và Server (ví dụ: app hiện trường, app dùng trong tầng hầm/thang máy, app nhập liệu ngoại tuyến). |

> ➕ Có thể bổ sung thêm pattern khác trong tương lai (Background periodic jobs, Push/Deep-link, Multi-flavor...) theo nhu cầu chung của nhiều dự án.

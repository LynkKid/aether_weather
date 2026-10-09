# 🧠 MEMORY — BỘ NHỚ AI (PER-PROJECT)

> Khi bộ quy tắc dùng chung được copy vào một dự án, thư mục `memory/` trở thành **bộ nhớ riêng của dự án đó**. Nó giúp Agent tiết kiệm token và học hỏi liên tục từ con người (xem `rules/14`).

## 📂 Thành phần

| File | Vai trò | Khi nào ghi |
|---|---|---|
| [architecture-decisions.md](architecture-decisions.md) | **ADR** — nhật ký quyết định kiến trúc & lựa chọn stack | Khi chốt/đổi công nghệ, pattern, quy ước lớn |
| [context-cache.md](context-cache.md) | Tóm tắt module phức tạp để **không phải quét lại nhiều file** | Sau khi hoàn thành module độ phức tạp trung bình–cao |
| [human-learnings.md](human-learnings.md) | Nhật ký bài học khi **con người can thiệp/sửa code** của Agent | Mỗi khi Human sửa code hoặc góp ý chấn chỉnh |

## 🔁 Cơ chế hoạt động

1. **Đọc trước khi code**: Đầu mỗi task, Agent đọc `context-cache.md` + `architecture-decisions.md` **trước** khi quét sâu source code → tiết kiệm token, tránh tràn context.
2. **Ghi sau khi làm**: Hoàn thành module phức tạp → tự động thêm tóm tắt vào `context-cache.md`.
3. **Học từ Human**: Khi con người sửa code Agent → phân tích diff, đúc kết bài học, ghi vào `human-learnings.md`; các task sau đọc lại để không tái phạm.

> ⚠️ Memory phản ánh trạng thái **tại thời điểm ghi**. Nếu một mục nhắc tới file/hàm/flag cụ thể, hãy xác minh nó còn tồn tại trước khi dựa vào.

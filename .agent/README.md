# 📚 code_base_rules_ai — BỘ QUY TẮC AI DÙNG CHUNG CHO DỰ ÁN FLUTTER

Bộ tri thức & quy tắc kỹ thuật **trung lập về stack**, dùng lại được cho **nhiều dự án Flutter khác nhau**. Khác với bộ rule gắn cứng một dự án cụ thể, bộ này tách bạch:

- **Nguyên tắc phổ quát (bất biến)** → nằm trong `rules/`.
- **Lựa chọn công nghệ (biến số theo dự án)** → khai báo trong `PROJECT_STACK.md` của từng dự án.

## 🚀 Bắt đầu nhanh (adopt vào 1 dự án)

1. Copy thư mục này vào dự án (khuyến nghị đổi tên thành `.agent/`), hoặc thêm dưới dạng git submodule để tái sử dụng và cập nhật tập trung.
2. `cp PROJECT_STACK.template.md PROJECT_STACK.md` rồi điền stack (state management, DB, network, DI, model, error type, ID, có/không offline-first...).
3. Chỉ vào file entry cho công cụ AI của bạn (ví dụ để `AGENTS.md` ở root, hoặc trỏ Cursor/Windsurf/Claude Code tới nó).
4. Ghi các quyết định stack thành ADR trong `memory/architecture-decisions.md`.
5. (Tùy chọn) Khi khởi tạo dự án: áp `templates/analysis_options.yaml`, `templates/ci_workflow.yaml`, `templates/lefthook.yml`.

## 📂 Thành phần

- **[AGENTS.md](AGENTS.md)** — Điểm nhập cuộc, Golden Rules, bản đồ thư mục.
- **[PROJECT_STACK.template.md](PROJECT_STACK.template.md)** — Cơ chế khai báo stack (cốt lõi để dùng chung).
- **[rules/](rules/)** — 21 quy tắc trung lập stack (kiến trúc, state, data, network, DI, coding, code-gen, security, logging, UI/l10n, testing, git, research/anti-hallucination, memory, isolate, async UX, widget mastery, CI/CD, timezone, a11y).
- **[patterns/](patterns/)** — Mẫu hình kiến trúc tùy chọn (bật theo `PROJECT_STACK.md`), gồm Offline-First + Outbox.
- **[skills/](skills/)** — Kỹ năng thực hành: feature-scaffold, flutter-widget-optimizer, security-auditor, test-writer, ui-mockup-designer.
- **[workflows/](workflows/)** — Quy trình: new-feature, fix-bug, code-review-gate.
- **[templates/](templates/)** — Template trung lập stack: analysis_options, CI, lefthook, logger, failure.
- **[memory/](memory/)** — Bộ nhớ AI (ADR, context-cache, human-learnings) — copy & dùng riêng cho mỗi dự án.

## 🧭 Triết lý

> **Nguyên tắc là bất biến; công nghệ là biến số.** Bộ này giữ nguyên tắc kỹ thuật (áp dụng cho mọi stack); `PROJECT_STACK.md` giữ lựa chọn công nghệ của từng dự án.

## 🔗 Nguồn gốc

Bộ này được khái quát hóa từ một bộ rule chuyên biệt cho dự án Offline-First (Clean Architecture + BLoC + Drift + Dio/Retrofit). Toàn bộ tri thức chuyên biệt đó được giữ lại dưới dạng **pattern tùy chọn** (`patterns/offline-first-outbox.md`) và **ví dụ trong `PROJECT_STACK`**, không còn bị ép buộc mặc định.

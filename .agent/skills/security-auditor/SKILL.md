---
name: security-auditor
description: Quét & phát hiện lỗ hổng bảo mật, rò rỉ secret/token/key và vi phạm lưu trữ dữ liệu an toàn. Áp dụng cho mọi dự án Flutter.
---

# SKILL: KIỂM TOÁN BẢO MẬT & RÒ RỈ THÔNG TIN (SECURITY-AUDITOR)

Kích hoạt trước khi kết thúc task lớn hoặc trước khi tạo Commit/Pull Request để phát hiện rủi ro an ninh.

## 📋 DANH MỤC KIỂM TRA (SECURITY CHECKLIST)

### 1. Quét Hardcoded Secrets
Chủ động quét codebase để phát hiện:
- Chuỗi giống API Key (`AIza...`, `sk-...`, `Bearer ...`).
- URL chứa token/mật khẩu query: `https://api.example.com?token=...`.
- Private key RSA / Certificate nhúng trong mã nguồn.
- Base URL / client secret hardcode → chuyển sang `--dart-define` hoặc file env không commit.

### 2. Quét cơ chế lưu trữ
- Kiểm tra có code nào ghi trực tiếp `token`, `password`, `credentials` vào storage thường (SharedPreferences...) không → **bắt buộc chuyển sang secure storage** (theo lib đã chọn trong `PROJECT_STACK.md`, ví dụ `flutter_secure_storage`) (`rules/08`).
- Nếu local DB chứa dữ liệu nhạy cảm → cân nhắc mã hóa (theo giải pháp DB đã chọn).

### 3. Quét Logger & In ra console
- Tìm `print(` / `debugPrint(` trong `lib/` → thay bằng logger wrapper (`rules/09`).
- Đảm bảo interceptor/log network đã che các trường nhạy cảm:
  ```dart
  if (key == 'password' || key == 'token') {
    sanitizedMap[key] = '******';
  }
  ```

### 4. Kiểm tra .gitignore
Đảm bảo đã ignore:
- File môi trường (`.env`, `*.env`).
- Keystore/signing (`*.keystore`, `*.jks`, `key.properties`).
- Credentials nền tảng (`google-services.json`, `GoogleService-Info.plist`) nếu chứa secret production.

### 5. Kết nối mạng
- Chỉ dùng `HTTPS`. Cân nhắc SSL Pinning ở Production.
- Xóa sạch token/cache/DB khi đăng xuất hoặc khi 401 không thể refresh.

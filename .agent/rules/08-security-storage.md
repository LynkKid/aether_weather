# RULE 08: BẢO MẬT & LƯU TRỮ DỮ LIỆU AN TOÀN

## 1. LƯU TRỮ THÔNG TIN NHẠY CẢM
1. **Token & mật khẩu**:
   - Mọi thông tin nhạy cảm (`accessToken`, `refreshToken`, `encryptionKey`, `pinCode`...) **bắt buộc** lưu trong secure storage (ví dụ: `flutter_secure_storage` — Keychain trên iOS, Keystore/EncryptedSharedPreferences trên Android).
   - **CẤM** lưu token/mật khẩu vào `SharedPreferences` thường hoặc file/DB không mã hóa.
2. **Mã hóa Database cục bộ** (nếu dự án lưu dữ liệu nhạy cảm offline):
   - Dùng cơ chế mã hóa của DB đã chọn (ví dụ `sqlcipher_flutter_libs` cho SQLite, hoặc mã hóa của Isar/Hive). Key mã hóa sinh ngẫu nhiên và lưu trong secure storage.

## 2. QUẢN LÝ BIẾN MÔI TRƯỜNG & SECRETS
1. **Cấm hardcode credentials**:
   - Không hardcode API keys, Base URLs, Client Secrets, JWT secrets trong code Dart.
   - Dùng `.env` (ví dụ `flutter_dotenv`) hoặc compile-time flags `--dart-define` / `--dart-define-from-file`.
2. **Bảo vệ Git repository**:
   - `.env`, keystore (`*.jks`, `*.keystore`), credentials (`google-services.json`, `GoogleService-Info.plist`) chứa secret production phải nằm trong `.gitignore`.

## 3. AN TOÀN KẾT NỐI MẠNG
- Chỉ giao tiếp qua `HTTPS`.
- Ở Production, cân nhắc SSL/Certificate Pinning theo client HTTP đã chọn.
- Xóa sạch token + cache + database khi người dùng **Đăng xuất** hoặc khi nhận 401 không thể refresh.

## 4. QUY TẮC BẮT BUỘC
- ✅ Token → secure storage; secret → env/define; xóa sạch khi logout.
- ❌ **CẤM** commit secret/private key/token vào git.
- ❌ **CẤM** để sót token cũ sau khi đăng xuất.

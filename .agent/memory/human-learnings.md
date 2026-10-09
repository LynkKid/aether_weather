# 🧑‍💻 HUMAN INTERVENTIONS & LEARNING LOG (NHẬT KÝ HỌC TẬP TỪ CON NGƯỜI)

> **MỤC ĐÍCH**: Khi con người (người dùng/lập trình viên) trực tiếp sửa code của Agent, đảo ngược quyết định, hoặc góp ý chấn chỉnh:
> 1. Agent phân tích khác biệt (Diff Analysis).
> 2. Đúc rút bài học (Lesson Learned) và ghi vào file này.
> 3. Agent **BẮT BUỘC ĐỌC FILE NÀY** trước mỗi task để không lặp lại sai lầm cũ.

---

## 📋 MẪU GHI NHẬN (LEARNING ENTRY TEMPLATE)

```markdown
### [YYYY-MM-DD] - [Chủ đề / Feature can thiệp]
- **Hành động ban đầu của Agent**: [Code/giải pháp Agent đã tạo]
- **Sự can thiệp của Human**: [Điều chỉnh Human đã sửa]
- **Lý do & Nguyên nhân gốc rễ**: [Vì sao cách của Human tốt hơn / lỗi của Agent]
- **Bài học rút ra (Guardrail cho tương lai)**: [Chỉ thị cụ thể để không tái phạm]
```

---

## 📚 CÁC BÀI HỌC ĐÃ ĐÚC RÚT

*(Trống — sẽ được bổ sung khi con người can thiệp vào code của Agent trong quá trình phát triển dự án.)*

### 2026-10-05 - Quản lý State phức tạp với BLoC/Freezed (Từ dự án Songless)
- **Hành động ban đầu của Agent**: Quản lý nhiều cờ (flags) độc lập trong GameState (như isRevived, hintsUsed) mà quên copy đầy đủ trong các hàm emit, dẫn đến rò rỉ state cũ.
- **Sự can thiệp của Human / Qua Adversarial Testing**: Phải viết các bài test giả lập, stress-test (Adversarial test) để bắt các lỗi logic rò rỉ state.
- **Lý do & Nguyên nhân gốc rễ**: Khi State lớn, việc `.copyWith()` thủ công dễ sót trường nếu không cẩn thận, đặc biệt khi có các luồng bất đồng bộ như Game Timer, Ads, và IAP chen ngang.
- **Bài học rút ra (Guardrail cho tương lai)**: Đối với state Game / luồng phức tạp: 
  1. Luôn dùng `freezed` để generate `copyWith`.
  2. Gom nhóm các trường liên quan thành các Object nhỏ hơn (vd: `GameStats`, `GameConfig`) để giảm bề mặt lỗi.
  3. Bắt buộc có Stress Test / Adversarial Test cho các trạng thái biên.

### 2026-10-05 - Tích hợp IAP & Ads chặn nhau (Từ dự án Songless)
- **Hành động ban đầu của Agent**: Tải Ads và kiểm tra IAP Premium hoạt động song song, dẫn đến user Premium vẫn thỉnh thoảng bị load hoặc hiện Ads khi mạng chậm.
- **Sự can thiệp của Human / Qua Testing**: Gộp chung logic kiểm tra Premium trước khi request Ads. Nếu `isPremium == true`, huỷ toàn bộ tiến trình init Ads.
- **Lý do & Nguyên nhân gốc rễ**: Race condition giữa IAP Restore và Ad Load.
- **Bài học rút ra (Guardrail cho tương lai)**: Mọi logic liên quan đến Ads BẮT BUỘC phải await trạng thái IAP (Premium) một cách dứt điểm (Single Source of Truth) từ Local Storage hoặc IAP Stream trước khi gửi request tới mạng lưới quảng cáo.

### 2026-10-05 - Ngoại lệ API và Fallback (Từ dự án Songless)
- **Hành động ban đầu của Agent**: Dựa hoàn toàn vào dữ liệu API (iTunes) trả về chuẩn format, sập game khi `previewUrl` null.
- **Sự can thiệp của Human / Qua Testing**: Thêm cơ chế filter null và fallback (bỏ qua bài hát lỗi).
- **Lý do & Nguyên nhân gốc rễ**: API bên thứ 3 luôn tiềm ẩn sai số dữ liệu.
- **Bài học rút ra (Guardrail cho tương lai)**: Parse JSON / DTO luôn cần cơ chế fallback an toàn, không bao giờ force-unwrap (`!`) hoặc tin tưởng tuyệt đối vào schema bên thứ 3 (đặc biệt là link media).

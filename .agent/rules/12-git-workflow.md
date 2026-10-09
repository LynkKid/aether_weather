# RULE 12: QUY TRÌNH GIT & KẾ HOẠCH CÔNG VIỆC (GIT & PLANNING)

## 1. NGUYÊN TẮC LẬP KẾ HOẠCH (PLAN FIRST)
- Mỗi khi nhận yêu cầu tính năng/sửa lỗi:
  1. Phân tích kiến trúc hiện tại và xác định các file cần tạo/sửa.
  2. Xuất bản một Checklist các bước ngắn gọn, rõ ràng.
  3. Chỉ sửa code trong phạm vi đã xác định. **Không "tiện tay"** sửa/refactor file ngoài task.

## 2. QUY CHUẨN ĐẶT TÊN COMMIT (CONVENTIONAL COMMITS)
Khi người dùng yêu cầu/cho phép commit, định dạng:
```
<type>(<scope>): <mô tả ngắn gọn>
```
### Types hợp lệ
- `feat`: thêm tính năng mới.
- `fix`: sửa lỗi.
- `refactor`: tái cấu trúc không đổi hành vi.
- `test`: thêm/cập nhật test.
- `chore`: cấu hình, dependencies, script build.
- `docs`: tài liệu, README, rules.
- `perf` / `style` / `ci` / `build` / `revert`: theo chuẩn Conventional Commits.

### Scope
- Phản ánh đúng tên module/feature (ví dụ: `auth`, `home`, `core`, `theme`, `sync`...).

## 3. QUYỀN HẠN GIT CỦA AGENT
- ❌ **CẤM** tự chạy `git commit` / `git push` khi người dùng chưa yêu cầu rõ ràng.
- ❌ **CẤM** chạy lệnh phá hủy dữ liệu: `git reset --hard`, `git clean -fd`.
- Khi được yêu cầu commit: xuất bản commit message đề xuất để người dùng xác nhận, hoặc thực hiện nếu đã có lệnh cụ thể.

## 4. QUY TẮC BẮT BUỘC
- ✅ Plan trước khi code; commit theo Conventional Commits; chỉ commit/push khi được phép.
- ❌ **CẤM** đổi/refactor ngoài phạm vi task; **CẤM** lệnh git gây mất mát dữ liệu.

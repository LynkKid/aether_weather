# Template Pre-commit Hook (lefthook) - TRUNG LẬP STACK
# Sao chép thành: lefthook.yml ở root, rồi chạy: dart run lefthook install
# Cưỡng chế cục bộ trước commit: format, analyze, chặn print(), chặn sửa tay file generated, conventional commits.
# Xem: rules/18-ci-cd-enforcement.md

pre-commit:
  parallel: true
  commands:
    format:
      glob: "*.dart"
      run: dart format {staged_files}
      stage_fixed: true

    analyze:
      run: flutter analyze --fatal-infos --fatal-warnings

    no-print:
      glob: "lib/**/*.dart"
      run: |
        if grep -nE '\b(print|debugPrint)\(' {staged_files}; then
          echo "❌ Phát hiện print()/debugPrint(). Hãy dùng logger wrapper (rules/09)."
          exit 1
        fi

    # Chặn sửa tay file generated. Điều chỉnh glob theo code-gen dự án dùng.
    no-manual-generated-edits:
      glob: "*.{g,freezed,gr,config}.dart"
      run: |
        echo "❌ Không được sửa tay file generated: {staged_files}"
        echo "   Sửa source rồi chạy: dart run build_runner build --delete-conflicting-outputs"
        exit 1

commit-msg:
  commands:
    conventional-commit:
      run: |
        PATTERN='^(feat|fix|refactor|test|chore|docs|perf|style|ci|build|revert)(\(.+\))?!?: .{1,}'
        if ! head -1 {1} | grep -qE "$PATTERN"; then
          echo "❌ Commit message không đúng Conventional Commits."
          echo "   Ví dụ: feat(auth): add login screen"
          exit 1
        fi

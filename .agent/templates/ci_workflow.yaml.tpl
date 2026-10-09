# Template CI Pipeline (GitHub Actions) - TRUNG LẬP STACK
# Sao chép thành: .github/workflows/ci.yml khi khởi tạo dự án.
# Cưỡng chế: format sạch, analyze 0/0/0, test + coverage. Bước code-gen chỉ bật nếu dự án dùng build_runner.
# Xem: rules/18-ci-cd-enforcement.md

name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  quality-gate:
    name: Quality Gate (Analyze + Test)
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: "3.x"   # Ghim theo dự án
          cache: true

      - name: Install dependencies
        run: flutter pub get

      # (TÙY CHỌN) Chỉ bật nếu dự án dùng build_runner. Nếu không, xóa 2 bước code-gen liên quan.
      - name: Run code generation
        run: dart run build_runner build --delete-conflicting-outputs
        # if: hashFiles('build.yaml') != '' # hoặc điều kiện phù hợp dự án

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze --fatal-infos --fatal-warnings

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Check coverage threshold
        run: |
          if [ ! -f coverage/lcov.info ]; then
            echo "::error::Không tìm thấy coverage/lcov.info"; exit 1
          fi
          COVERED=$(grep -c '^DA:.*,[1-9]' coverage/lcov.info || echo 0)
          TOTAL=$(grep -c '^DA:' coverage/lcov.info || echo 1)
          PCT=$(awk "BEGIN {printf \"%.1f\", ($COVERED/$TOTAL)*100}")
          echo "Line coverage: $PCT% ($COVERED/$TOTAL)"
          MIN=70.0   # Điều chỉnh theo PROJECT_STACK.md
          if awk "BEGIN {exit !($PCT < $MIN)}"; then
            echo "::error::Coverage $PCT% dưới ngưỡng $MIN%"; exit 1
          fi

      # (TÙY CHỌN) Chỉ bật nếu dùng code-gen: đảm bảo file generated đồng bộ với source đã commit.
      - name: Ensure generated files are up-to-date
        run: |
          if ! git diff --exit-code --stat; then
            echo "::error::File generated bị lệch. Hãy chạy build_runner và commit lại."; exit 1
          fi

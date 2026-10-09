# Template analysis_options.yaml chuẩn Enterprise (0 Errors, 0 Warnings) - TRUNG LẬP STACK
# Áp dụng bộ linter nghiêm ngặt khi khởi tạo dự án.
# Điều chỉnh phần `exclude` theo code-gen dự án thực sự dùng (nếu có).

include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
    invalid_annotation_target: ignore

  # Loại trừ file sinh tự động — điều chỉnh theo code-gen dự án dùng (freezed/json/drift/...).
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gr.dart"        # auto_route (nếu dùng)
    - "**/*.config.dart"    # injectable (nếu dùng)
    - "**/generated/**"
    - "**/generated_plugin_registrant.dart"

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    unnecessary_const: true
    prefer_final_fields: true
    prefer_final_locals: true
    unawaited_futures: true
    avoid_void_async: true
    avoid_unnecessary_containers: true
    prefer_single_quotes: true
    always_declare_return_types: true
    avoid_relative_lib_imports: true
    prefer_is_empty: true
    prefer_is_not_empty: true
    prefer_iterable_whereType: true
    annotate_overrides: true
    empty_constructor_bodies: true
    use_build_context_synchronously: true
    sized_box_for_whitespace: true

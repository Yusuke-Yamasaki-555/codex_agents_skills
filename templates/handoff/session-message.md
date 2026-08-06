# Session Handoff Message

```yaml
message_type: <implementation_result|review_result|task_assignment|blocked>
source_role: <project_management|implementation|review>
target_role: <project_management|implementation|review>
issue: <number>

summary: >
  <結果の要約>

intent:
  - <判断と理由>

changes:
  - <変更箇所>

validation:
  local:
    - <command or check>
  ci:
    - <workflow/check>
  result: <passed|failed|not_run>

requirement_coverage:
  - REQ-F-001

new_problems: []

review_focus:
  - <確認してほしい点>

next_action:
  - <次に必要な処理>
```

主要な決定、理由、成果、検証、未解決事項を省略しない。内部の逐語的な思考過程は記録せず、他セッションと人間が判断を再現できる情報を残す。

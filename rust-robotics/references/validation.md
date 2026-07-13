# Rust workspaceの検証

品質契約と変更範囲に応じて必要なものを選ぶ。

```bash
cargo fmt --all -- --check
cargo test --workspace
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo check --workspace
git diff --check
```

- 公開APIの正常系、異常系、非有限値、境界値を確認する。
- feature組合せを変更した場合は、影響するfeatureを個別または`--all-features`で確認する。
- モデルや外部サービスを必要とするテストは、純粋な単体テストと分離する。
- 重いworkspace検証の前に対象packageまたは対象testで早期に失敗を検出する。

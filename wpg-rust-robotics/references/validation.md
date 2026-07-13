# 検証

品質契約で選んだ範囲に応じ、次から必要な検証を組み合わせる。

## 数値とAPI

- 正常入力の固定値または物理的に妥当な応答
- 非有限値、欠落、重複、範囲外、周期不整合の拒否
- 名前と内部アドレス、列、値の対応
- 期待するサンプル数、開始・終了時刻、センサ次元
- 出力が有限値で、制御入力と目標がlimit内であること
- 目標入力に対し対象関節が妥当な方向へ応答すること
- free jointとball jointが能動関節列へ混入しないこと

純粋関数の単体テストと、実MJCFを読む統合テストを分ける。GUI表示をテスト結果で推測せず、
viewerはWaylandなど実際の対象環境で短時間確認する。

## ローカル検証

通常のworkspace検証候補は次の通り。品質契約と変更範囲に合わせて絞る。

```bash
cargo fmt --all -- --check
cargo test --workspace
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo check --workspace
git diff --check
```

重いモデル依存テストは、まず対象テストだけを実行する。全検証をCIに委ねる場合も、ローカルで
formatter、静的check、変更対象テストのうち短時間なものを先に実行し、CI失敗の往復を減らす。

## CI

- CIの依存バージョン、checksum、外部モデルcommitを固定する。
- 依存とビルド成果物をcacheし、成功時ログとartifactを必要最小限にする。
- 現行WPGでは`master`向けPull Requestを統合判定の入口とし、pushとの二重実行を避ける。
- ローカルでは短い対象検証、PRではworkspace全体という役割分担で、保証とセッショントークンを両立する。
- CI結果はcheck名、成否、失敗箇所、URLを報告し、全ログを再掲しない。

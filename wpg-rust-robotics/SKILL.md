---
name: wpg-rust-robotics
description: dora_walking_pattern_generatorと同種のRust歩行ロボティクス開発を支援する。LIPMなどの計算コア、ROS 2/C++からRustへの移植、MuJoCo Cassie制御、Doraノード、dat/CSV/グラフ出力、Cargo workspace、モデル依存テストを実装・レビューするとき、またはユーザーがWPG Rustロボティクス手順を明示したときに使用する。
---

# WPG Rustロボティクス

共通の品質契約、長時間処理、出力、Git規則は対象リポジトリの`AGENTS.md`に従う。
ここではWPG固有の判断と参照先だけを扱う。

## 作業手順

1. workspace、関連Issue、既存差分、移植元、モデル取得方法を確認する。
2. 入出力、単位、周期、座標系、互換性、既知の欠陥を整理する。
3. 物理的意味やテスト可能性が曖昧なら、実装前にユーザーと確定する。
4. 純粋な計算コアとMuJoCo、Dora、保存、描画の副作用境界を分ける。
5. 値型、入力検証、計算、状態遷移、出力構築の順に実装する。
6. 純粋関数テスト、モデル依存テスト、GUI確認を別々に行う。
7. 品質契約の範囲でworkspaceを検証し、変更と結果を要約する。

## 参照資料の選択

必要な資料だけを読む。各資料はこのファイルから直接参照し、参照間を連鎖的に読み進めない。

- 計算コア、Rust API、ROS 2移植、Dora境界を扱う場合は
  [architecture.md](references/architecture.md)を読む。
- Cassie、MJCF、PD制御、関節・センサ出力、MuJoCo環境を扱う場合は
  [mujoco-cassie.md](references/mujoco-cassie.md)を読む。
- dat/CSV、グラフ、リアルタイムロガーを扱う場合は
  [logging.md](references/logging.md)を読む。
- テスト範囲、数値回帰、GUI確認、CI活用を決める場合は
  [validation.md](references/validation.md)を読む。
- Issue、branch、PR、commit、pushを扱う場合は
  [github-workflow.md](references/github-workflow.md)を読む。

## 常に守るWPG固有条件

- 計算ライブラリへMuJoCo、Dora、描画、ファイル保存の依存を持ち込まない。
- 制御目標とシミュレーション状態の強制代入を区別する。
- free jointとball jointを1自由度の能動関節列に含めない。
- 単位、座標系、サンプル時刻、名前と値の対応を公開境界で明示する。
- MJCFやアセットのライセンスと上流履歴を保ち、無断で本体リポジトリへ複製しない。
- 暫定二足制御では、単に「転倒しないこと」を合格条件にしない。
- GUI表示を単体テストで判定せず、数値検証と短時間のviewer確認を分離する。

## 現行プロジェクトの情報源

バージョンや固定commitはこの文書へ重複記載せず、次を正とする。

- Rust依存: `Cargo.toml`と各クレートの`Cargo.toml`
- MuJoCo、menagerie、CI依存: `.github/workflows/ci.yml`
- ローカル起動とモデル取得: `README.md`
- 実装済みAPIと期待動作: ソースコードとテスト

情報源の値を変更した場合は、相互の整合性と再現性を確認し、必要な文書だけを更新する。

---
name: rust-robotics
description: Rustによるロボティクス計算コアとworkspace設計を支援する。物理量の値型、Resultによる失敗、状態遷移、Cargo workspace、クレート分割、数値入力検証、Rust API、テストを実装、変更、レビューするときに使用する。
---

# Rustロボティクス

共通規則は対象リポジトリの`AGENTS.md`に従い、ここではRust固有の判断を扱う。

## 作業手順

1. workspace構成、公開API、依存、既存差分、MSRVやtoolchain設定を確認する。
2. 物理量、単位、座標系、状態、失敗を名前付きの型として設計する。
3. 純粋な計算と外部I/Oをクレートまたはモジュール境界で分離する。
4. 公開境界の検証と計算を実装し、正常系・異常系・数値境界をテストする。
5. 品質契約に応じてformatter、対象テスト、Clippy、workspaceを検証する。

## 参照資料

- API、値型、クレート境界を扱う場合は[architecture.md](references/architecture.md)を読む。
- Rust workspaceの検証範囲を決める場合は[validation.md](references/validation.md)を読む。

## 常に守る条件

- 外部入力の非有限値、範囲、欠落、重複、周期不整合を公開境界で検証する。
- 失敗を呼び出し側が判断できる`Result`とエラー型で表す。
- ライブラリ固有型を計算コアの公開APIへ無用に漏らさない。
- `unsafe`を使う場合は安全条件と根拠を記録する。

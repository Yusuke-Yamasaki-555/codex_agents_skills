---
name: mujoco-cassie
description: MuJoCoのCassieモデルをRustから制御・検証する。MJCF、mujoco_menagerie、能動関節、free joint、ball joint、アクチュエータ、センサ、PD制御、ctrlrange、viewer、モデル依存テストを実装、変更、レビューするときに使用する。
---

# MuJoCo Cassie

共通規則は対象リポジトリの`AGENTS.md`に従い、Rust計算コアには必要に応じて`$rust-robotics`も使う。

## 作業手順

1. MuJoCo本体、Rust binding、MJCF、asset、上流commit、ライセンスを確認する。
2. joint、actuator、sensorの名前、種類、アドレス、次元、rangeをMJCFから導出する。
3. 制御目標とシミュレーション状態を分け、PD計算をMuJoCo非依存にする。
4. 数値テスト、実MJCF統合テスト、短時間viewer確認を別々に行う。

## 参照資料

- モデル取得、状態出力、PD制御を扱う場合は[model-control.md](references/model-control.md)を読む。
- モデル依存テストとviewer確認を決める場合は[validation.md](references/validation.md)を読む。

## 常に守る条件

- 制御目標を`qpos`や`qvel`へ強制代入しない。
- free jointとball jointを1自由度の能動関節列へ含めない。
- controlをMJCFの`ctrlrange`へ制限する。
- MJCF、asset、LICENSE、上流履歴を保ち、無断で本体へ複製しない。
- GUI表示を単体テストの成功から推測しない。

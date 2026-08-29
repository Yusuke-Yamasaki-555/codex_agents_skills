# モデルと制御

## 環境と取得

- MuJoCo、Rust binding、モデルcommitはCargo設定とCIを正として互換性を確認する。
- `mujoco_menagerie`は独立cloneとし、必要なモデルだけをsparse-checkoutする。
- ローカルcloneを本体で追跡せず、可能ならCIと同じcommitを使う。
- Arch Linuxで`mujoco.pc`がない場合は、workspace設定の`MUJOCO_DYNAMIC_LINK_DIR`を確認する。

## 制御境界

```text
JointTarget + JointState + PD gains
  -> pure control calculation
  -> MotorCommand within ctrlrange
  -> MuJoCo step
  -> RobotState
```

- joint、actuator、sensorの名前、アドレス、次元をMJCFから取得する。
- 骨盤free jointは位置と`[w, x, y, z]`姿勢として能動関節と別に出力する。
- シミュレーション周期と制御周期を分け、整数ステップ数との整合性を検証する。
- 状態出力には時刻、名前付き関節状態、sensor、actuator、骨盤姿勢を含める。
- 具体的な関節数や周期を文書の固定値へ依存させない。

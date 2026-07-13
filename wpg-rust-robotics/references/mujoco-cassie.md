# MuJoCo Cassie

## 環境とモデル

- `mujoco-rs`とMuJoCo本体の互換性をCargo設定、上流情報、最小ビルドで確認する。
- Arch Linuxで`mujoco.pc`がない場合は、workspaceの`.cargo/config.toml`に
  `MUJOCO_DYNAMIC_LINK_DIR=/usr/lib`を設定する。
- バージョンとモデルcommitは`.github/workflows/ci.yml`を正とし、文書中の固定値に依存しない。
- `mujoco_menagerie`は独立cloneとし、`agility_cassie`だけをsparse-checkoutする。
- ローカルcloneを本体リポジトリで追跡せず、MJCF、アセット、LICENSEを上流のまま扱う。
- ローカル取得でも可能な限りCIと同じcommitをcheckoutする。探索目的でbranch先端を使う場合は差異を明示する。

```bash
git clone --filter=blob:none --no-checkout \
  https://github.com/google-deepmind/mujoco_menagerie.git mujoco_menagerie
git -C mujoco_menagerie sparse-checkout set agility_cassie
git -C mujoco_menagerie checkout <CIで固定したcommit>
```

## 制御境界

```text
JointTarget + JointState + PD gains
  → 純粋な制御計算
  → ctrlrange内のMotorCommand
  → MuJoCo更新
  → RobotState
```

- 関節角度・角速度の入力は制御目標として扱い、`qpos`や`qvel`へ強制代入しない。
- PD制御をMuJoCo非依存の純粋関数にし、controlをMJCFの`ctrlrange`へ制限する。
- 関節limit、アクチュエータ、センサの名前、アドレス、次元をMJCFから取得する。
- free jointとball jointを能動関節列へ含めない。
- 骨盤free jointは位置と`[w, x, y, z]`クォータニオンとして別出力にする。
- シミュレーション周期と制御周期を分け、整数ステップ数と整合性を検証する。

状態出力には、時刻、名前付き能動関節角度・角速度、全センサ値、全アクチュエータ状態、
骨盤位置・姿勢を含める。具体的な関節数や周期はMJCFと設定から導出し、文書の固定値へ依存しない。

## 確認用入力

- 可動域確認では`jnt_range`から中心と安全余裕を含む振幅を求める。
- 位置正弦波を使う場合、目標速度は解析微分から求める。
- 左右関節の位相、周波数、期間は、確認したい物理挙動を明示して決める。
- 目標値がlimit内であることと、対象関節が妥当な方向へ応答することを別々に検証する。

---
name: wpg-rust-robotics
description: Rust・Dora・MuJoCoによる歩行パターン生成とロボット制御を、関数型の計算コア、明確な副作用境界、モデル依存テスト、ロギング、GitHub Issue運用を保ちながら実装・改良する。ROS 2/C++からRustへの移植、LIPM軌道生成、MuJoCo Cassie制御、Doraノード境界、dat/CSV/グラフ出力、Cargo workspace整理、Issue駆動の実装・レビューを行うときに使用する。
---

# WPG Rustロボティクス

## 基本ワークフロー

1. リポジトリ、`AGENTS.md`、Issue、移植元、既存差分を確認する。
2. 入力、出力、単位、周期、座標系、互換性、既知の欠陥を整理する。
3. 曖昧な物理的意味やテスト困難な要件を指摘し、ユーザーと仕様を確定する。
4. 純粋な計算コアとMuJoCo、Dora、ファイル、描画などの副作用境界を分ける。
5. 値型、入力検証、計算、状態遷移、出力構築の順に実装する。
6. 純粋関数テストと実モデルを使うシミュレーションテストを分ける。
7. GUIは数値テストから分離し、Wayland上で短時間の起動確認を行う。
8. workspace全体を検証し、変更点、結果、コミット状態を報告する。

## 関数型の設計方針

次の流れがコードから読み取れるようにする。

```text
入力値
  → 検証
  → 正規化・制御・軌道計算
  → 出力値
  → MuJoCo更新／Dora通信／保存／描画
```

- 公開APIを名前付きの値型で表し、ライブラリ固有型を境界の外へ漏らさない。
- 外部状態を読まない計算を純粋関数として切り出す。
- 時間発展の状態を小さな値オブジェクトへまとめる。
- 可変状態を機械的に排除せず、状態遷移の物理的意味を優先する。
- `map`や`scan`の使用自体を目的にせず、数式との対応を明確にする。
- `Result`と具体的なエラー型で失敗を表現する。
- `NaN`、無限大、欠落、重複、周期比、単位の不整合を入力境界で拒否する。
- 時刻の累積加算を避けられる場合は、サンプル番号から時刻を算出する。
- 移植元との数値互換性が必要なら、固定値の回帰テストを保持する。
- 移植元の欠陥を再現しない場合は、安全な終了条件と差異をdoc commentへ記録する。

## Rustコードの可読性

- Rust初学者にも分かるよう、単位、座標系、配列要素、式の目的をdoc commentへ書く。
- コメントで構文を逐語訳せず、その判断や境界が必要な理由を書く。
- `main.rs`を入力準備とライブラリ呼び出しだけの薄い層にする。
- 計算ライブラリへgnuplot、ファイル保存、Dora、ROS 2依存を持ち込まない。
- 単体テストを`src/test.rs`または`src/tests.rs`へ分離する。
- 複数クレートをCargo workspaceで管理し、ルートの`Cargo.lock`を使用する。

## MuJoCo Cassie制御

### 環境とモデル

- `mujoco-rs 5.0.0`とMuJoCo 3.9.0を組み合わせる。
- Arch LinuxのAUR版が`mujoco.pc`を提供しない場合は、`.cargo/config.toml`で
  `MUJOCO_DYNAMIC_LINK_DIR=/usr/lib`を指定する。
- MJCFとアセットを本体リポジトリへコピーしない。
- `mujoco_menagerie`を独立したローカルcloneとして取得し、`agility_cassie`だけを
  sparse-checkoutする。

```bash
git clone --filter=blob:none --no-checkout \
  https://github.com/google-deepmind/mujoco_menagerie.git mujoco_menagerie
git -C mujoco_menagerie sparse-checkout set agility_cassie
git -C mujoco_menagerie checkout main
```

- `mujoco_menagerie/`を本体リポジトリでignoreする。
- `mujoco_menagerie/agility_cassie/scene.xml`を読み込む。

### 制御境界

```text
JointTarget + JointState + PD gains
  → compute_motor_commands
  → ctrlrange内のMotorCommand
  → CassieSimulation
  → RobotState
```

- 関節角度・角速度を状態へ直接代入せず、制御目標として扱う。
- PD制御をMuJoCo非依存の純粋関数として実装する。
- motor controlをMJCFの`ctrlrange`へ制限する。
- 関節、アクチュエータ、センサの名前、アドレス、次元、limitをMJCFから取得する。
- free jointとball jointを1自由度の能動関節列へ含めない。
- 骨盤free jointを位置と`[w, x, y, z]`クォータニオンとして別出力にする。
- MJCF既定の0.5 ms周期を検証し、10 msの制御周期ごとに20 step進める。

`RobotState`へ次を含める。

1. シミュレーション時刻
2. 10能動関節の名前付き角度
3. 10能動関節の名前付き角速度
4. MJCFで定義された全センサ値
5. 全アクチュエータのcontrol、length、velocity、force
6. 骨盤の位置とクォータニオン姿勢

## 正弦波入力とdatロギング

- MJCFの`jnt_range`から上下限を取得する。
- 正弦波の中心を上下限の中央にする。
- 可動半幅の95%を振幅とし、上下限に可動範囲全体の2.5%ずつ余裕を残す。
- 0.5 Hzで2秒間実行し、上限側と下限側を1周期で確認する。
- 左右膝へ同相の目標を与え、姿勢変化を見やすくする。
- 目標速度を位置正弦波の解析微分から求める。
- 制御周期10 msごとに全能動関節角度を記録する。
- 先頭行へ`time_s`と`<joint-name>_rad`を書き、空白区切りdatとして保存する。
- 2秒なら200サンプルとし、生成先の`logs/`をignoreする。

次をテストする。

- 0.5秒で上限近傍、1.5秒で下限近傍へ目標が到達する。
- 最初のサンプルが0.01秒、最後が2.00秒になる。
- datがヘッダー1行と200データ行になる。

## ロギング・可視化の分離

- 計算クレートから描画依存を削除する。
- ロガーを`lib.rs`と`main.rs`へ分ける。
- 入力データから描画系列への変換を純粋関数にする。
- PNG、CSV、dat出力を副作用関数に閉じ込める。
- 生成画像とログをignoreする。
- 制御データの受信周期と描画周期を分離する。
- 将来Doraを使う場合は、制御ノードとロガーノードを別プロセスにする。
- 表示用の間引きと完全記録用経路を必要に応じて分ける。

## テストと完了判定

最低限、次を確認する。

- 正常入力の固定値または物理的に妥当な応答
- 非有限値、欠落、重複、周期不整合の拒否
- 名前とMuJoCo内部アドレスの対応
- 期待するサンプル数、時刻、センサ次元
- 数秒間の全出力が有限値であること
- controlがlimit内であること
- 目標入力に対して対象関節が妥当な方向へ応答すること
- free jointとball jointが能動関節列へ混入しないこと

二足ロボットの暫定コントローラでは、単純に「転倒しないこと」を合格条件にしない。
GUI表示を単体テストで判定せず、viewerの起動確認を別に行う。

```bash
cargo fmt --all -- --check
cargo test --workspace
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo check --workspace
git diff --check
```

## GitHub Issue運用

1. Issue本文と全コメントを読む。
2. 仕様確定後、許可がある場合だけ実装計画をIssueへコメントする。
3. 方針変更をIssueへ追記する。
4. 実装、テスト、viewer確認の結果をIssueへコメントする。
5. ユーザー確認前はcommitしない。
6. 明示指示後だけ対象ファイルをstageし、commit・pushする。
7. コミットIDとpush先をIssueへ追記する。
8. Issueを無断でcloseしない。

既存のユーザー差分を必ず保持する。commit、push、Issueコメント、PR作成を依頼から推測して
実行しない。ユーザーがcommitとpushだけを求めた場合はPRを作らない。

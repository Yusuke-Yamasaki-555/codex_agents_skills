---
name: project-planning
description: GitHub Projectを使う開発について、目的、要件、設計、Issue、依存関係、検証方法、Pull Request構成を実行可能な計画へ変換する。新規プロジェクトやMilestoneの計画、既存計画の再編、巨大な変更のIssue・PR分割、Stacked PRの事前設計を行うときに使用する。
---

# Project Planning

ユーザーと合意した開発目標を、別セッションが会話履歴なしで着手できるGitHub Projectとリポジトリ内成果物へ変換する。実装の自律実行や完了判定は担当しない。

## 原則

- 上位指示、リポジトリ固有規則、ユーザーが指定した承認境界を優先する。
- 複数セッションを必須にしない。規模、独立性、利用可能な機構から有効な場合だけ分担する。
- GitHub Projectを進捗の計器盤として使い、会話ログの保管場所にしない。
- 同じ情報を複数箇所へ複製せず、正本へリンクする。
- 計画作成とGitHub・ファイルへの書き込みを分け、書き込みは明示的な許可範囲だけで行う。

## 正本

情報種別ごとに正本を一つにする。

- 目的、要件、設計、ADR: リポジトリ内文書
- 作業範囲、受け入れ条件、依存関係: Issue
- 優先度、担当、進行状態、Blocked: GitHub Project
- 実装差分、レビュー判断: Pull Request
- 検証結果: 対象commitに紐づくCIとPull Request
- 監督レポート: 上記から生成する派生スナップショット

## ワークフロー

1. リポジトリ規則、既存計画、Issue、Pull Request、CI、ユーザー差分を確認する。
2. 目的、成功条件、対象範囲、対象外、制約、人間の承認が必要な判断を合意する。
3. 機能要件と非機能要件へ一意なIDと検証可能な受け入れ条件を付ける。
4. 主要な責務、境界、データフロー、失敗条件、検証戦略を設計する。
5. 単独の受け入れ条件を持ち、担当範囲を区別できるIssueへ分解する。
6. Issue間の依存関係、予定変更範囲、検証方法、レビュー境界を記録する。
7. Pull Request構成を通常PR、Stacked PR、独立した複数スタックから選ぶ。
8. GitHub Project、Milestone、Issue、必要な文書を許可範囲内で作成する。
9. `assets/planning-completion-checklist.md`で処理期へ渡せるか確認する。

テンプレートを生成物へコピーするときだけ`assets/`から必要なものを選ぶ。不要な文書を一律に作らない。

## Issueの粒度

次をすべて満たす単位をIssueとする。

- 単独の受け入れ条件を持つ。
- 単独でレビュー可能である。
- 他Issueと担当範囲を区別できる。

独立した優先順位、担当変更、後日再開、ユーザー判断、複数成果物への影響のいずれも不要な細部は、親Issueのチェックリストに留める。

## GitHub Projectの最小構成

既存Projectの運用がある場合はそれを優先する。新規Projectでは過剰な同期項目を作らず、最低限次を持たせる。

- Status: `Backlog`、`Ready`、`In Progress`、`Review`、`Blocked`、`Done`
- MilestoneまたはIteration
- Priority
- Requirement IDs
- Decision required

依存関係はGitHubのIssue関係またはSub-issueを正本とし、Projectの自由記述フィールドへ重複させない。Pull RequestはIssueのDevelopmentリンクを正本とし、Stack内の順序とbaseはPull Request本文と実際のbase branchから確認する。

- `Ready`: 受け入れ条件、依存、変更境界、検証方法が明確で、未完了の前提がない。
- `In Progress`: 担当と着手対象が明確である。
- `Review`: 対象PRと最新commitのローカル検証が提示されている。
- `Blocked`: 継続不能な原因、判断者、解除条件、戻り先が記録されている。
- `Done`: 受け入れ条件、必要なレビュー、最新commitの必須CI、依存PRがすべて満たされている。

依存先の未完了だけで作業不能なら`Blocked`ではなく`Backlog`に置く。開始後に仕様不足、外部障害、未解決の下位PRなどで継続不能になった場合だけ`Blocked`を使う。

## Pull Request構成

### 通常PR

変更が一つの関心事で、依存レイヤーへ分けてもレビュー価値が増えない場合に使う。

### Stacked PR

一つの変更ストーリーに、順序依存する複数の関心事がある場合に使う。実装開始前にtrunkから上へレイヤーを設計し、各レイヤーへ一つのレビュー可能なPRを割り当てる。

例:

`main <- feature/types <- feature/core <- feature/dora-node <- feature/integration`

- 基盤となる型、スキーマ、公開契約を下へ置く。
- 上位レイヤーは直下のレイヤーだけをbaseにする。
- 各レイヤーを一文で説明できる単一の関心事にする。
- 各PRに要件ID、Stack内の位置、base PR、依存理由、単独検証、最終統合検証を記録する。
- 無関係または並列可能な変更は同じStackへ入れず、別Issueまたは別Stackにする。
- 最上位に統合テストだけを置く場合でも、下位PRの単体検証を省略しない。

公式`gh stack`が利用可能なら、実装担当へ次の非対話的な基本経路を提示する。

公式`gh-stack` Skillも利用可能なら併用し、コマンドの前提、非対話フラグ、復旧手順はその現行版を優先する。

```text
gh stack init <bottom-branch> [upper-branch...]
gh stack add <branch>
gh stack submit --auto
gh stack view --json
```

複数remoteでは書き込み系コマンドへ`--remote <name>`を付けるか、`remote.pushDefault`を設定する。`gh stack`が未導入または対象リポジトリで無効なら、同じbase連鎖を通常のGit branchとPull Requestで表現し、その事実を計画へ記録する。

`submit`、`push`、`sync`、`rebase`、`link`、`merge`は外部状態または履歴を変更する。計画Skillから実行せず、ユーザーとリポジトリ規則が許可した実装・公開工程へ渡す。

## 計画完了条件

- 目的、範囲、対象外、成功条件が明記されている。
- 要件と受け入れ条件が検証可能である。
- 主要設計と責務分担が記録されている。
- Issue間の依存関係と変更予定範囲が明示されている。
- 要件、Issue、PR計画、テストの対応が追跡可能である。
- PRまたはStackの各レビュー境界と統合検証が定義されている。
- 人間の判断が必要な条件が記録されている。
- 未確定事項は決定済みとして扱わず、調査IssueまたはBlocked条件になっている。

## 成果物

必要に応じて以下を作成する。

- `assets/project-overview.md`
- `assets/requirements.md`
- `assets/design.md`
- `assets/traceability.md`
- `assets/milestone.md`
- `assets/issue.md`
- `assets/adr.md`
- `assets/planning-completion-checklist.md`

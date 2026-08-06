# Project Planning Skill

## Purpose

ユーザーとの対話を通じて要件定義と設計を確定し、GitHub Project・Milestone・Issue群として実行可能な開発計画へ変換する。

## Parent Session

議論役セッションを親とする。

## Child Session

タスク分解役セッション。

## Responsibilities

### 議論役

- ユーザーの目的、背景、制約、対象範囲、対象外を確認する。
- 機能要件・非機能要件・受け入れ条件を定義する。
- 設計上の重要判断をユーザーと合意する。
- 仕様変更を伴う判断は必ずユーザーへ確認する。
- 確定事項、未確定事項、判断理由を構造化してタスク分解役へ渡す。

### タスク分解役

- 要件と設計をMilestone、Issue、Sub-issueへ分解する。
- 各Issueへ要件ID、成果物、受け入れ条件、依存関係、予定変更範囲、検証方法を記載する。
- 単独の受け入れ条件を持ち、単独レビュー可能で、担当範囲を区別できる作業をIssue化する。
- 細かな実装手順はIssue内チェックリストとする。
- 技術的不確実性は予備実験Issueとして分離する。
- 並列化候補は、変更対象となるインターフェース、ファイル、データ構造、設計判断が競合しない範囲で示す。

## Required Outputs

- `docs/project/overview.md`
- `docs/project/requirements.md`
- `docs/design/design.md`
- `docs/project/traceability.md`
- GitHub Project
- 対象Milestone
- 実行可能なIssue / Sub-issue
- 必要に応じたADR

## Handoff Rule

策定期と処理期では会話メモリを前提にしない。処理期が会話履歴なしで開始できるよう、正式な決定事項をGitHubおよびリポジトリ内文書へ残す。

同一期内の通信は親セッション経由を第一選択とする。明示的なセッション通信機構が利用可能な場合でも、主要な決定・理由・成果・検証・未解決事項はGitHubへ要約して記録する。

## Planning Completion Gate

次を満たすまで処理期へ移行しない。

- プロジェクト目的、範囲、対象外が明記されている。
- 要件に一意なIDがある。
- 主要設計と責務分担が記載されている。
- Milestoneのゴールと完了条件が定義されている。
- 各Issueに受け入れ条件がある。
- Issue間の依存関係と変更予定範囲が記録されている。
- テスト方針と人間承認条件が記載されている。
- 要件とIssueの対応関係が追跡可能である。

## Human Approval

次の場合はユーザー確認を必須とする。

- 要件変更
- 外部仕様変更
- 設計の本質的変更
- Milestoneのゴール変更
- スコープ縮小
- 受け入れ条件の本質的な緩和

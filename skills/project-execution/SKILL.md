# Project Execution Skill

## Purpose

策定済みGitHub Projectと対象Milestoneを受け取り、実装、レビュー、CI、テスト完遂まで進行する。

## Session Structure

Project管理役を親セッションとする。

- Project管理役（親）
  - 実装役
  - レビュー役

## Project管理役

### Responsibilities

- GitHub Project、Milestone、要件、設計、Issue群を読み込む。
- `Ready`のIssueから着手可能なものを選ぶ。
- Issueを予約し、担当セッションと開始状況をGitHubへ記録する。
- 変更対象が競合しないIssueのみ並列に割り当てる。
- 実装役とレビュー役の受け渡しを統括する。
- Issue、Sub-issue、コメント、状態、ラベル、担当者、依存関係を管理する。
- 仕様不足、設計の本質的変更、mainへのマージが必要な場合はユーザーへ通知する。
- レビュー役の合否とCI結果をもとにIssueを完了させる。
- 対象Issueがすべて完了し、未解決問題がなく、完了条件を満たした場合にMilestone完了を判定する。

### State Authority

正式なProject状態の変更はProject管理役のみが行う。

基本状態:

`Backlog → Ready → In Progress → Review → Done`

通常のレビュー修正は `Review → In Progress` とする。

`Blocked`は、実装役だけでは解消できない仕様不足、外部依存、技術的障害などに限定する。

## 実装役

- Issue、要件、設計、依存関係、変更予定範囲を確認する。
- 実装前に具体的な変更予定範囲をProject管理役へ報告する。
- コード、テスト、文書、設定などの成果物を作成する。
- ローカル検証を行う。
- ブランチ、コミット、Pull Requestを作成する。
- 実装意図、変更内容、検証結果、既知の制約、発見した問題を報告する。
- Issueを直接Doneにしない。

## レビュー役

レビュー役は、成果物レビュー時に要件・設計・Issue・生成物の対応を確認する。

- 要件との整合性を確認する。
- 設計との整合性を確認する。
- 目的から逸脱していないか確認する。
- コードレビューを行う。
- テスト内容と受け入れ条件の充足を確認する。
- GitHub ActionsのCI結果を確認する。
- CI失敗やレビュー不合格時は、理由と必要修正をProject管理役へ返す。
- 合格時は、満たした要件ID、確認した検証、残存制約を報告する。
- Project状態を直接変更しない。

CIの実行主体はGitHub Actions、結果の評価主体はレビュー役とする。

## Parallel Execution

同時実行するIssue間で、変更対象となる次の項目が競合しないことを確認する。

- 公開インターフェース
- ファイルまたはモジュール
- データ構造
- 設計判断

同じAPIや型を参照するだけで、定義自体を変更しない場合は並列化を妨げない。

## Issue Discovery

実装中に発見した問題は原則として元IssueのSub-issueとする。ただし、複数Issueに影響する問題、元Issueの範囲外、重大な品質・セキュリティ問題は独立Issueとする。

仕様不足を検出した場合は作業をBlockedにし、Project管理役からユーザーへ確認する。

## Milestone Completion

次をすべて満たした場合に完了可能とする。

- 対象IssueがすべてDoneである。
- 各Issueにレビュー役の承認記録がある。
- 必須GitHub Actionsが成功している。
- 未解決のBlocked IssueまたはSub-issueがない。
- 要件トレーサビリティに未対応項目がない。
- mainへのマージがユーザーに承認されている。

## Human Approval

次の場合はユーザー承認を必須とする。

- mainへのマージ
- 要件変更
- 外部仕様変更
- 設計の本質的変更
- Milestoneのゴール変更
- スコープ縮小
- 受け入れ条件の本質的な緩和

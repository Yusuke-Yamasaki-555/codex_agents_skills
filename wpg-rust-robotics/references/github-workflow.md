# GitHub運用

対象リポジトリの`AGENTS.md`にある外部変更の許可とコミット規則を先に適用する。

## Issue駆動

1. Issue本文と関連コメントを読む。
2. ユーザーの許可がある場合だけ、合意済み仕様と計画をコメントする。
3. 方針変更は旧方針との差が分かる形で追記する。
4. 許可された範囲で実装・検証結果とコミット状態を記録する。
5. Issueを無断でcloseまたはreopenしない。

コメント本文はセッションへ再掲せず、投稿結果とURLだけを報告する。

## BranchとCI

- 現行WPGは`dev`で開発し、`master`向けPull Requestで統合する。
- CIは`master`向けPull Requestだけで実行し、通常pushとの重複を避ける。
- workflowや保護規則を変更する前に、現在のtrigger、required check、branch protectionを確認する。
- PRを作る権限はcommit・pushの権限から推測しない。

## Commitとpush

- 詳細調査を行い、branch、remote、既存差分、stage対象を確認する。
- ユーザー差分と自分の変更を分け、対象ファイルだけをstageする。
- 件名にはCodexとWhatを含め、短くする。背景や検証は必要な場合だけ本文へ書く。
- push後はbranch、commit ID、成否を確認する。
- ユーザーがcommitとpushだけを求めた場合は、PRやIssue操作を追加しない。

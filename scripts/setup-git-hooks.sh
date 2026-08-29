#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
hooks_path="${repo_root}/.githooks"
hook_file="${hooks_path}/prepare-commit-msg"

if [[ "$(git -C "${repo_root}" rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
    echo "Gitワークツリーではありません: ${repo_root}" >&2
    exit 1
fi

configured_path="$(git -C "${repo_root}" config --local --get core.hooksPath || true)"

if [[ ! -f "${hook_file}" ]]; then
    echo "hookが存在しません: ${hook_file}" >&2
    exit 1
fi

if [[ ! -x "${hook_file}" ]]; then
    echo "hookに実行権限がありません: ${hook_file}" >&2
    exit 1
fi

case "${configured_path}" in
    "")
        git -C "${repo_root}" config --local core.hooksPath .githooks
        echo "Git hookを設定しました: core.hooksPath=.githooks"
        ;;
    .githooks|./.githooks|"${hooks_path}")
        echo "Git hookは設定済みです: core.hooksPath=${configured_path}"
        ;;
    *)
        echo "既存のcore.hooksPathを上書きしません: ${configured_path}" >&2
        exit 1
        ;;
esac

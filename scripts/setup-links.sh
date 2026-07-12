#!/usr/bin/env bash

set -euo pipefail

# このスクリプト自身の場所からGit管理されるSkillsディレクトリを求める。
# リポジトリを別の場所へcloneしても、原本へのリンク先は自動的に追従する。
skills_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# 必要なら環境変数で配置先を変更できる。未指定時は現在の開発環境を使用する。
wpg_root="${WPG_ROOT:-${HOME}/Projects/WPG}"
codex_home="${CODEX_HOME:-${HOME}/.codex}"

agents_source="${skills_root}/AGENTS.md"
agents_link="${wpg_root}/AGENTS.md"
skill_source="${skills_root}/wpg-rust-robotics"
skill_link="${codex_home}/skills/wpg-rust-robotics"

create_link() {
    local source_path="$1"
    local link_path="$2"

    if [[ ! -e "${source_path}" ]]; then
        echo "リンク元が存在しません: ${source_path}" >&2
        return 1
    fi

    if [[ -L "${link_path}" ]]; then
        local current_target
        current_target="$(readlink -f -- "${link_path}")"
        if [[ "${current_target}" == "$(readlink -f -- "${source_path}")" ]]; then
            echo "設定済みです: ${link_path} -> ${source_path}"
            return 0
        fi
        echo "異なるシンボリックリンクが存在します: ${link_path} -> $(readlink -- "${link_path}")" >&2
        return 1
    fi

    if [[ -e "${link_path}" ]]; then
        echo "既存ファイルを上書きしません: ${link_path}" >&2
        return 1
    fi

    mkdir -p -- "$(dirname -- "${link_path}")"
    ln -s -- "${source_path}" "${link_path}"
    echo "作成しました: ${link_path} -> ${source_path}"
}

create_link "${agents_source}" "${agents_link}"
create_link "${skill_source}" "${skill_link}"

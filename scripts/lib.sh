#!/usr/bin/env bash
#
# lib.sh — shared helpers for the dotfiles install scripts.
#
# Source it from each installer, e.g.:
#     SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#     . "${SCRIPT_DIR}/lib.sh"
#
# It provides logging functions, a repo-root variable, and reusable install
# helpers (require_command, link_file, backup_path).

# Guard against being sourced more than once in the same shell.
[ -n "${DOTFILES_LIB_SOURCED:-}" ] && return 0
DOTFILES_LIB_SOURCED=1

# Standardized exit handling for every script that sources us:
#   -e  exit on any unhandled error
#   -u  error on unset variables
#   -o pipefail  a failing command in a pipeline fails the pipeline
set -euo pipefail

# Repo root, derived from this file's location (scripts/lib.sh -> repo root).
DOTFILES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${DOTFILES_LIB_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------
# Colors are enabled only on a terminal, so piped/redirected output stays clean.
if [ -t 1 ]; then
    _C_RESET=$'\033[0m'
    _C_GREEN=$'\033[32m'
    _C_YELLOW=$'\033[33m'
    _C_RED=$'\033[31m'
else
    _C_RESET='' _C_GREEN='' _C_YELLOW='' _C_RED=''
fi

# section TITLE — a header separating one installer's output from the next.
section() { printf '\n== %s ==\n' "$*"; }

info()    { printf '  %s\n'        "$*"; }
success() { printf '  %s✓%s %s\n'  "${_C_GREEN}"  "${_C_RESET}" "$*"; }
warn()    { printf '  %s!%s %s\n'  "${_C_YELLOW}" "${_C_RESET}" "$*"; }
error()   { printf '  %s✗%s %s\n'  "${_C_RED}"    "${_C_RESET}" "$*" >&2; }

# die MESSAGE — report an error and exit non-zero.
die() { error "$*"; exit 1; }

# ---------------------------------------------------------------------------
# Common helpers
# ---------------------------------------------------------------------------

# require_command NAME [MESSAGE] — die unless NAME is on PATH.
require_command() {
    command -v "$1" >/dev/null 2>&1 \
        || die "${2:-Required command '$1' not found on PATH.}"
}

# backup_path PATH — move an existing file/dir/symlink into this run's backup
# directory, preserving its basename. No-op when PATH does not exist.
#
# All displaced files from a single run land in one directory
# (${DOTFILES_BACKUP_DIR}), which the dotfiles CLI exports once so every
# installer shares it. Run standalone, an installer creates its own on first use.
backup_path() {
    local target="$1"
    [ -e "$target" ] || [ -L "$target" ] || return 0

    : "${DOTFILES_BACKUP_DIR:=${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)}"
    mkdir -p "${DOTFILES_BACKUP_DIR}"

    local dest="${DOTFILES_BACKUP_DIR}/$(basename "$target")"
    mv "$target" "$dest"
    warn "Backed up ${target} -> ${dest}"
}

# link_file SOURCE TARGET — install SOURCE at TARGET, idempotently.
#
# Prefers a symbolic link; falls back to a copy on platforms without symlink
# support (e.g. Windows Git Bash without Developer Mode). Existing content at
# TARGET is backed up first. Returns early if TARGET is already installed.
link_file() {
    local source="$1" target="$2"
    [ -f "$source" ] || die "Source file not found: ${source}"

    # Already a symlink to our source?
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        success "$(basename "$target") already linked. Nothing to do."
        return 0
    fi
    # Already an identical copy (symlink-less platforms)?
    if [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$target" "$source"; then
        success "$(basename "$target") already up to date. Nothing to do."
        return 0
    fi

    backup_path "$target"

    # ln can report success yet leave a plain copy on some Windows setups, so
    # confirm the result is truly a symlink before claiming it.
    if ln -s "$source" "$target" 2>/dev/null && [ -L "$target" ]; then
        success "Linked ${target} -> ${source}"
    else
        rm -f "$target"
        cp "$source" "$target"
        warn "Symlinks unavailable here; copied to ${target} instead."
        info "Re-run after changes to keep the copy in sync."
    fi
}

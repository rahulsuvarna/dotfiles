#!/usr/bin/env bash
#
# install-git.sh — install the repository's Git configuration.
#
# Verifies Git is available and links git/gitconfig into place as ~/.gitconfig,
# backing up any existing file first. Safe to run repeatedly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/lib.sh"

section "Installing Git configuration"

require_command git "Git is not installed or not on PATH. Install Git and re-run."
success "Git found: $(git --version)"

link_file "${REPO_ROOT}/git/gitconfig" "${HOME}/.gitconfig"

success "Git configuration installed."

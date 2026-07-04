#!/usr/bin/env bash
#
# install-ssh.sh — install the repository's SSH client config.
#
# Installs ssh/config as ~/.ssh/config, backing up any existing file first.
# Safe to run repeatedly.
#
# SAFETY: this installer only ever touches ~/.ssh/config. It never reads,
# writes, moves, renames or deletes SSH keys, and it never installs private
# keys from the repository (the repo contains none).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${SCRIPT_DIR}/lib.sh"

section "Installing SSH configuration"

require_command ssh "OpenSSH client ('ssh') not found on PATH. Install it and re-run."

SSH_DIR="${HOME}/.ssh"
TARGET="${SSH_DIR}/config"
SOURCE="${REPO_ROOT}/ssh/config"

# Ensure ~/.ssh exists with correct permissions. mkdir -p is a no-op if the
# directory is already present, so existing keys are left untouched.
if [ ! -d "${SSH_DIR}" ]; then
    mkdir -p "${SSH_DIR}"
    success "Created ${SSH_DIR}"
else
    info "${SSH_DIR} already exists."
fi
chmod 700 "${SSH_DIR}"

# Install the config. link_file backs up any existing ~/.ssh/config into the
# shared backup directory before replacing it, and is idempotent.
link_file "${SOURCE}" "${TARGET}"

# Verify the installed configuration by resolving the effective config for a
# known host. ssh -G reads ~/.ssh/config and exits non-zero on a parse error.
if ssh -G github.com >/dev/null 2>&1; then
    success "Verified SSH config (ssh -G github.com)."
else
    die "SSH config verification failed: 'ssh -G github.com' returned an error."
fi

success "SSH configuration installed."

# dotfiles

Version-controlled configuration for my development environment — shell setup,
Git configuration, and SSH client options — with a small installer that puts
them in place idempotently. This repository is the canonical source: changes are
made here, committed, and applied, rather than edited in a home directory and
forgotten.

## Features

- One command (`dotfiles install`) to configure Git and SSH on a new machine.
- Idempotent installers that back up existing files before replacing them.
- Per-context Git identity via conditional includes (personal vs. work).
- Shell environment and aliases split by concern and driven by workspace paths.
- No secrets in the repository; SSH keys are never tracked or installed.

## Why this exists

Treating the development environment as code makes it inspectable, diffable, and
reproducible. The goals, in order:

- **Reproducibility** — a new machine reaches a known-good state by cloning and
  running one command.
- **Maintainability** — every change is a commit with a rationale, so the setup
  can be audited and reverted.
- **Incremental improvement** — the setup grows one small change at a time.

Automation is added only where it solves a real, recurring problem.

## Repository structure

```
.
├── scripts/
│   ├── dotfiles          # CLI entry point: `dotfiles <command>`
│   ├── lib.sh            # Shared helpers: logging, backup, idempotent linking
│   ├── install-git.sh    # Installs Git configuration
│   └── install-ssh.sh    # Installs SSH client configuration
├── shell/
│   ├── env.sh            # Environment variables (workspace paths)
│   ├── aliases.sh        # Shell aliases
│   └── functions.sh      # Shell functions (placeholder, empty)
├── git/
│   ├── gitconfig         # Base Git config, linked to ~/.gitconfig
│   ├── gitconfig-personal # Identity for personal repos (conditional include)
│   ├── gitconfig-work    # Identity for work repos (conditional include)
│   └── gitignore_global  # Global gitignore (placeholder, empty)
├── ssh/
│   ├── config            # SSH client config, linked to ~/.ssh/config
│   └── config.example    # Example config (placeholder, empty)
└── docs/
    └── SETUP.md          # Setup notes (placeholder, empty)
```

Files marked as placeholders reserve a location and are not yet populated.

## Prerequisites

- **Bash** — the installer and its modules are Bash scripts.
- **Git** — required by the Git module and to clone this repository.
- **OpenSSH client** (`ssh`) — required by the SSH module.

The installer runs on Linux, macOS, and Windows under Git Bash. Where symlinks
are unavailable (for example, Windows Git Bash without Developer Mode), it falls
back to copying files.

## Installation

Clone the repository, then run the installer:

```sh
git clone <this-repo-url> dotfiles
cd dotfiles
./scripts/dotfiles install
```

`install` is idempotent: existing files are backed up before replacement, and
re-running it is safe. Files displaced during a single run are moved into one
timestamped directory under `~/.dotfiles-backups/`.

The CLI implements a single command:

```
dotfiles install     Install all configuration modules (git, ssh)
```

`doctor`, `verify`, and `update` appear in the CLI help as planned commands but
are not yet implemented.

## What the installer does

`dotfiles install` runs each module in turn.

**Git module** (`install-git.sh`)

- Verifies Git is on `PATH`.
- Links `git/gitconfig` to `~/.gitconfig`, backing up any existing file first.

**SSH module** (`install-ssh.sh`)

- Verifies the `ssh` client is on `PATH`.
- Ensures `~/.ssh` exists with `700` permissions; existing keys are untouched.
- Links `ssh/config` to `~/.ssh/config`, backing up any existing file first.
- Verifies the result with `ssh -G github.com`, which fails on a parse error.

The SSH module only ever touches `~/.ssh/config`; it never reads, writes, moves,
or installs SSH keys, and this repository contains no private keys.

The installer does not wire up the shell configuration in `shell/` (see below).

## Shell configuration

Shell configuration is split by concern:

- **`shell/env.sh`** — environment variables, primarily workspace roots
  (`WORKSPACE`, `PERSONAL`, `WORK`, `DEMO`, and derived paths such as `OCP`).
- **`shell/aliases.sh`** — aliases grouped by section (navigation, project
  shortcuts, Git, utilities), referencing the variables from `env.sh`.
- **`shell/functions.sh`** — reserved for shell functions; empty.

No installer module sources these files. To use them, source them from your
shell profile:

```sh
for f in ~/path/to/dotfiles/shell/*.sh; do
    [ -r "$f" ] && . "$f"
done
```

## Git configuration

`git/gitconfig` sets a shared identity and delegates the email address to a
per-context file using conditional includes based on repository location:

```
[includeIf "gitdir:~/workspace/personal/"]
    path = ~/.gitconfig-personal

[includeIf "gitdir:~/workspace/work/"]
    path = ~/.gitconfig-work
```

Repositories under the personal workspace use the personal email; those under
work use the work email. Only `~/.gitconfig` is linked; the included files are
referenced from the home directory and are not themselves linked.

## Workspace layout

`shell/env.sh` assumes a workspace rooted at `/c/workspace` (the Git Bash path on
Windows):

```
$WORKSPACE (/c/workspace)
├── personal/   $PERSONAL
├── work/       $WORK
│   └── ocp/    $OCP
└── demo/       $DEMO
```

Aliases navigate relative to these roots. Adjust `env.sh` to match your machine.

## Adding aliases and environment variables

Add an environment variable to `shell/env.sh`, deriving it from an existing root
where possible:

```sh
export TOOLS="$WORKSPACE/tools"
```

Add an alias to the relevant section of `shell/aliases.sh`, referencing
variables rather than absolute paths:

```sh
alias tools='cd "$TOOLS"'
```

## Design principles

- Everything is version-controlled; nothing is edited only in the home directory.
- Installers are idempotent, back up before replacing, and never destroy data.
- Single responsibility per file: environment, aliases, and functions stay
  separate, and each installer handles one concern.
- No secrets in the repository; configuration references keys by path.
- Automation is justified by a recurring need, not added speculatively.

## Not managed by this repository

- **SSH keys or secrets.** Keys live in `~/.ssh` and are never tracked.
- **Package or tool installation.** It configures tools it assumes are present;
  it does not install Git, a shell, or language runtimes.
- **OS or application settings** beyond shell, Git, and SSH.
- **Machine-specific paths as universal truth.** The workspace layout reflects
  one machine and is expected to be adjusted per host.

## Contributing

- Keep changes small and focused; one concern at a time.
- Prefer the simplest thing that works; avoid speculative abstractions.
- Preserve idempotency and backup-before-replace behavior in installer changes.
- Never introduce secrets, keys, or machine-specific credentials.

## License

No license file is included. A license should be added before this repository is
made public.

# codex-helper

Utilities for creating Git worktrees and launching Codex in the new worktree context.

## What this gives you

- `create-worktree-codex.sh`: creates a worktree and launches Codex.
- `install-codextree.sh`: installs the script to `~/.local/bin` and adds alias `codextree` to `~/.zshrc`.
- Worktree folder naming format: `<repo-folder>-<worktree-name>`.
  - This helps Codex thread names follow the same format.

## Requirements

- macOS or Linux shell with `bash`
- `git`
- `zsh` (for alias install flow)
- Codex CLI (`codex`) for best desktop launch behavior

## Install

From this project directory:

```bash
./install-codextree.sh
source ~/.zshrc
```

After install, use:

```bash
codextree --help
```

## Usage

```bash
codextree [--app|--cli] <name> [base-ref]
```

### Arguments

- `name`: Worktree and branch name (example: `feature-login`)
- `base-ref` (optional): ref to branch from (default: `HEAD`)

### Options

- `--app`: open Codex desktop app for the new worktree
- `--cli`: open Codex CLI in the new worktree (default)
- `-h, --help`: show help

## Examples

Create from current `HEAD` and open desktop app:

```bash
codextree --app feature-auth
```

Create from `origin/main` and open CLI:

```bash
codextree --cli feature-billing origin/main
```

Create only, skip launch:

```bash
CODEX_NO_LAUNCH=1 codextree feature-refactor
```

Custom worktree parent directory:

```bash
WORKTREE_ROOT="$HOME/.worktrees" codextree --app feature-dashboard
```

## Behavior details

- Must be run inside a Git repository.
- Worktrees are created under:
  - default: `<repo>/.worktrees`
  - override: `$WORKTREE_ROOT`
- New folder path is:
  - `<worktree-root>/<repo-folder>-<worktree-name>`
- Branch behavior:
  - if branch exists: adds worktree for that branch
  - if branch does not exist: creates branch from `[base-ref]`

## Environment variables

- `WORKTREE_ROOT`: parent dir for worktrees
- `CODEX_CMD`: command used to launch Codex (default: `codex`)
- `CODEX_NO_LAUNCH=1`: create worktree without launching Codex
- `INSTALL_DIR`: install target for installer (default: `~/.local/bin`)
- `ZSHRC`: zsh config path for installer (default: `~/.zshrc`)

## Troubleshooting

- `Operation not permitted` during install:
  - run install in a shell with permission to write to your home directory.
- `Error: run this script inside a git repository`:
  - `cd` into a Git repo first.
- Desktop app did not open:
  - use `--app` and make sure `codex` CLI is installed.
  - on macOS, fallback launch uses `open -a "Codex"`.

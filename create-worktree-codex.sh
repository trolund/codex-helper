#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: create-worktree-codex.sh <name> [base-ref]

Creates a git worktree and launches Codex in that worktree.

Arguments:
  name       Worktree/branch name (for example: feature-login)
  base-ref   Optional base ref to branch from (default: current HEAD)

Environment variables:
  WORKTREE_ROOT   Parent dir for worktrees (default: <repo>/_worktrees)
  CODEX_CMD       Codex launch command (default: codex)
  CODEX_NO_LAUNCH Set to 1 to skip launching Codex
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 1
fi

name="$1"
base_ref="${2:-HEAD}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: run this script inside a git repository." >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
repo_name="$(basename "$repo_root")"
worktree_root="${WORKTREE_ROOT:-$repo_root/_worktrees}"
worktree_dir="$worktree_root/$name"
branch="$name"

mkdir -p "$worktree_root"

if git show-ref --verify --quiet "refs/heads/$branch"; then
  if [[ -d "$worktree_dir" ]]; then
    echo "Error: branch '$branch' and worktree '$worktree_dir' already exist." >&2
    exit 1
  fi
  echo "Branch '$branch' exists, creating worktree from existing branch..."
  git worktree add "$worktree_dir" "$branch"
else
  echo "Creating branch '$branch' from '$base_ref' in new worktree..."
  git worktree add -b "$branch" "$worktree_dir" "$base_ref"
fi

echo "Worktree created at: $worktree_dir"

if [[ "${CODEX_NO_LAUNCH:-0}" == "1" ]]; then
  echo "Skipping Codex launch because CODEX_NO_LAUNCH=1"
  exit 0
fi

codex_cmd="${CODEX_CMD:-codex}"

if command -v "$codex_cmd" >/dev/null 2>&1; then
  echo "Launching Codex with: $codex_cmd (cwd=$worktree_dir)"
  (
    cd "$worktree_dir"
    exec "$codex_cmd"
  )
  exit 0
fi

if [[ "$OSTYPE" == darwin* ]] && [[ -d "/Applications/Codex.app" ]]; then
  echo "Codex CLI not found. Opening Codex.app instead."
  open -a "Codex" "$worktree_dir"
  exit 0
fi

cat >&2 <<EOF
Warning: could not launch Codex automatically.
Worktree is ready at:
  $worktree_dir

Set CODEX_CMD to your launch command, for example:
  CODEX_CMD="codex" ./create-worktree-codex.sh "$name"
EOF

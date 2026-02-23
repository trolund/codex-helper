#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/create-worktree-codex.sh"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
TARGET_SCRIPT="$INSTALL_DIR/create-worktree-codex.sh"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  echo "Error: source script not found at $SOURCE_SCRIPT" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"

touch "$ZSHRC"

path_line='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -Fqx "$path_line" "$ZSHRC"; then
  printf "\n# Added by codextree installer\n%s\n" "$path_line" >> "$ZSHRC"
fi

alias_line='alias codextree="$HOME/.local/bin/create-worktree-codex.sh"'
if ! grep -Fqx "$alias_line" "$ZSHRC"; then
  printf "%s\n" "$alias_line" >> "$ZSHRC"
fi

echo "Installed: $TARGET_SCRIPT"
echo "Updated: $ZSHRC"
echo "Run: source \"$ZSHRC\""

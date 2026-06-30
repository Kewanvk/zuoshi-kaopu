#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"

mkdir -p "$TARGET_DIR"

for skill_dir in "$ROOT_DIR"/skills/*; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  dest="$TARGET_DIR/$name"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "skip $name: $dest exists and is not a symlink" >&2
    continue
  fi

  ln -sfn "$skill_dir" "$dest"
  echo "installed $name"
done

echo "done. restart Codex, then say: vkskill"

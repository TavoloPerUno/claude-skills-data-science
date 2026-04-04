#!/bin/bash
# Install all skills by symlinking into ~/.claude/skills/

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

mkdir -p "$SKILLS_DIR"

for skill_dir in "$SCRIPT_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    # Skip hidden dirs and non-skill folders
    if [[ "$skill_name" == .* ]] || [[ ! -f "$skill_dir/SKILL.md" ]]; then
        continue
    fi
    if [[ -e "$SKILLS_DIR/$skill_name" ]]; then
        echo "Skipping $skill_name (already exists)"
    else
        ln -s "$skill_dir" "$SKILLS_DIR/$skill_name"
        echo "Installed $skill_name"
    fi
done

echo "Done."

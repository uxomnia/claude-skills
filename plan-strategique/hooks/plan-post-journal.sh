#!/usr/bin/env bash
# Hook PostToolUse pour le skill plan-strategique
# Append une ligne dans le journal du plan actif (repo + miroir Obsidian si configuré)
#
# Variables d'environnement :
#   CLAUDE_PROJECT_DIR              — racine du projet (Claude Code la définit auto)
#   PLAN_STRATEGIQUE_OBSIDIAN_DIR  — dossier Obsidian pour miroir (optionnel)
set -e

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
ACTIVE_PLAN_FILE="$PROJECT_ROOT/docs/plans/.active-plan"
OBSIDIAN_DIR="${PLAN_STRATEGIQUE_OBSIDIAN_DIR:-}"

# Si pas de plan actif → ne rien faire
[ -s "$ACTIVE_PLAN_FILE" ] || exit 0

SLUG="$(tr -d '[:space:]' < "$ACTIVE_PLAN_FILE")"
[ -n "$SLUG" ] || exit 0

# Lire l'input JSON
INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_response.filePath // .tool_input.file_path // ""')"
[ -n "$FILE_PATH" ] || exit 0

# Éviter la boucle infinie : ignorer les edits dans docs/plans/** et le miroir Obsidian
case "$FILE_PATH" in
  */docs/plans/*) exit 0 ;;
esac
if [ -n "$OBSIDIAN_DIR" ]; then
  case "$FILE_PATH" in
    "$OBSIDIAN_DIR"/*) exit 0 ;;
  esac
fi

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
# Chemin relatif au projet pour la lisibilité
REL_PATH="${FILE_PATH#$PROJECT_ROOT/}"
LINE="- $TIMESTAMP — modifié : $REL_PATH"

append_journal() {
  local plan_file="$1"
  [ -f "$plan_file" ] || return 0
  if grep -q "^## 📓 Journal des modifications" "$plan_file"; then
    printf '%s\n' "$LINE" >> "$plan_file"
  else
    printf '\n## 📓 Journal des modifications\n\n%s\n' "$LINE" >> "$plan_file"
  fi
}

append_journal "$PROJECT_ROOT/docs/plans/$SLUG.md"
[ -n "$OBSIDIAN_DIR" ] && append_journal "$OBSIDIAN_DIR/$SLUG.md"

exit 0

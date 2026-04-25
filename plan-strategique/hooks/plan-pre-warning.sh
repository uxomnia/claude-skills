#!/usr/bin/env bash
# Hook PreToolUse pour le skill plan-strategique
# Avertit (sans bloquer) si aucun plan actif n'est défini
#
# Variables d'environnement :
#   CLAUDE_PROJECT_DIR — racine du projet (Claude Code la définit auto)
set -e

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
ACTIVE_PLAN_FILE="$PROJECT_ROOT/docs/plans/.active-plan"

# Lire l'input JSON depuis stdin
INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')"

# Exclure les éditions de la mémoire du plan elle-même (sinon avertissement parasite)
case "$FILE_PATH" in
  */docs/plans/*) exit 0 ;;
  */.claude/skills/plan-strategique/*) exit 0 ;;
  */.claude/hooks/plan-*) exit 0 ;;
esac

# Si .active-plan existe et n'est pas vide → aucun avertissement
if [ -s "$ACTIVE_PLAN_FILE" ]; then
  exit 0
fi

# Sinon, avertissement non-bloquant via systemMessage
cat <<'EOF'
{"systemMessage": "⚠️ Aucun plan actif détecté (docs/plans/.active-plan vide). Lance /plan-strategique d'abord pour cadrer ton travail, ou ignore si c'est une petite édition."}
EOF
exit 0

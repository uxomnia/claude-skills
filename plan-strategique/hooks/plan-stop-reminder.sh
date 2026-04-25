#!/usr/bin/env bash
# Hook Stop pour le skill plan-strategique
# Rappelle à Claude de mettre à jour le statut du plan actif si nécessaire
#
# Variables d'environnement :
#   CLAUDE_PROJECT_DIR — racine du projet (Claude Code la définit auto)
set -e

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
ACTIVE_PLAN_FILE="$PROJECT_ROOT/docs/plans/.active-plan"

[ -s "$ACTIVE_PLAN_FILE" ] || exit 0

SLUG="$(tr -d '[:space:]' < "$ACTIVE_PLAN_FILE")"
[ -n "$SLUG" ] || exit 0

# Injecter un rappel dans le contexte modèle au prochain tour
jq -n --arg slug "$SLUG" '{
  systemMessage: ("🧠 plan-strategique — plan actif : " + $slug + ". Mets à jour le statut si livraison/abandon, et synchronise repo + Obsidian si configuré.")
}'
exit 0

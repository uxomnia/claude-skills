#!/usr/bin/env bash
# Installeur du skill plan-strategique
#
# Usage :
#   ./install.sh /chemin/vers/projet
#   ./install.sh                       # utilise $PWD
#
# Ce script :
#   1. Copie SKILL.md dans <projet>/.claude/skills/plan-strategique/
#   2. Copie les hooks dans <projet>/.claude/hooks/
#   3. Crée docs/plans/INDEX.md et docs/plans/.active-plan
#   4. Affiche les instructions pour merger settings.example.json
#
# Idempotent : ré-exécutable sans casser l'existant.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$PWD}"

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "❌ Erreur : '$PROJECT_ROOT' n'est pas un dossier." >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
echo "📦 Installation de plan-strategique dans : $PROJECT_ROOT"

# 1. Skill
echo "  → .claude/skills/plan-strategique/SKILL.md"
mkdir -p "$PROJECT_ROOT/.claude/skills/plan-strategique"
cp "$SCRIPT_DIR/SKILL.md" "$PROJECT_ROOT/.claude/skills/plan-strategique/SKILL.md"

# 2. Hooks
echo "  → .claude/hooks/plan-*.sh"
mkdir -p "$PROJECT_ROOT/.claude/hooks"
cp "$SCRIPT_DIR/hooks/"plan-*.sh "$PROJECT_ROOT/.claude/hooks/"
chmod +x "$PROJECT_ROOT/.claude/hooks/"plan-*.sh

# 3. Stockage des plans
echo "  → docs/plans/"
mkdir -p "$PROJECT_ROOT/docs/plans"
[ -f "$PROJECT_ROOT/docs/plans/.active-plan" ] || touch "$PROJECT_ROOT/docs/plans/.active-plan"
if [ ! -f "$PROJECT_ROOT/docs/plans/INDEX.md" ]; then
  cp "$SCRIPT_DIR/templates/INDEX.md" "$PROJECT_ROOT/docs/plans/INDEX.md"
  echo "    (INDEX.md créé)"
else
  echo "    (INDEX.md déjà présent — préservé)"
fi

# 4. Vérifier les dépendances
if ! command -v jq >/dev/null 2>&1; then
  echo ""
  echo "⚠️  jq n'est pas installé. Les hooks en ont besoin."
  echo "    macOS : brew install jq"
  echo "    Linux : apt-get install jq  (ou équivalent)"
fi

# 5. Instructions pour settings.local.json
SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.local.json"
echo ""
echo "✅ Skill et hooks installés."
echo ""
echo "📝 ÉTAPE MANUELLE : merge la config des hooks dans $SETTINGS_FILE"
echo "    Source : $SCRIPT_DIR/settings.example.json"
echo ""
if [ -f "$SETTINGS_FILE" ]; then
  echo "    Le fichier existe déjà — fusionne à la main les clés \"hooks\" et \"env\""
  echo "    sans écraser tes \"permissions\" actuelles."
else
  echo "    Le fichier n'existe pas — tu peux copier settings.example.json :"
  echo "    cp \"$SCRIPT_DIR/settings.example.json\" \"$SETTINGS_FILE\""
fi
echo ""
echo "🧠 Optionnel : pour un miroir Obsidian, ajoute dans .claude/settings.local.json :"
echo '    "env": { "PLAN_STRATEGIQUE_OBSIDIAN_DIR": "/chemin/vers/ton/vault/Plans-Claude" }'
echo ""
echo "🔄 Active les hooks : ouvre /hooks dans Claude Code, ou redémarre."
echo ""
echo "🚀 Usage : tape /plan-strategique dans Claude Code, ou laisse Claude le déclencher auto."

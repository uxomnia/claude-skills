# plan-strategique

> Skill Claude Code qui **force une analyse stratégique complète avant tout code**, avec **mémoire persistante entre conversations** et **journalisation automatique** des modifications via hooks.

## Pourquoi ce skill ?

Sans ce skill, Claude saute souvent directement à l'implémentation sans cadrer le contexte, identifier les risques, ni découper le travail. Résultat : code écrit trop vite, retours en arrière, "perte de fil" entre sessions.

`plan-strategique` :

- 📋 **Force la planification avant le code** — restate requirements, risques, étapes, fichiers, critères d'acceptation
- 💾 **Mémoire long terme** — chaque plan est sauvegardé en markdown (avec frontmatter), indexé, retrouvable
- 🔁 **Continuité entre conversations** — Claude lit l'index + les plans actifs au début de chaque session
- 🪝 **Journal automatique via hooks** — chaque `Edit`/`Write` est loggué dans le plan actif sans intervention
- 🧠 **Optionnel : sync Obsidian** — pour avoir le plan dans ton second cerveau, en plus du repo

## Architecture

```
<projet>/
├── .claude/
│   ├── skills/plan-strategique/SKILL.md       ← le skill (chargé en contexte)
│   ├── hooks/
│   │   ├── plan-pre-warning.sh                ← avertit si pas de plan actif
│   │   ├── plan-post-journal.sh               ← journalise chaque modification
│   │   └── plan-stop-reminder.sh              ← rappelle à Claude le plan en cours
│   └── settings.local.json                    ← câblage des 3 hooks
└── docs/plans/
    ├── INDEX.md                               ← index de tous les plans
    ├── .active-plan                           ← slug du plan en cours (vide = aucun)
    └── <YYYY-MM-DD-slug>.md                   ← plans individuels avec frontmatter
```

Optionnel : miroir Obsidian si `PLAN_STRATEGIQUE_OBSIDIAN_DIR` est défini.

## Installation

### Méthode 1 — Script automatique

```bash
git clone https://github.com/Casakub/claude-skills.git /tmp/claude-skills
cd /chemin/vers/ton/projet
/tmp/claude-skills/plan-strategique/install.sh "$PWD"
```

### Méthode 2 — Via Claude Code

Dans une session Claude Code, dans ton projet, demande :

> Installe le skill `plan-strategique` depuis https://github.com/Casakub/claude-skills.git

Claude exécutera l'installeur et te guidera.

### Méthode 3 — Installation manuelle

```bash
PROJECT_ROOT="/chemin/vers/ton/projet"

# 1. Skill
mkdir -p "$PROJECT_ROOT/.claude/skills/plan-strategique"
cp plan-strategique/SKILL.md "$PROJECT_ROOT/.claude/skills/plan-strategique/"

# 2. Hooks
mkdir -p "$PROJECT_ROOT/.claude/hooks"
cp plan-strategique/hooks/*.sh "$PROJECT_ROOT/.claude/hooks/"
chmod +x "$PROJECT_ROOT/.claude/hooks/plan-"*.sh

# 3. Stockage des plans
mkdir -p "$PROJECT_ROOT/docs/plans"
touch "$PROJECT_ROOT/docs/plans/.active-plan"
[ -f "$PROJECT_ROOT/docs/plans/INDEX.md" ] || cp plan-strategique/templates/INDEX.md "$PROJECT_ROOT/docs/plans/"

# 4. Hooks dans settings.local.json — voir settings.example.json et merger à la main
```

Puis merge manuellement `settings.example.json` dans `<projet>/.claude/settings.local.json`.

## Configuration optionnelle — sync Obsidian

Pour que les plans soient aussi écrits dans ton vault Obsidian (utile si tu utilises Obsidian comme second cerveau), définis la variable d'environnement `PLAN_STRATEGIQUE_OBSIDIAN_DIR` dans `.claude/settings.local.json` :

```json
{
  "env": {
    "PLAN_STRATEGIQUE_OBSIDIAN_DIR": "/Users/toi/Documents/MonVault/Projets/MonProjet/Plans-Claude"
  }
}
```

Si la variable n'est pas définie, le skill écrit uniquement dans le repo (`docs/plans/`). Le dossier Obsidian est créé automatiquement au premier plan.

## Activation après installation

Les hooks ajoutés à `settings.local.json` en cours de session ne sont parfois pas pris en compte tant que tu n'as pas :

- soit ouvert **`/hooks`** une fois (force le rechargement),
- soit **redémarré Claude Code**.

Une fois rechargés, les 3 hooks tourneront silencieusement à chaque interaction.

## Usage

1. **Démarre une session Claude Code** dans ton projet.
2. Quand tu as un objectif non-trivial à atteindre (nouvelle feature, refacto, bug complexe), tape :
   ```
   /plan-strategique
   ```
   ou décris ton objectif et laisse Claude déclencher le skill automatiquement.
3. Claude lit l'index des plans précédents, écrit un nouveau plan dans `docs/plans/<slug>.md` (et miroir Obsidian si configuré), et écrit le slug dans `.active-plan`.
4. Tu valides avec **`GO`**.
5. À chaque `Edit`/`Write` que Claude fait, le hook `PostToolUse` ajoute automatiquement une ligne dans la section `## 📓 Journal des modifications` du plan actif.
6. À la livraison, Claude passe le statut à `✅ livré` et vide `.active-plan`.

## Statuts disponibles

- 🟡 `en cours` — plan actif, en implémentation
- 🔵 `en attente` — plan validé mais non démarré
- ✅ `livré` — implémentation terminée et validée
- ❌ `abandonné` — plan abandonné (avec raison)

## Désinstallation

```bash
rm -rf <projet>/.claude/skills/plan-strategique
rm <projet>/.claude/hooks/plan-*.sh
# Et retire le bloc "hooks" lié à plan-strategique de .claude/settings.local.json
```

Les plans dans `docs/plans/` sont conservés (ils restent utiles comme historique).

## Variables d'environnement

| Variable | Utilité | Défaut |
|----------|---------|--------|
| `CLAUDE_PROJECT_DIR` | Racine du projet (Claude Code la définit automatiquement) | `$PWD` |
| `PLAN_STRATEGIQUE_OBSIDIAN_DIR` | Dossier Obsidian pour le miroir des plans | (vide → pas de sync) |

## Licence

MIT.

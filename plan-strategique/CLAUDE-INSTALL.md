# Directives pour Claude — installation du skill `plan-strategique`

> **À l'attention de Claude Code** : ce document décrit la procédure exacte à suivre quand un utilisateur te demande d'installer ce skill depuis GitHub dans son projet courant.

## Quand appliquer cette procédure

L'utilisateur dit quelque chose comme :
- "Installe le skill `plan-strategique` depuis https://github.com/Casakub/claude-skills.git"
- "Ajoute le skill plan stratégique de Casakub à ce projet"
- "Configure plan-strategique sur ce repo"

## Procédure (5 étapes)

### Étape 1 — Confirmer le projet cible

Le projet cible est **le répertoire de travail courant** (`$PWD` au moment où Claude Code tourne). Annonce-le explicitement à l'utilisateur :

> "Je vais installer le skill dans : `<chemin du projet courant>`. OK ?"

Attends confirmation **avant** d'écrire quoi que ce soit hors de `/tmp`.

### Étape 2 — Cloner le repo en /tmp

```bash
rm -rf /tmp/claude-skills-install
git clone https://github.com/Casakub/claude-skills.git /tmp/claude-skills-install
```

### Étape 3 — Lancer l'installeur

```bash
/tmp/claude-skills-install/plan-strategique/install.sh "$PWD"
```

L'installeur :
- copie `SKILL.md` dans `.claude/skills/plan-strategique/`
- copie les 3 hooks dans `.claude/hooks/`
- crée `docs/plans/INDEX.md` et `docs/plans/.active-plan`
- affiche les instructions pour le settings

### Étape 4 — Merger les hooks dans settings.local.json

C'est la partie délicate : **ne pas écraser** le fichier existant.

1. **Lis** `.claude/settings.local.json` (avec le tool `Read`)
2. **Lis** `/tmp/claude-skills-install/plan-strategique/settings.example.json`
3. **Merge** :
   - Si `.claude/settings.local.json` n'existe pas : crée-le avec le contenu de `settings.example.json`
   - S'il existe : ajoute les clés `hooks.PreToolUse`, `hooks.PostToolUse`, `hooks.Stop` (en concaténant aux tableaux existants si présents) et `env.PLAN_STRATEGIQUE_OBSIDIAN_DIR` (vide par défaut)
   - **Ne touche pas** aux clés `permissions`, autres `env`, ou autres `hooks` matchers
4. **Valide** le JSON avec `jq '.' .claude/settings.local.json > /dev/null`

### Étape 5 — Demander à l'utilisateur s'il veut Obsidian

> "Veux-tu un miroir Obsidian des plans ? Si oui, donne-moi le chemin du dossier de ton vault où stocker les plans (ex. `/Users/toi/Vault/MonProjet/Plans-Claude`)."

Si oui, mets à jour `.claude/settings.local.json` :
```json
{
  "env": {
    "PLAN_STRATEGIQUE_OBSIDIAN_DIR": "<chemin fourni>"
  }
}
```

Crée aussi le dossier : `mkdir -p "<chemin fourni>"` et copie-y `templates/INDEX.md`.

Si non, laisse la variable vide. Le skill fonctionnera avec le repo seul.

### Étape 6 — Annonce de fin

Affiche à l'utilisateur :

> ✅ Skill `plan-strategique` installé.
>
> **Action requise** : ouvre `/hooks` dans Claude Code (ou redémarre) pour activer les 3 hooks.
>
> Ensuite, tape `/plan-strategique` ou décris-moi un objectif non-trivial — je déclencherai le skill automatiquement.

## Garde-fous

- ❌ **Ne push jamais** vers le repo Casakub/claude-skills depuis cette installation — l'utilisateur n'en est pas le propriétaire (sauf s'il l'indique).
- ❌ **N'écrase jamais** `.claude/settings.local.json` — toujours merger.
- ❌ **N'installe pas globalement** dans `~/.claude/` sans demander — les hooks doivent rester par projet.
- ✅ **Idempotence** : si le skill est déjà installé, l'installeur le détecte (les `cp` réécrivent les fichiers, c'est OK pour les mises à jour). Confirme à l'utilisateur que c'est une mise à jour.
- ✅ **Vérifie `jq`** : les hooks en dépendent. Si absent, demande à l'utilisateur de l'installer (`brew install jq`).

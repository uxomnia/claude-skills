# claude-skills

Collection de skills réutilisables pour [Claude Code](https://claude.com/claude-code).

## Skills disponibles

| Skill | Description |
|-------|-------------|
| [plan-strategique](./plan-strategique/) | Force une analyse stratégique avant tout code, avec mémoire persistante (repo + Obsidian optionnel) et journalisation automatique des modifications via hooks. |

## Installation

### Option 1 — Installation manuelle d'un skill

Chaque dossier de skill contient son propre `README.md` avec les instructions détaillées et un script `install.sh` :

```bash
git clone https://github.com/Casakub/claude-skills.git
cd claude-skills
./plan-strategique/install.sh /chemin/vers/ton/projet
```

### Option 2 — Demander à Claude Code de l'installer

Dans une session Claude Code, dans le projet où tu veux installer le skill, demande :

> Installe le skill `plan-strategique` depuis https://github.com/Casakub/claude-skills.git dans ce projet.

Claude clonera le repo en `/tmp`, exécutera `./plan-strategique/install.sh "$PWD"`, puis te demandera de recharger les hooks via `/hooks` ou un redémarrage de Claude Code.

### Option 3 — Installation globale (tous projets)

Pour rendre un skill disponible sur **tous tes projets** Claude Code :

```bash
mkdir -p ~/.claude/skills/plan-strategique
cp -r plan-strategique/* ~/.claude/skills/plan-strategique/
```

Note : les hooks doivent rester **par projet** (ils écrivent dans `docs/plans/` du projet courant) — ne les copie pas dans `~/.claude/`.

## Structure d'un skill

```
<skill-name>/
├── README.md            ← documentation + installation
├── SKILL.md             ← le skill (frontmatter YAML + corps markdown)
├── hooks/               ← scripts shell appelés par Claude Code (optionnel)
├── settings.example.json ← exemple de config à merger dans settings.local.json
└── install.sh           ← installeur one-shot
```

## Contribuer

1. Crée un dossier `<skill-name>/` à la racine
2. Ajoute `SKILL.md` avec frontmatter `name` + `description`
3. Si le skill nécessite des hooks, place-les dans `hooks/` et documente la config dans `settings.example.json`
4. Écris un `install.sh` portable (Bash, macOS + Linux)
5. Documente l'usage dans le `README.md` du skill

## Licence

MIT — usage libre, modifications bienvenues.

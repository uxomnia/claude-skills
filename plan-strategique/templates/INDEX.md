# Plans Stratégiques

> Mémoire long terme du skill `plan-strategique`.
> Convention de nommage : `YYYY-MM-DD-<slug-kebab>.md`
> Statuts : 🟡 en cours · 🔵 en attente · ✅ livré · ❌ abandonné

---

## 🟡 En cours

<!-- Ajouter les nouveaux plans en tête. Format : `- [slug](./slug.md) — titre — date` -->

_Aucun plan actif._

## 🔵 En attente

_Aucun plan en attente._

## ✅ Livrés

_Aucun plan livré._

## ❌ Abandonnés

_Aucun plan abandonné._

---

## Comment utiliser

1. Invoquer `/plan-strategique` ou laisser Claude le déclencher automatiquement
2. À chaque nouveau plan, Claude :
   - lit cet index + les 3 derniers plans actifs
   - écrit le nouveau plan dans `docs/plans/<slug>.md` (et miroir Obsidian si configuré)
   - écrit le slug dans `.active-plan`
   - met à jour cet index
3. À la livraison, Claude déplace la ligne vers la section `✅ Livrés` et vide `.active-plan`

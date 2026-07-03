# Workflow IA — config opencode

Config personnelle d'agents IA pour mon workflow de dev consultant senior
(fullstack JS, dominante front). Pensée comme un **système** : cadrer → planifier
→ implémenter → reviewer, avec en fil rouge la **reconnaissance des
patterns/anti-patterns** pour monter en autonomie.

---

## 🚀 « Je veux… » → quoi utiliser (le cookbook)

| Ma situation | J'utilise | Comment |
|---|---|---|
| Une idée floue, un arbitrage, choisir une archi (perso ou client), décider quoi faire | **brainstorm** | `Tab` → brainstorm |
| Je débarque sur un codebase inconnu, je veux la carte des patterns existants | **/pattern-scan** | tape `/pattern-scan` (ou `/pattern-scan src/`) |
| Préparer un changement sûr : inspecter, comparer, plan d'exécution | **plan** | `Tab` → plan |
| Implémenter le changement validé | **build** | `Tab` → build |
| Valider un diff / PR avant livraison | **review** | `Tab` → review |
| Un pattern/anti-pattern croisé m'intéresse, je veux le garder pour l'étudier plus tard | **/capture** | tape `/capture` |
| On me propose plein de texte, je veux juste choisir | les agents proposent A/B/C | réponds par la lettre |

**Le doute le plus fréquent — `/pattern-scan` ou `/capture` ?**
- **`/pattern-scan`** = *LIRE* un codebase entier pour en sortir la carte des
  patterns. Au **début** d'un projet. Ça produit de l'info.
- **`/capture`** = *SAUVEGARDER* un pattern déjà mentionné dans la conversation,
  dans mon journal perso. **Pendant** le travail. Ça archive une note.
- Moyen mnémo : **scan = découvrir / capture = garder.**

---

## 🧠 Le modèle mental : 3 types d'objets

| Type | Ce que c'est | Comment j'y accède | Contexte |
|---|---|---|---|
| **Agent primaire** | une *phase* que je pilote | `Tab` pour switcher | partagé (ma conversation) |
| **Command** | une *action* rapide | `/nom` | celui de l'agent courant |
| **Subagent** | une *tâche* isolée occasionnelle | `/nom` épinglé, ou délégation | isolé (jetable) |

Règle : **phase récurrente que je conduis = agent primaire**. **Action dans le
contexte courant = command**. **Tâche lourde/isolée occasionnelle = subagent.**

---

## 👥 Les agents

### Primaires (rotation `Tab`)

| Agent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **brainstorm** | Cadrer, challenger, comparer, décider. Ne lit **pas** le code (c'est volontaire : altitude décision). | GPT-5.5 Fast / low / temp 0.5 | ❌ read-only |
| **plan** | Inspecter en read-only, produire un plan d'exécution. Pattern Radar obligatoire. | GPT-5.5 / high / temp 0.1 | ❌ read-only |
| **build** | Implémenter le plan, diffs minimaux, validation ciblée. | GPT-5.5 / medium / temp 0 | ✅ edit autorisé |
| **review** | Reviewer un diff strictement. Verdicts APPROVE / REQUEST CHANGES / ESCALATE. Pattern Radar obligatoire. | GPT-5.5 / high / temp 0 | ❌ read-only |

Flux par défaut : **brainstorm → plan → build → review** (chaque agent recommande
le suivant). Greenfield *et* brownfield sont gérés ; pour un projet perso où je
veux **apprendre** une archi, je l'annonce explicitement pour débrayer le réflexe
« fais simple ».

### Subagent (à la demande)

| Subagent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **pattern-scan** | Cartographier les patterns (archi / JS / framework) d'un codebase inconnu. Contexte isolé. | GPT-5.5 Fast / medium / temp 0.1 | ❌ read-only |

Lancé via `/pattern-scan`. Le mode courant n'a aucune importance : la command est
épinglée au subagent (modèle cheap, read-only, contexte vierge garantis).

---

## ⌨️ Les commands

| Command | Fait quoi | Dépend du mode ? |
|---|---|---|
| **/pattern-scan** `[scope]` | Lance le subagent pattern-scan sur un dossier (défaut : tout le projet). | Non (épinglé) |
| **/capture** `[texte]` | Append les patterns discutés (ou le texte donné) au journal perso. Sortie 1 ligne. | Non (autorisé partout) |

### Le journal de capture
- Emplacement : **`~/dev/ai/pattern-captures/<projet>.md`** — **un fichier par
  projet** (nom auto-détecté via git), créé automatiquement. Le script **append**
  (jamais d'écrasement) — chaque fichier est le journal cumulatif d'un projet.
- Chaque entrée : en-tête de date + les patterns.
- Usage : je relis en fin de journée, je note ce que je veux creuser, j'étudie de
  mon côté. (Branchement Obsidian plus tard = juste changer le chemin dans
  `bin/capture.sh`.)

---

## 🎯 Patterns / anti-patterns (objectif apprentissage)

Deux niveaux, séparés exprès :

1. **Lentille (gratuite, automatique)** — le **Pattern Radar** tourne dans `plan`,
   `review` et `pattern-scan`. Il **nomme** chaque pattern avec son nom canonique
   (le nom est le but : c'est ce que je retiens et vais chercher). Il juge sa
   propre pertinence (« rien de notable » plutôt qu'inventer).
2. **Capture (volontaire)** — quand un nom m'intrigue, `/capture` le met de côté.

---

## 🧩 Les skills (séparés par rôle → zéro overlap)

| Skill(s) | Rôle |
|---|---|
| `react-2026`, `react-composition-2026`, `react-data-fetching`, `react-render-optimization` | **apprendre + produire** (plan, build) |
| rendering : `*-side-rendering`, `static-*`, `incremental-*`, `react-server-components`, `react-selective-hydration`, `islands-architecture` | idem, **uniquement** si le projet utilise vraiment Next/SSR/SSG/ISR/RSC/hydration |
| `js-performance-patterns` | perf JS, **seulement** avec preuve/risque réel |
| `frontend-design` | **produire** de l'UI visuelle |
| `vercel-react-best-practices` (76 règles) | **review uniquement** — checklist perf finale. Jamais en build/plan. |
| `web-design-guidelines` | **review** UI / a11y / UX |

Ordre d'autorité : **conventions du projet → comportement officiel du framework →
skills installés**. Jamais forcer un skill si une simple inspection suffit.

---

## 📁 Structure du repo

```
opencode.json            # agents, modèles, permissions, composition des prompts
prompts/
  _core.md               # doctrine partagée (chargée pour tous via `instructions`)
  pattern-radar.md       # bloc Pattern Radar partagé (plan / review / pattern-scan)
  brainstorm.md plan.md build.md review.md pattern-scan.md   # rôle de chaque agent
commands/
  capture.md             # /capture
  pattern-scan.md        # /pattern-scan (épinglé au subagent pattern-scan)
bin/
  capture.sh             # écriture du journal (résolution dossier + projet + date)
.agents/skills/          # skills installés (PatternsDev, Vercel, design)
```

---

## 🔭 Reporté (assumé)

- **Apprentissage actif** (drill, répétition espacée) — capture suffit pour l'instant.
- **Portabilité Cursor/Copilot** — pont `AGENTS.md` le jour où j'y travaille vraiment.
- **Parallélisation** — utile surtout pour du fan-out de review sur gros diff.
- **Subagent dédié** au-delà de pattern-scan — seulement si un besoin devient récurrent.

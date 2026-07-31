# Workflow IA — config opencode

Adaptateur OpenCode du workflow IA personnel. La doctrine et les skills
canoniques vivent dans `cockpit/portable/`; ce dossier ne contient que les
modes, prompts, commandes, permissions et defaults propres à OpenCode. Sur une
nouvelle machine, l'adaptateur est copié dans `~/.config/opencode/`, tandis que
`AGENTS.md` et les skills partagés sont liés depuis Backpack. Les overrides
provider/modèle restent dans `~/.config/opencode/opencode.json`, préservé lors
des updates. Les extensions locales (`package.json`, lockfile, `node_modules`,
`.claude`) sont également préservées lorsqu'elles existent.

Le système : collaborer → planifier → exécuter → reviewer, avec en fil rouge la
**reconnaissance des patterns/anti-patterns** pour monter en autonomie.

---

## 🚀 « Je veux… » → quoi utiliser (le cookbook)

| Ma situation | J'utilise | Comment |
|---|---|---|
| Une idée floue, un arbitrage, choisir une archi (perso ou client), décider quoi faire | **interactive** | `Tab` → interactive |
| Besoin de contenu, parcours, page, UX/UI ou idée sans maquette | **design** ou **/design** | `Tab` → design, ou tape `/design ...` |
| Je débarque sur un codebase inconnu, je veux la carte des patterns existants | **/pattern-scan** | tape `/pattern-scan` (ou `/pattern-scan src/`) |
| Préparer un changement sûr : inspecter, comparer, plan d'exécution | **plan** | `Tab` → plan |
| Implémenter le changement validé | **build** | `Tab` → build |
| Valider un diff / PR avant livraison | **/review** | tape `/review` |
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
| **Command vers agent primaire** | une *action* contextuelle | `/nom` | partagé (ma conversation) |
| **Subagent** | une *tâche* isolée occasionnelle | `/nom` épinglé, ou délégation | isolé (jetable) |

Règle : **phase récurrente que je conduis = agent primaire**. **Action dans le
contexte courant = command vers agent primaire**. **Tâche lourde/isolée
occasionnelle = subagent.**

---

## 👥 Les agents

### Primaires visibles (rotation `Tab`)

| Agent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **interactive** | Cadrer, challenger, comparer, décider. Ne lit **pas** le code (c'est volontaire : altitude décision). | Profil local | ❌ read-only |
| **design** | Cadrer contenu, parcours, UX/UI ou idée sans maquette dans le contexte courant. | Profil local | ❌ read-only |
| **plan** | Inspecter en read-only, produire un plan d'exécution. Pattern Radar obligatoire. | Profil local | ❌ read-only |
| **build** | Implémenter le plan, diffs minimaux, validation ciblée. | Profil local | ✅ edit autorisé |

Flux par défaut : **interactive → plan → build → /review**. Pour du contenu,
parcours, page, UX/UI ou une UI sans maquette : **design → build → /review**.
`/design` est un raccourci vers l'agent primaire `design`, donc il garde le
contexte de la conversation courante. Chaque agent recommande le suivant.
Greenfield *et* brownfield sont gérés ; pour un projet perso où je veux
**apprendre** une archi, je l'annonce explicitement pour débrayer le réflexe
« fais simple ».

Note : `build` peut éditer les fichiers, mais les commandes shell restent en
validation `ask` par défaut. C'est volontaire : moins de friction sur les diffs,
garde-fou sur l'exécution.

### Actions et subagents internes

| Command / subagent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **/design** → `design` | Façade content/UX/UI contextuelle : classe la demande en content-led, UI-led ou mixed, puis produit le bon contrat read-only. | Profil local | ❌ read-only |
| **/review** | Reviewer un diff strictement. Verdicts APPROVE / REQUEST CHANGES / ESCALATE. Pattern Radar obligatoire. | Profil local | ❌ read-only |

### Subagent (à la demande)

| Subagent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **pattern-scan** | Cartographier les patterns (archi / JS / framework) d'un codebase inconnu. Contexte isolé. | Profil local | ❌ read-only |

Lancé via `/pattern-scan`. Le mode courant n'a aucune importance : la command est
épinglée au subagent (modèle cheap, read-only, contexte vierge garantis).

---

## ⌨️ Les commands

| Command | Fait quoi | Dépend du mode ? |
|---|---|---|
| **/design** `[besoin]` | Produit le bon contrat content/UX/UI : audit contenu, architecture narrative, parcours, page ou UI code-first. Garde le contexte courant. | Non (agent primaire `design`) |
| **/pattern-scan** `[scope]` | Lance le subagent pattern-scan sur un dossier (défaut : tout le projet). | Non (épinglé) |
| **/review** `[scope]` | Lance l'agent review sur le diff courant ou un scope donné. | Non (épinglé) |
| **/capture** `[texte]` | Append les patterns discutés (ou le texte donné) au journal perso. Sortie 1 ligne. | Non (autorisé partout) |

### Le journal de capture
- Emplacement : **`~/dev/ai/pattern-captures/<projet>.md`** — **un fichier par
  projet** (nom auto-détecté via git), créé automatiquement. Le script **append**
  (jamais d'écrasement) — chaque fichier est le journal cumulatif d'un projet.
- Chaque entrée : en-tête de date + les patterns.
- Usage : je relis en fin de journée, je note ce que je veux creuser, j'étudie de
  mon côté. (Branchement Obsidian plus tard = changer le script portable
  `pattern-capture`.)

---

## 🎯 Patterns / anti-patterns (objectif apprentissage)

Deux niveaux, séparés exprès :

1. **Lentille (gratuite, automatique)** — le **Pattern Radar** tourne dans `plan`,
   `/review` et `pattern-scan`. Il **nomme** chaque pattern avec son nom canonique
   (le nom est le but : c'est ce que je retiens et vais chercher). Il juge sa
   propre pertinence (« rien de notable » plutôt qu'inventer).
2. **Capture (volontaire)** — quand un nom m'intrigue, `/capture` le met de côté.

---

## 🧩 Les skills (séparés par rôle → zéro overlap)

| Skill(s) | Rôle |
|---|---|
| `brand-messaging`, `website-content-architecture`, `website-copywriting` | **content design** : audience, promesse, navigation, section narrative, CTA, copy et readiness |
| `code-first-product-design` | **cadrer** une UI sans maquette : besoin métier → contrat content/UX/UI prêt pour `build` |
| `design-quality-standards` | **qualité design** : hiérarchie, typo, spacing, couleur, a11y, responsive, anti-slop |
| `frontend-design` | **produire** de l'UI visuelle distinctive (skill Anthropic) |
| `style-refined-product`, `style-editorial-saas`, `style-bento-dashboard`, `style-developer-minimal`, `style-friendly-consumer` | **directions visuelles optionnelles** — une seule à la fois, jamais par défaut en brownfield |
| `pattern-scan`, `pattern-capture` | **apprentissage portable** : cartographier puis conserver les patterns établis |

Ordre d'autorité : **conventions du projet → comportement officiel du framework →
skills installés**. Jamais forcer un skill si une simple inspection suffit.

Dans le menu `/`, utilise **`/design`** comme entrée utilisateur pour contenu,
parcours, UX et UI. Les skills content/design peuvent apparaître dans la liste,
mais ce sont des outils internes du workflow `design`, pas des commandes à lancer
directement.

---

## 📁 Structure du repo

```
../portable/
  AGENTS.md              # doctrine canonique partagée par tous les outils
  skills/                # skills standard partagés via ~/.agents/skills
opencode.json            # agents, permissions, modèles locaux
agents/
  product-design.md      # subagent isolé optionnel pour briefs design explicites
prompts/
  pattern-radar.md       # bloc Pattern Radar partagé (plan / review / pattern-scan)
  interactive.md product-design.md plan.md build.md review.md pattern-scan.md
                         # rôle de chaque agent primaire/subagent
commands/
  design.md              # /design → agent primaire design (contexte partagé)
  capture.md             # /capture
  pattern-scan.md        # /pattern-scan (épinglé au subagent pattern-scan)
  review.md              # /review (épinglé au subagent review)
plugins/
  rtk.ts                 # réécrit les commandes compatibles via rtk si présent
```

---

## 🔭 Reporté (assumé)

- **Apprentissage actif** (drill, répétition espacée) — capture suffit pour l'instant.
- **Adaptateurs supplémentaires** — seulement lorsqu'un outil ne sait lire ni
  `AGENTS.md` ni le standard `.agents/skills`.
- **Parallélisation** — utile surtout pour du fan-out de review sur gros diff.
- **Subagent dédié** au-delà de pattern-scan — seulement si un besoin devient récurrent.

---

## Config locale machine/client

Ce repo ne doit pas contenir de config client réelle. Après bootstrap,
`~/.config/opencode/` est la config effective lue par OpenCode et peut être
modifiée localement pour la machine courante :

```txt
~/.config/opencode/
  AGENTS.md -> backpack/cockpit/portable/AGENTS.md
  opencode.json
  agents/
  prompts/
  commands/
~/.agents/skills -> backpack/cockpit/portable/skills
```

Sur un PC client, ajoute les providers/modèles client directement dans
`~/.config/opencode/opencode.json`, puis relance OpenCode :

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "interactive",
  "model": "github-copilot/...",
  "small_model": "github-copilot/..."
}
```

Règle : Backpack initialise **comment** travailler ; la config locale machine
décide **avec quels modèles/providers** travailler.

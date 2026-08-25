# Workflow IA — config opencode

Adaptateur OpenCode du workflow IA personnel. La doctrine et les skills
canoniques vivent dans `cockpit/portable/`; ce dossier ne contient que les
modes, prompts, commandes, permissions et defaults propres à OpenCode. Sur une
nouvelle machine, l'adaptateur est copié dans `~/.config/opencode/`, tandis que
`AGENTS.md` et les skills partagés sont liés depuis Backpack. Les overrides
provider/modèle restent dans `~/.config/opencode/opencode.json`, préservé lors
des updates. Les extensions locales (`package.json`, lockfile, `node_modules`,
`.claude`) sont également préservées lorsqu'elles existent.

Le système : **Plan → Build → Validate → Learn**. Validate combine une Code
Review et une Product QA indépendantes ; Learn capitalise uniquement les
enseignements réutilisables.

---

## 🚀 « Je veux… » → quoi utiliser (le cookbook)

| Ma situation | J'utilise | Comment |
|---|---|---|
| Une idée floue, un arbitrage, choisir une archi (perso ou client), décider quoi faire | **interactive** | `Tab` → interactive |
| Mon prompt est long, ambigu ou répétitif | automatique | Cockpit laisse passer les prompts clairs, normalise sans risque, ou demande validation si le sens peut changer |
| Je veux voir et contrôler explicitement la reformulation | **/refine** | tape `/refine ...`, vérifie la proposition, puis valide-la explicitement |
| Besoin de contenu, parcours, page, UX/UI ou idée sans maquette | **design** ou **/design** | `Tab` → design, ou tape `/design ...` |
| Je débarque sur un codebase inconnu, je veux la carte des patterns existants | **/pattern-scan** | tape `/pattern-scan` (ou `/pattern-scan src/`) |
| Préparer un changement sûr : inspecter, comparer, plan d'exécution | **plan** | `Tab` → plan |
| Implémenter le changement validé | **build** | `Tab` → build |
| Vérifier tout le changement avant livraison | **/validate** | tape `/validate` |
| Faire uniquement une Code Review | **/review** | tape `/review` |
| Faire uniquement la Product QA fonctionnelle | **/qa** | tape `/qa` |
| Tirer les leçons d'une tranche terminée | **/learn** | tape `/learn` |
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
| **Command contextuelle** | une *action* qui doit garder le contrat courant | `/nom` | partagé (ma conversation) |
| **Subagent** | une *lentille* isolée à laquelle l'orchestrateur transmet un contrat explicite | délégation | isolé (jetable) |

Règle : **phase récurrente que je conduis = agent primaire**. **Porte de
livraison ou apprentissage qui dépend de la conversation = command contextuelle**.
**Lentille indépendante = subagent avec un contrat explicite transmis par son
parent.**

---

## 👥 Les agents

### Primaires visibles (rotation `Tab`)

| Agent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **interactive** | Cadrer, challenger, comparer, décider. Ne lit **pas** le code (c'est volontaire : altitude décision). | Profil local | ❌ read-only |
| **design** | Cadrer contenu, parcours, UX/UI ou idée sans maquette dans le contexte courant. | Profil local | ❌ read-only |
| **plan** | Inspecter en read-only, produire un plan d'exécution. Pattern Radar obligatoire. | Profil local | ❌ read-only |
| **build** | Implémenter le plan, diffs minimaux, validation ciblée. | Profil local | ✅ edit autorisé |

Flux par défaut : **interactive → plan → build → /validate**. Pour du contenu,
parcours, page, UX/UI ou une UI sans maquette : **design → build → /validate**.
`/design` est un raccourci vers l'agent primaire `design`, donc il garde le
contexte de la conversation courante. Chaque agent recommande le suivant.
Greenfield et brownfield suivent le même cycle, avec une stratégie différente.
En greenfield solo, Cockpit établit progressivement le contrat produit/design et
les premières conventions sans simuler une équipe absente. En brownfield, il
inspecte et préserve les contrats existants.

Note : `build` peut éditer les fichiers, mais les commandes shell restent en
validation `ask` par défaut. C'est volontaire : moins de friction sur les diffs,
garde-fou sur l'exécution.

### Actions et subagents internes

| Command / subagent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **/refine** | Prépare une version clarifiée du prompt, montre l'original et les changements, puis s'arrête avant exécution. | Profil local | ❌ read-only |
| **/design** → `design` | Façade content/UX/UI contextuelle : classe la demande en content-led, UI-led ou mixed, puis produit le bon contrat read-only. | Profil local | ❌ read-only |
| **/review** | Code Review stricte. Verdicts APPROVE / REQUEST CHANGES / ESCALATE. | Profil local | ❌ read-only |
| **/qa** | Product QA contextuelle contre les exigences, parcours, états et comportements visibles. | Profil local | ❌ read-only |
| **/validate** | Conserve le contrat courant, délègue `/review` et `/qa`, puis produit le statut RTS consolidé. | Profil local | ❌ read-only |
| **/learn** | Conserve le contexte de la tranche, puis réfléchit, extrait et codifie les connaissances réutilisables. | Profil local | ❌ produit read-only |

### Subagent (à la demande)

| Subagent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **pattern-scan** | Cartographier les patterns (archi / JS / framework) d'un codebase inconnu. Contexte isolé. | Profil local | ❌ read-only |

Lancé via `/pattern-scan`, le spécialiste devient l'agent actif de la session
courante et reste read-only. Une délégation ou une invocation `@pattern-scan`
crée, elle, une session enfant isolée.

---

## ⌨️ Les commands

| Command | Fait quoi | Dépend du mode ? |
|---|---|---|
| **/refine** `[brouillon]` | Raffine le prompt en mode Safe, expose les changements et attend une validation explicite sans l'exécuter. | Non (contextuel) |
| **/design** `[besoin]` | Produit le bon contrat content/UX/UI : audit contenu, architecture narrative, parcours, page ou UI code-first. Garde le contexte courant. | Non (agent primaire `design`) |
| **/pattern-scan** `[scope]` | Lance le subagent pattern-scan sur un dossier (défaut : tout le projet). | Non (épinglé) |
| **/review** `[scope]` | Lance uniquement la Code Review technique en gardant le contexte courant. | Non (contextuel) |
| **/qa** `[scope]` | Lance uniquement la Product QA fonctionnelle en gardant le contexte courant. | Non (contextuel) |
| **/validate** `[scope]` | Garde le contrat courant, lance les deux lentilles et consolide `READY TO SHIP`, `CHANGES REQUIRED` ou `DEPENDENCY PENDING`. | Non (contextuel) |
| **/learn** `[scope]` | Analyse la tranche courante et route les connaissances utiles. | Non (contextuel) |
| **/capture** `[texte]` | Append les patterns discutés (ou le texte donné) au journal perso. Sortie 1 ligne. | Non (autorisé partout) |

`READY TO SHIP` n'autorise aucune action Git. Après RTS, Cockpit affiche le diff,
les preuves, les risques et l'état Git, puis attend une instruction exacte :
`commit`, `push`, ou `commit and push`. Un simple « OK » n'est pas une
autorisation Git. `/learn` reste optionnel avant ou après cette instruction.

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
2. **Learn (volontaire)** — `/learn` fait la rétrospective et décide si une
   connaissance mérite d'être codifiée.
3. **Capture (primitive)** — `/capture` enregistre un pattern déjà établi lorsque
   `/learn` ou l'utilisateur décide de le conserver.

---

## 🧩 Les skills (séparés par rôle → zéro overlap)

| Skill(s) | Rôle |
|---|---|
| `brand-messaging`, `website-content-architecture`, `website-copywriting` | **content design** : audience, promesse, navigation, section narrative, CTA, copy et readiness |
| `impeccable` | **skill UX/UI unique** : shape, critique, direction visuelle, audit, polish, hardening et itération live |
| `pattern-scan`, `pattern-capture` | **apprentissage portable** : cartographier puis conserver les patterns établis |
| `prompt-refinement` | **préparer automatiquement** un prompt : bypass s'il est clair, flow-through éditorial, validation si le sens peut changer |

Ordre d'autorité : **conventions du projet → comportement officiel du framework →
skills installés**. Jamais forcer un skill si une simple inspection suffit.

Dans le menu `/`, utilise **`/design`** comme entrée utilisateur pour contenu,
parcours, UX et UI. Backpack orchestre; Impeccable prend l'UX/UI lorsqu'il est
installé dans le projet avec `backpack add impeccable`.

---

## 📁 Structure du repo

```
../portable/
  AGENTS.md              # doctrine canonique partagée par tous les outils
  skills/                # skills standard partagés via ~/.agents/skills
opencode.json            # agents, permissions, modèles locaux
agents/
  product-design.md      # subagent isolé optionnel pour briefs design explicites
  qa.md validate.md      # Product QA et porte de livraison RTS
  learn.md                # rétrospective et capitalisation
prompts/
  pattern-radar.md       # bloc Pattern Radar partagé (plan / review / pattern-scan)
  interactive.md product-design.md plan.md build.md review.md pattern-scan.md
                         # rôle de chaque agent primaire/subagent
commands/
  design.md              # /design → agent primaire design (contexte partagé)
  refine.md              # /refine → prépare un prompt et attend validation
  capture.md             # /capture
  qa.md validate.md       # Product QA et porte de livraison RTS
  learn.md                # rétrospective et capitalisation
  pattern-scan.md        # /pattern-scan (épinglé au subagent pattern-scan)
  review.md              # /review (épinglé au subagent review)
plugins/
  rtk.ts                 # réécrit les commandes compatibles via rtk si présent
```

---

## 🔭 Reporté (assumé)

- **Apprentissage actif** (drill, répétition espacée) — Learn et capture suffisent
  pour l'instant.
- **Adaptateurs supplémentaires** — seulement lorsqu'un outil ne sait lire ni
  `AGENTS.md` ni le standard `.agents/skills`.
- **Parallélisation** — utile surtout pour du fan-out de review sur gros diff.
- **Automatisation du déploiement** — RTS reste volontairement séparé des actions
  Git et de déploiement.
- **Optimisation mesurée de prompts** — nécessite un dataset représentatif, des
  critères de succès et des évaluations comparatives ; `/refine` reste un
  raffinement one-shot sans prétendre mesurer un optimum.

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

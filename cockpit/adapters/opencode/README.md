# Workflow IA — config opencode

Adaptateur OpenCode du workflow IA personnel. La doctrine et les skills
canoniques vivent dans `cockpit/portable/`; ce dossier ne contient que les
agents, prompts, commandes, permissions et defaults propres à OpenCode. Sur une
nouvelle machine, l'adaptateur est copié dans `~/.config/opencode/`, tandis que
`AGENTS.md` et les skills partagés sont liés depuis Backpack. Chaque installation
remplace l'adaptateur local complet après l'avoir déplacé dans une sauvegarde
horodatée. Les changements durables se font donc dans ce dossier canonique avant
réinstallation.

Le système : **Plan → Build → Validate → Learn**. Validate combine une Code
Review et une Product QA indépendantes ; Learn capitalise uniquement les
enseignements réutilisables.

---

## 🚀 « Je veux… » → quoi utiliser (le cookbook)

| Ma situation | J'utilise | Comment |
|---|---|---|
| Une idée floue, un arbitrage, choisir une archi (perso ou client), décider quoi faire | **build** ou **/cockpit-brainstorm** | demande directement, ou tape `/cockpit-brainstorm ...` pour une exploration read-only |
| Mon prompt est long, ambigu ou répétitif | automatique | Cockpit laisse passer les prompts clairs, normalise sans risque, ou demande validation si le sens peut changer |
| Je veux voir et contrôler explicitement la reformulation | **prompt-refinement** | invoque le skill, vérifie la proposition, puis valide-la explicitement |
| Besoin de contenu, parcours, page, UX/UI ou idée sans maquette | **build** ou **/cockpit-design** | demande directement, ou tape `/cockpit-design ...` pour isoler le contrat design |
| Je débarque sur un codebase inconnu, je veux la carte des patterns existants | **pattern-scan** | invoque le skill avec le scope voulu |
| Préparer une branche de travail depuis une base distante à jour | **cockpit-start-work** | invoque le skill avec la branche et la base |
| Préparer un changement sûr : inspecter, comparer, plan d'exécution | **plan** | `Tab` → plan |
| Implémenter le changement validé | **build** | `Tab` → build |
| Vérifier tout le changement avant livraison | **cockpit-validate** | invoque le skill portable |
| Faire uniquement une Code Review | **/cockpit-review** | tape `/cockpit-review` |
| Faire uniquement la Product QA fonctionnelle | **/cockpit-qa** | tape `/cockpit-qa` |
| Tirer les leçons d'une tranche terminée | **cockpit-learn** | invoque le skill portable |
| Un pattern/anti-pattern croisé m'intéresse, je veux le garder pour l'étudier plus tard | **pattern-capture** | invoque le skill portable |
| On me propose plein de texte, je veux juste choisir | les agents proposent A/B/C | réponds par la lettre |

**Le doute le plus fréquent — `pattern-scan` ou `pattern-capture` ?**
- **`pattern-scan`** = *LIRE* un codebase entier pour en sortir la carte des
  patterns. Au **début** d'un projet. Ça produit de l'info.
- **`pattern-capture`** = *SAUVEGARDER* un pattern déjà mentionné dans la conversation,
  dans mon journal perso. **Pendant** le travail. Ça archive une note.
- Moyen mnémo : **scan = découvrir / capture = garder.**

---

## 🧠 Le modèle mental

| Type | Ce que c'est | Comment j'y accède | Contexte |
|---|---|---|---|
| **Agent primaire** | une posture durable et son enveloppe de permissions | `Tab` pour switcher | partagé (ma conversation) |
| **Command** | une recette nommée et répétable | `/nom` | courant ou agent déclaré |
| **Skill** | un savoir-faire chargé à la demande | automatique | ajouté à l'agent actif |
| **Subagent** | un spécialiste auquel le primaire délègue un contrat borné | automatique ou `@nom` | enfant isolé |
| **Auto** | l'approbation automatique des permissions `ask` | palette/CLI OpenCode | ne change ni agent ni workflow |

Règle : **posture durable ou permissions propres = agent primaire**. **Recette
répétable = command**. **Expertise injectée = skill**. **Contexte ou verdict
indépendant = subagent**. `auto` ne contourne jamais un `deny` explicite.

---

## 👥 Les agents

### Primaires visibles (rotation `Tab`)

| Agent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **plan** | Inspecter en read-only, produire un plan d'exécution. Pattern Radar obligatoire. | Profil local | ❌ read-only |
| **build** | Agent par défaut : discuter, diagnostiquer, planifier proportionnellement, implémenter si autorisé et valider. | Profil local | ✅ edit autorisé |

Rester dans **build** pour le travail quotidien. Passer à **plan** uniquement
pour garantir une posture de planification durable sans modification. Pour du
contenu, parcours, page, UX/UI ou une UI sans maquette, `build` charge les skills
adaptés ou `/cockpit-design` isole explicitement le contrat design.

Le plan inspecte aussi profondément que le risque l'exige, mais restitue par
défaut un résultat compact : statut, cinq faits matériels au plus, sept étapes
avec leur preuve, trois risques et trois questions bloquantes. Les limites sont
souples lorsqu'une omission rendrait le plan dangereux. Un dépôt, contrat ou
arbitrage manquant produit un arrêt anticipé `DEPENDENCY PENDING` ou
`DECISION NEEDED`, sans plan détaillé spéculatif.

Greenfield et brownfield suivent le même cycle, avec une stratégie différente.
En greenfield solo, Cockpit établit progressivement le contrat produit/design et
les premières conventions sans simuler une équipe absente. En brownfield, il
inspecte et préserve les contrats existants.

`build` peut éditer les fichiers, mais les commandes shell restent en validation
`ask` par défaut. `plan` refuse les edits et le shell : OpenCode `auto` ne peut
donc pas transformer une session Plan en session d'implémentation. Les lentilles
`/cockpit-review` et `/cockpit-qa` refusent aussi le shell : elles utilisent les
preuves déjà disponibles et signalent une preuve manquante plutôt que d'exécuter
un check ou de conclure sans fondement.

### Surfaces publiques et subagents internes

| Command / subagent | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| **/cockpit-brainstorm** → `plan` | Explore plusieurs options et recommande une direction sans implémenter. | Profil local | ❌ read-only |
| **prompt-refinement** | Prépare une version clarifiée du prompt, montre l'original et les changements, puis s'arrête avant exécution. | Profil local | ❌ read-only |
| **/cockpit-design** → `product-design` | Isole un contrat content/UX/UI : classe la demande en content-led, UI-led ou mixed. | Profil local | ❌ read-only |
| **/cockpit-review** | Code Review stricte. Verdicts APPROVE / REQUEST CHANGES / ESCALATE. | Profil local | ❌ read-only |
| **/cockpit-qa** | Product QA contextuelle contre les exigences, parcours, états et comportements visibles. | Profil local | ❌ read-only |
| **cockpit-validate** | Conserve le contrat courant, délègue Code Review et Product QA, puis produit le statut RTS consolidé. | Profil local | ❌ read-only |
| **cockpit-learn** | Conserve le contexte de la tranche, puis réfléchit, extrait et route les connaissances réutilisables. | Profil local | ❌ produit read-only |
| **pattern-scan** | Cartographie les patterns établis d'un codebase inconnu. | Profil local | ❌ read-only |

### Modèle et provider

L'adaptateur n'épingle aucun modèle, ni sur les agents principaux ni sur les
subagents. Le modèle choisi dans la session OpenCode est hérité par
`cockpit-validate`, Code Review, Product QA, Learn et les autres délégations. Changer de provider via
le sélecteur de modèles change donc toute la vague suivante ; une requête déjà
lancée conserve naturellement son modèle de départ.

Les tiers Maximum, Frontier et Balanced de `cockpit/portable/MODELS.md` sont des
recommandations de sélection, pas un routage silencieux. Astra est réservé aux
travaux les plus difficiles ou conséquents ; Sol reste le choix de planification
et de review à risque, et Terra couvre le travail quotidien comme l'exécution
routinière. Avant un travail substantiel, Cockpit propose un changement lorsque
le modèle courant connu est insuffisant ou inutilement coûteux, puis attend une
réponse oui/non. OpenCode ne fournit pas d'API officielle pour sélectionner
directement un modèle précis dans la session, et Backpack n'ajoute pas de plugin
de reroutage masqué. Cockpit annonce donc cette limite dans sa recommandation :
changer le modèle avec `/models`, puis répondre `yes` une fois le modèle actif,
ou `no` pour continuer sans changement. Pour confirmer le canal réel et ses
limites, utiliser l'affichage natif d'OpenCode ou un outil de quota explicitement
choisi.

---

## ⌨️ Les surfaces utilisateur

Les capacités partagées sont exposées directement par leur skill canonique :
`cockpit-validate`, `cockpit-learn`, `cockpit-start-work`, `pattern-scan`,
`pattern-capture` et `prompt-refinement`. OpenCode ne maintient aucun alias
supplémentaire pour ces capacités.

Les commandes restantes sont strictement propres à l'hôte :

| Command | Fait quoi | Dépend du mode ? |
|---|---|---|
| **/cockpit-brainstorm** `[sujet]` | Explore trois options, leurs compromis et une recommandation dans l'enveloppe read-only de `plan`. | Non (épinglé à `plan`) |
| **/cockpit-design** `[besoin]` | Produit le bon contrat content/UX/UI dans un sous-agent isolé. | Non (épinglé à `product-design`) |
| **/cockpit-review** `[scope]` | Lance uniquement la Code Review technique en gardant le contexte courant. | Non (contextuel) |
| **/cockpit-qa** `[scope]` | Lance uniquement la Product QA fonctionnelle en gardant le contexte courant. | Non (contextuel) |

`READY TO SHIP` n'autorise aucune action Git. Après RTS, Cockpit affiche le diff,
les preuves, les risques et l'état Git, puis attend une instruction exacte :
`commit`, `push`, ou `commit and push`. Un simple « OK » n'est pas une
autorisation Git. `cockpit-learn` reste optionnel avant ou après cette instruction.

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

1. **Lentille (gratuite, automatique)** — `plan` et `/cockpit-review` appliquent la règle
   portable sur les patterns établis. Le skill `pattern-scan` possède le contrat
   de cartographie explicite. Chaque lentille **nomme** les patterns
   avec leur nom canonique et préfère « rien de notable » à une invention.
2. **Learn (volontaire)** — `cockpit-learn` fait la rétrospective et décide si une
   connaissance mérite d'être codifiée.
3. **Capture (primitive)** — `pattern-capture` enregistre un pattern déjà établi lorsque
   `cockpit-learn` ou l'utilisateur décide de le conserver.

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

Dans le menu `/`, utilise **`/cockpit-design`** comme entrée utilisateur pour contenu,
parcours, UX et UI. Backpack orchestre; Impeccable prend l'UX/UI lorsqu'il est
installé dans le projet avec `backpack add impeccable`.

---

## 📁 Structure du repo

```
../portable/
  AGENTS.md              # doctrine canonique partagée par tous les outils
  skills/                # skills standard partagés via ~/.agents/skills
opencode.json            # agents et permissions propres à OpenCode
agents/
  product-design.md      # subagent isolé optionnel pour briefs design explicites
  qa.md                  # Product QA indépendante
prompts/
  plan.md build.md review.md
                         # contrats minces des agents primaires et de review
commands/
  cockpit-brainstorm.md  # /cockpit-brainstorm → plan read-only divergent
  cockpit-design.md      # /cockpit-design → subagent product-design isolé
  cockpit-qa.md          # /cockpit-qa → Product QA
  cockpit-review.md      # /cockpit-review → subagent review
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
  critères de succès et des évaluations comparatives ; `prompt-refinement` reste un
  raffinement one-shot sans prétendre mesurer un optimum.

---

## Config effective et récupération

Ce repo ne doit pas contenir de config client réelle. Après bootstrap,
`~/.config/opencode/` est la copie effective lue par OpenCode :

```txt
~/.config/opencode/
  AGENTS.md -> backpack/cockpit/portable/AGENTS.md
  opencode.json
  agents/
  prompts/
  commands/
~/.agents/skills/
  <skill core> -> backpack/cockpit/portable/skills/<skill core>
```

Une modification locale peut servir d'essai, mais la prochaine installation la
remplacera. Pour la pérenniser, reporte uniquement le changement voulu dans
`cockpit/adapters/opencode/opencode.json`, vérifie le diff Git, puis réinstalle.
Si elle a déjà été remplacée, compare avec le dossier
`~/.config.backup.<timestamp>/.../.config/opencode/` affiché par l'installateur.

Sur un PC client, sélectionner le modèle dans la session est préférable. Une
surcharge locale reste temporaire et ne doit jamais être remontée dans Backpack
si elle contient des providers, endpoints, politiques ou secrets propres au
client :

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "build",
  "model": "github-copilot/..."
}
```

Règle : Backpack est la source de vérité de l'adaptateur ; l'installation
remplace sa copie locale et sauvegarde l'état précédent pour récupération.

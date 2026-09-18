# Choix d'une app desktop de coding agent

> Brainstorming vivant — 27 août 2026

## Périmètre

Comparer uniquement les **applications desktop** utilisées comme environnement
principal de travail avec un agent de code.

Le CLI, le TUI et les extensions IDE ne sont pas évalués comme interfaces
principales. Leur moteur sous-jacent ne compte que lorsqu'il améliore ou limite
concrètement l'expérience desktop.

Applications considérées actuellement :

- OpenCode Desktop ;
- Codex Desktop ;
- Claude Desktop, onglet Code ;
- GitHub Copilot Desktop ;
- autre candidat seulement après un essai réel.

## Décision à prendre

Choisir progressivement :

1. une app desktop principale pour Plan → Build → Validate → Learn ;
2. éventuellement une app secondaire si elle couvre une capacité décisive que
   l'app principale ne fournit pas ;
3. ou une app unique si le coût du changement de contexte dépasse le bénéfice
   de la spécialisation.

La décision doit venir de l'usage réel, pas des annonces produit ni d'une liste
de fonctionnalités.

## Besoins importants

### Backpack Engineering et personnalisation

- instructions personnelles et projet fiables ;
- skills ou capacités portables ;
- commandes explicites pour les workflows récurrents ;
- agents spécialisés configurables ;
- visibilité de la phase active et des capacités déclenchées ;
- conservation de la configuration lors des mises à jour.

### Boucle de développement

- inspection et édition efficaces du dépôt ;
- diff lisible et contrôle fin des changements ;
- terminal et processus longs correctement intégrés ;
- permissions compréhensibles sans friction excessive ;
- modèles et providers adaptés au besoin ;
- stabilité sur des tâches longues et multi-étapes.

### Canal de consommation

- possibilité d'utiliser le budget ou le siège professionnel ;
- coût personnel incrémental ;
- limites mesurables sur une journée et une semaine réelles ;
- repli possible sans perdre le cadre Backpack Engineering.

### Product QA desktop

- navigateur réellement intégré à l'app ;
- ouverture fiable de localhost et des environnements distants ;
- navigation et interaction par l'agent ;
- inspection visuelle, screenshots et console ;
- annotation d'un élément ou d'une zone par l'utilisateur ;
- transfert de l'annotation au chat avec le bon contexte ;
- boucle correction → rechargement → vérification sans changer d'app.

## Observations actuelles

### OpenCode Desktop

Points forts observés :

- engineering très personnalisable ;
- commandes host-only pour les actions sans skill portable équivalent ;
- agents et configuration explicites ;
- Backpack y expose aujourd'hui son workflow le plus visible ;
- couvre déjà l'essentiel des besoins quotidiens hors QA visuelle intégrée.

Limite actuelle :

- pas encore de navigateur intégré publié avec une boucle d'annotation comparable
  à Codex.

Évolution à surveiller :

- une [pull request officielle en brouillon](https://github.com/anomalyco/opencode/pull/44838)
  ajoute un navigateur desktop expérimental avec panneau intégré, navigation,
  contrôle par l'agent et politiques de sécurité ;
- les annotations sont demandées dans
  [l'issue dédiée](https://github.com/anomalyco/opencode/issues/26772), mais elles
  ne sont pas garanties par la pull request actuelle ;
- aucune date de disponibilité ne doit être supposée avant fusion et publication.

Écosystème évalué via
[awesome-opencode](https://github.com/awesome-opencode/awesome-opencode) :

- [OpenCode Chromium](https://github.com/Quindart-com/opencode-chromium) couvre
  déjà l'automatisation d'un navigateur externe, les screenshots, le DOM, la
  console et le réseau. Il requiert toutefois une extension Chromium et un hôte
  natif : il ne recrée ni le navigateur intégré ni la boucle d'annotation Codex,
  et son MCP fonctionne également dans Codex ;
- [open-plan-annotator](https://github.com/ndom91/open-plan-annotator) apporte
  une interface d'annotation des plans, pas une annotation contextualisée de
  l'interface produit pendant la QA ;
- [opencode-quota](https://github.com/slkiser/opencode-quota) peut rendre visibles
  le provider, le quota et les tokens. C'est un observateur optionnel utile pour
  le benchmark, pas un correctif de routage ni une dépendance Backpack Engineering ;
- les frameworks multi-agents et workflows complets de la liste recouvrent la
  responsabilité de Backpack Engineering. Les empiler augmenterait le bruit, les conflits de
  doctrine et la maintenance sans résoudre le déficit d'UX desktop.

### Codex Desktop

Points forts observés :

- navigateur intégré utile pour la Product QA ;
- annotations visuelles directement reliées à la conversation ;
- boucle interface → feedback → correction particulièrement fluide ;
- skills portables, déclenchables explicitement ou automatiquement.

Points à évaluer :

- fiabilité réelle des skills Backpack Engineering comme surface d'entrée quotidienne ;
- visibilité et indépendance de Code Review et Product QA dans les subagents ;
- maintien du cadre sur une tâche longue sans rappels manuels.

### Claude Desktop — Code

État : à tester sur des tranches comparables.

À vérifier :

- qualité de l'expérience navigateur et annotation ;
- exposition des skills, sous-agents et workflows personnels ;
- continuité entre inspection, modification et Product QA ;
- coût, limites et stabilité sur une journée de travail réelle.

### GitHub Copilot Desktop

État : candidat principal à éprouver sur les mêmes tranches que Codex.

Points forts établis :

- app agentique desktop avec sessions parallèles et worktrees isolés ;
- modes Interactive, Plan et Autopilot ;
- instructions globales et projet, skills et serveurs MCP ;
- intégration native des issues, pull requests et checks GitHub ;
- navigateur intégré configurable pour ouvrir l'application locale ;
- consommation possible sur le canal GitHub Copilot professionnel ;
- Backpack Engineering expose Validate, Learn et Start Work comme skills portables, sans
  dépendre d'une commande custom propre à OpenCode.

Ces capacités sont documentées dans la
[présentation officielle de Copilot App](https://docs.github.com/en/copilot/concepts/agents/github-copilot-app).
Les forfaits organisationnels mutualisent leurs crédits et restent soumis aux
politiques et budgets administrateur ; vérifier le siège effectif dans la
[documentation des forfaits Copilot](https://docs.github.com/en/copilot/get-started/plans).

À vérifier :

- visibilité native et indépendance de Code Review et Product QA ;
- boucle d'annotation utilisateur comparable à Codex, non établie à ce jour ;
- politique du siège professionnel et budget de crédits réellement disponibles ;
- friction, stabilité et consommation par rapport à Codex sur la boucle complète.

## Hypothèse provisoire

GitHub Copilot App est le **candidat principal économique** : il promet une UX
desktop agentique proche du besoin tout en utilisant le canal professionnel.
Codex reste le **benchmark UX** grâce à sa boucle de QA visuelle, ses annotations
et son rendu natif compact des skills, outils et subagents.

Ne pas acheter le forfait Codex à 100 $ avant l'essai comparatif. Il devient
pertinent seulement si Codex gagne nettement en temps ou en qualité sur les
tâches réelles et si les limites du forfait actuel sont atteintes régulièrement.
Le forfait Pro à 100 $ apporte 5× la limite de Plus, pas un usage illimité ; les
fenêtres locales et d'éventuelles limites hebdomadaires restent décrites dans la
[tarification officielle de Codex](https://learn.chatgpt.com/docs/pricing).
OpenCode reste un témoin de portabilité et un repli provider, pas le candidat UX
principal tant que son app reste plus bruyante et moins fluide.

Cette hypothèse doit être invalidée ou confirmée par des tâches réelles.

## Protocole d'évaluation

Évaluer chaque app sur au moins trois tranches significatives :

1. une correction de bug brownfield ;
2. une évolution UI avec vérification responsive et états d'erreur ;
3. une tâche longue comprenant Plan, Build, Validate et Learn.

Pour chaque tranche, noter de 0 à 3 :

- `0` — impossible ou contournement majeur ;
- `1` — possible avec forte friction ;
- `2` — correct ;
- `3` — fluide et clairement différenciant.

| Date | Projet / tranche | App | Backpack Engineering | Build | QA visuelle | Stabilité | Changements d'app | Temps perdu | Conso / limite | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
|  |  |  |  |  |  |  |  |  |  |  |

Ne pas attribuer de score à une capacité seulement annoncée. Une fonctionnalité
compte lorsqu'elle est disponible dans la version utilisée et fonctionne sur un
cas réel.

## Règles de décision

Choisir GitHub Copilot App si :

- le cadre Backpack Engineering reste aussi fiable et lisible que dans Codex ;
- la QA visuelle suffit malgré l'écart éventuel sur les annotations ;
- le siège professionnel absorbe l'usage sans blocages fréquents ;
- le gain économique ne crée pas de coût cognitif ou de maintenance supérieur.

Choisir Codex seul et envisager le forfait à 100 $ si :

- le cadre Plan → Build → Validate → Learn reste fiable sans rappel manuel ;
- les skills et subagents rendent les activations et preuves suffisamment
  inspectables ;
- l'UX desktop et la QA intégrée réduisent nettement la friction sur les missions
  réelles ;
- le forfait actuel limite réellement plusieurs journées de travail et le temps
  gagné justifie les 80 $ mensuels supplémentaires par rapport à Plus.

Revenir à OpenCode comme app principale si :

- Codex dérive régulièrement hors du cadre ou mélange les phases ;
- Validate ne maintient pas deux lentilles indépendantes et vérifiables ;
- la personnalisation explicite d'OpenCode compense sa friction d'interface.

Conserver GitHub Copilot App + Codex Plus si :

- Copilot App couvre le quotidien sur le canal professionnel ;
- Codex reste ponctuellement meilleur pour une QA visuelle ou une annotation ;
- le passage entre les deux reste rare, intentionnel et moins coûteux que Pro.

Choisir une autre app principale si elle surpasse OpenCode sur la boucle complète,
pas seulement sur une fonctionnalité spectaculaire.

## Questions ouvertes

- À quelle fréquence les annotations ont-elles réellement évité un bug ou une
  mauvaise interprétation ?
- Un navigateur externe piloté par OpenCode suffit-il en pratique ?
- Le futur navigateur OpenCode permettra-t-il à l'utilisateur et à l'agent de
  travailler sur la même page sans conflit ?
- La personnalisation d'OpenCode fait-elle gagner du temps ou crée-t-elle une
  maintenance supplémentaire ?
- Copilot App rend-il Validate aussi clairement que les deux chips natives de
  Codex, sans bruit textuel supplémentaire ?
- Son navigateur permet-il une annotation utilisateur contextualisée ou seulement
  la navigation et le contrôle par l'agent ?
- Quel forfait Copilot professionnel est réellement attribué, avec quel budget
  de crédits additionnels autorisé par l'organisation ?
- Combien de fois Codex Plus atteint-il sa limite sur une semaine normale ?
- Quelle app conserve le mieux le contexte et la confiance sur une tâche longue ?
- Le coût cognitif d'une stratégie à deux apps reste-t-il inférieur à son gain ?

# Choix d'une app desktop de coding agent

> Brainstorming vivant — 25 août 2026

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

### Cockpit et personnalisation

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

- cockpit très personnalisable ;
- commandes custom comme `/learn` ;
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

### Codex Desktop

Points forts observés :

- navigateur intégré utile pour la Product QA ;
- annotations visuelles directement reliées à la conversation ;
- boucle interface → feedback → correction particulièrement fluide ;
- skills portables, déclenchables explicitement ou automatiquement.

Points à évaluer :

- cockpit moins directement personnalisable qu'OpenCode avec des commandes `/`
  arbitraires ;
- adéquation réelle de l'invocation par skills avec les workflows Backpack ;
- coût du maintien d'un second outil uniquement pour la QA visuelle.

### Claude Desktop — Code

État : à tester sur des tranches comparables.

À vérifier :

- qualité de l'expérience navigateur et annotation ;
- exposition des skills, sous-agents et workflows personnels ;
- continuité entre inspection, modification et Product QA ;
- coût, limites et stabilité sur une journée de travail réelle.

### GitHub Copilot Desktop

État : testé partiellement, preuve insuffisante pour trancher.

Observation actuelle :

- les skills installés sont visibles, mais le workflow `Learn` de Backpack n'est
  pas exposé comme commande custom équivalente à `/learn` dans OpenCode.

À vérifier :

- profondeur réelle de la personnalisation desktop ;
- qualité du navigateur et des annotations ;
- avantage apporté par l'intégration GitHub dans les missions courantes ;
- friction par rapport à OpenCode et Codex sur la boucle complète.

## Hypothèse provisoire

OpenCode est actuellement le meilleur candidat comme **app principale** grâce à
sa personnalisation et à la couverture du workflow complet. Codex reste le
meilleur candidat comme **app secondaire de Product QA visuelle** tant que le
navigateur OpenCode et les annotations ne sont pas disponibles et éprouvés.

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

| Date | Projet / tranche | App | Cockpit | Build | QA visuelle | Stabilité | Changements d'app | Temps perdu | Notes |
|---|---|---|---:|---:|---:|---:|---:|---:|---|
|  |  |  |  |  |  |  |  |  |  |

Ne pas attribuer de score à une capacité seulement annoncée. Une fonctionnalité
compte lorsqu'elle est disponible dans la version utilisée et fonctionne sur un
cas réel.

## Règles de décision

Choisir OpenCode seul si :

- son navigateur intégré couvre la QA quotidienne ;
- les annotations deviennent suffisantes ou leur absence ne produit pas de bugs
  ni de friction mesurable ;
- conserver Codex ne fournit plus de bénéfice régulier.

Conserver OpenCode + Codex si :

- OpenCode reste nettement meilleur pour piloter le workflow ;
- Codex détecte ou accélère régulièrement des corrections grâce à sa boucle de
  QA visuelle ;
- le passage entre les deux reste rare et intentionnel.

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
- Quelle app conserve le mieux le contexte et la confiance sur une tâche longue ?
- Le coût cognitif d'une stratégie à deux apps reste-t-il inférieur à son gain ?

# Découpage des tâches — Kid Matix

> **Copie de référence dans le dépôt.** Exportée le 9 octobre 2026 depuis le
> document d'origine
> (<https://claude.ai/code/artifact/7b5a98b9-745b-4527-b32c-c90647248333>).
> C'est ce fichier qui se coche désormais : passer une tâche de `- [ ]` à
> `- [x]` dans le même commit que le code qui la réalise, puis mettre à jour
> `docs/status.md` à la fin de chaque lot.
>
> Par rapport à l'export : les tâches de F0 sont cochées, les maquettes
> dessinées depuis sont référencées (`docs/design/`), et les deux points à
> trancher sur les règles de code sont clos.

L'application est découpée en 22 lots, de F0 à F21, à intégrer dans cet ordre ; chaque lot livre une fonctionnalité utilisable et testée. Le détail fonctionnel est dans les [spécifications](specifications.md), les écrans dans le [design](../design/README.md), les décisions dans [decisions.md](../decisions.md) et l'avancement dans [status.md](../status.md).

## Vue d'ensemble

Les lots F0 à F11 forment la version 1.0, F12 à F18 la version 1.1 et F19 à F21 la version 1.2. Un lot ne démarre que lorsque ceux dont il dépend sont terminés.

| Lot | Fonctionnalité | Version | Dépend de | Maquettes (`docs/design/screens/`) |
| --- | --- | --- | --- | --- |
| F0 | Socle du projet | 1.0 | Aucun | Thème commun à tous les écrans |
| F1 | Profils | 1.0 | F0 | 01, 02 |
| F2 | Moteur de quiz et domaine multiplication | 1.0 | F0 | Aucun, Dart pur |
| F3 | Session de quiz et résultats | 1.0 | F1, F2 | 06, 06b, 06c, 07, 09 |
| F4 | Maîtrise et répétition espacée | 1.0 | F3 | Aucun (fiche d'aide à dessiner) |
| F5 | Parcours | 1.0 | F3, F4 | 03, 04, 05 |
| F6 | Combat de boss | 1.0 | F5 | 08 |
| F7 | Récompenses | 1.0 | F3, F5 | 09, 03 |
| F8 | Mascotte qui grandit | 1.0 | F7 | 12 |
| F9 | Entraînement libre et Contre-la-montre | 1.0 | F3, F4, F7 | 10, 11 |
| F10 | Profil et réglages | 1.0 | F4, F7, F8 | 12, 13 |
| F11 | Finition et publication | 1.0 | F0 à F10 | Aucun |
| F12 | Révision du jour et Survie | 1.1 | F9 | 11 ; écran de Survie à dessiner |
| F13 | Mes monstres | 1.1 | F4, F6 | 14 |
| F14 | Duel sur le même téléphone | 1.1 | F1, F2 | 15 ; choix des joueurs à dessiner |
| F15 | Nouveaux formats de questions | 1.1 | F2, F3 | 16, 17 |
| F16 | Test de départ | 1.1 | F1, F5 | 18 |
| F17 | Classement local | 1.1 | F7 | 19 |
| F18 | Rappel quotidien | 1.1 | F10 | 13 (section Rappel) |
| F19 | Défi par code | 1.2 | F9 | 20, 21 |
| F20 | Sauvegarde par fichier | 1.2 | F1 | 13 (section Sauvegarde) |
| F21 | Autres langues et boutique | 1.2 | F7, F8 | 22 |

Les numéros de la dernière colonne sont les préfixes des captures de `docs/design/screens/` (par exemple `01-who-is-playing.png`) ; l'index complet est dans `docs/design/README.md`.

Les nouveaux domaines (la division en premier) et le mode en ligne viennent après la version 1.2 ; ils ne sont pas découpés ici.

## Règles communes à tous les lots

Chaque lot se code dans le même ordre : domaine, données, présentation, tests. Les tâches sont numérotées `F<lot>-<numéro>` et se cochent ici au fil de l'intégration. La vérification se lance avec `bash tool/check.sh`.

**Un lot est terminé quand**

- `flutter analyze` ne renvoie aucun avertissement, et le code respecte les règles de code ci-dessous.
- Les tests du lot passent, ainsi que toute la suite des lots précédents.
- Les écrans du lot correspondent au design.
- Tous les textes affichés sont dans le fichier de traduction, aucun dans le code.
- Tout changement de schéma a sa migration numérotée et son test.
- Le critère « Terminé quand » du lot est vérifié à la main sur un téléphone ou un émulateur.

**Deux points à prévoir avant de coder**

- Presque tous les écrans ont une maquette dans `docs/design/`. Restent à dessiner, avant leur lot : la fiche d'aide (F4), l'écran de Survie (F12), le choix des joueurs du duel (F14), l'opération à trous et les dialogues de confirmation (à dériver des écrans existants).
- La mascotte, les 12 monstres et les 12 avatars du design sont provisoires : les lots F1, F6 et F8 démarrent avec ces dessins et acceptent des illustrations définitives plus tard, sans changer le code.

## Règles de code à respecter

Tout le code suit les règles Flutter et Dart du propriétaire du projet, copiées dans `docs/rules/` : `flutter-architecture.md`, `dart-guidelines.md` et `code-examples.md`. En cas d'écart avec les spécifications ou avec ce découpage, ces règles priment.

| Sujet | Règle appliquée |
| --- | --- |
| Structure | Découpage par fonctionnalité puis par couche ; nom de dossier au singulier ; un `injection.dart` par fonctionnalité ; `core/` réservé au code utilisé par au moins deux fonctionnalités |
| Couches | `domain/` en Dart pur, sans Flutter ni paquet tiers ; `data/` dépend de `domain/` ; `presentation/` n'appelle que des cas d'usage |
| Entre fonctionnalités | Aucune fonctionnalité n'en importe une autre ; une entité partagée va dans `core/entities/`, une capacité partagée passe par une interface de `core/services/` implémentée dans la fonctionnalité qui la possède |
| Résultats et erreurs | Chaque appel de repository est dans un `try/catch` et renvoie un `DataState<T>` ; exceptions typées `AppException` avec un `AppErrorCode` ; le texte affiché est résolu dans la présentation par `AppLocalizations` |
| BLoC et Cubit | Appellent seulement des cas d'usage ; jamais enregistrés dans GetIt ; créés par `BlocProvider` à l'entrée de la page ; un état de chargement avant chaque opération asynchrone ; états en classes scellées |
| Parcours sur plusieurs pages | Un BLoC de flux partagé, porté par un `ShellRoute`, plus un BLoC par page |
| Injection | `registerLazySingleton` lié au type abstrait ; jamais de `sl<T>()` dans un widget |
| Navigation | Chemins dans `AppRoutes` ; garde dans `redirect`, jamais dans une page ; seuls des identifiants simples passent par les routes |
| Stockage | sqflite avec `version` et `onUpgrade`, une migration par version ; requêtes paramétrées ; accès derrière une interface `LocalDataSource` |
| Modèles et entités | `XxxLocalModel` générés par json_serializable, avec `toEntity()` ; `XxxEntity` avec `@immutable`, `copyWith`, `==` et `hashCode` |
| Widgets et interface | Jamais de `Widget _buildXxx()` ; `StatelessWidget` piloté par un BLoC ; `const` partout où c'est possible ; couleurs et styles par `ThemeData` ; textes par `AppLocalizations` |
| Dart | Code et documentation en anglais ; types toujours déclarés ; pas de `dynamic` ; lignes de 80 caractères ; fonctions de 20 instructions au plus ; classes de 200 lignes au plus ; pas de nombre magique ; constantes en lowerCamelCase, comme le veut le lint Dart (la règle SCREAMING_SNAKE_CASE est abandonnée) |
| Tests | Arrange, Act, Assert ; variables `inputX`, `mockX`, `actualX`, `expectedX` ; mocktail ; 80 % de couverture au moins sur `domain/` et `data/` |
| Accessibilité | `tooltip` sur chaque bouton icône ; zones de 48 px au moins ; jamais de sens porté par la couleur seule ; échelle de texte du système respectée ; animations réduites si le système le demande |
| Journalisation | `log()` de `dart:developer`, jamais `print()` ; `AppBlocObserver` ; erreurs non interceptées remontées depuis `main()` |

**Ce que ces règles changent dans le découpage**

1. Le dossier `app/` disparaît : routeur, thème, injection et widgets partagés vivent dans `core/`.
2. `DataState<T>` et `AppException` remplacent `Result` et les échecs typés prévus au départ.
3. Le code est en anglais : les noms de champs en français des spécifications sont traduits (`pseudoNormalise` devient `normalizedNickname`, `itemCle` devient `itemKey`).
4. Les contrats du moteur de quiz (`LearningDomain`, `QuestionType`, `Question`) vont dans `core/`, car le quiz, le parcours et les défis s'en servent.
5. Le joueur actif devient un service `ProfileSessionService` de `core/services/`, implémenté par la fonctionnalité profil et écouté par le routeur pour sa redirection.
6. La fin d'une session prévient la maîtrise, le parcours et les récompenses par des interfaces de `core/services/`, dans une seule transaction.
7. L'écran Résultats reçoit seulement l'identifiant de la session et la charge avec son propre Cubit.
8. equatable est retiré, et uuid sort du domaine : les identifiants passent par une interface `IdGenerator`.
9. json_serializable et build_runner sont ajoutés pour les modèles locaux.
10. Les règles de réseau (Dio, jetons, erreurs HTTP) et de stockage sécurisé ne s'appliquent qu'à partir du mode en ligne.

**Deux points tranchés** (détail dans `docs/decisions.md`)

- [x] Rapport de plantage : interface `CrashReporter` dans `core/services/`, avec l'implémentation locale `LogCrashReporter` en 1.0 ; un vrai service sera branché avec le mode en ligne.
- [x] Valeurs des règles du jeu (12 points de vie, 10 XP par réponse) : constantes nommées dans le domaine de la fonctionnalité qui les possède ; dans `core/constants/` seulement si deux fonctionnalités s'en servent.

## F0 · Socle du projet

Le socle met en place le projet, l'architecture, la base locale et le thème du design, sans aucune fonctionnalité de jeu.

**Projet**

- [x] **F0-01** Créer le projet Flutter pour Android et iOS, verrouillé en portrait, avec un nom et un identifiant provisoires.
- [x] **F0-02** Ajouter et figer les dépendances : flutter_bloc, get_it, go_router, sqflite, path, shared_preferences, uuid, meta, json_annotation ; en développement : build_runner, json_serializable, bloc_test, mocktail, sqflite_common_ffi pour tester la base hors téléphone.
- [x] **F0-03** Créer l'arborescence de vos règles : `lib/core/` (constants, di, entities, error, extensions, router, services, storage, theme, utils, widgets), `lib/features/`, `lib/l10n/` et `lib/main.dart`.
- [x] **F0-04** Nommer les fonctionnalités au singulier : `profile`, `multiplication`, `quiz`, `mastery`, `learning_path`, `reward`, `mascot`, `challenge`, `setting` ; chacune avec `data/`, `domain/`, `presentation/` et `injection.dart`.
- [x] **F0-05** Activer un lint aligné sur vos règles : lignes de 80 caractères, types déclarés, pas de `dynamic`, pas de `print()`, virgules finales.
- [x] **F0-06** Écrire un test d'architecture qui échoue si `domain/` importe Flutter ou un paquet tiers, ou si une fonctionnalité en importe une autre.
- [x] **F0-07** Copier vos trois fichiers de règles dans le projet (`docs/rules/`) et les référencer dans un fichier d'instructions à la racine, pour que chaque session de code les applique.

**Cœur technique (`core/`)**

- [x] **F0-08** `core/error/` : `DataState<T>` scellé (`DataSuccess`, `DataFailed`) et hiérarchie `AppException` portant un `AppErrorCode`.
- [x] **F0-09** Interfaces `UseCase<Output, Input>` et `NoParamUseCase<Output>`.
- [x] **F0-10** `core/services/` : interfaces `Clock`, `RandomSource` avec graine, `Ticker` pour le chrono, `IdGenerator` et `CrashReporter`.
- [x] **F0-11** `core/storage/` : base sqflite avec `version` et `onUpgrade`, une migration par version, clés étrangères activées, colonnes communes de dernière modification et de suppression logique ; enveloppe `LocalStorage` autour de shared_preferences.
- [x] **F0-12** Signal de changement par table, émis par les repositories après chaque écriture, pour que les BLoC rechargent leurs données.
- [x] **F0-13** `core/di/injection_container.dart` : `configureDependencies()` appelle le `registerXxxFeature()` de chaque fonctionnalité ; liaisons sur les types abstraits ; aucun BLoC enregistré.
- [x] **F0-14** `main.dart` minimal : `AppBlocObserver`, puis `FlutterError.onError` et `PlatformDispatcher.instance.onError` branchés sur `CrashReporter`.

**Routeur, thème et widgets partagés**

- [x] **F0-15** `core/router/` : chemins dans `AppRoutes`, `AppRouter` go_router, coquille à 4 onglets (Parcours, S'entraîner, Défis, Profil), `redirect` vers « Qui joue ? » ajouté avec F1, quand le joueur actif existe.
- [x] **F0-16** `core/theme/` : `AppColors`, `AppTextTheme` et `AppTheme` aux couleurs du design, polices Fredoka et Nunito embarquées pour fonctionner hors ligne ; tailles et espacements dans `core/constants/`.
- [x] **F0-17** `core/widgets/` : bouton en relief (primaire, secondaire), carte, barre de progression, pastille, bouton icône avec `tooltip`, barre d'onglets.
- [x] **F0-18** Traductions : fichier ARB français et génération d'`AppLocalizations`.
- [x] **F0-19** Script unique qui lance la génération de code, l'analyse et tous les tests.

**Tests**

- [x] **F0-20** Tests de `DataState`, de l'exécuteur de migrations sur une base en mémoire et du signal de changement.

**Terminé quand :** l'app démarre sur une coquille vide à 4 onglets, aux couleurs et polices du design et le test d'architecture passe. La base s'ouvre avec F1, à la création de sa première table.

**Notes de réalisation (F0, 9 octobre 2026)**

- F0-01 : le portrait est verrouillé à l'exécution (`SystemChrome` dans `main.dart`). Les manifestes natifs autorisent encore le paysage (`Info.plist`, `AndroidManifest.xml`) : à restreindre au plus tard en F11.
- F0-04 : les dossiers de fonctionnalités ne sont pas créés à l'avance ; chacun arrive avec son lot (`lib/features/README.md` donne la liste et le gabarit).
- F0-11 : la liste des migrations (`app_migrations.dart`) est vide et la base ne s'ouvre pas encore ; la première migration et l'ouverture arrivent avec F1-05.
- F0-13 : `configureDependencies()` n'appelle encore aucun `registerXxxFeature()` ; chaque lot ajoute le sien.
- F0-15 : le `redirect` vers « Qui joue ? » arrive avec F1-09 (`ProfileSessionService` comme `refreshListenable`).
- F0-19 : `bash tool/setup.sh` (une fois) puis `bash tool/check.sh` (à chaque changement).
- Reste à confirmer : la correction de la barre d'onglets faite après la dernière vérification complète (voir `docs/status.md`).

## F1 · Profils (Qui joue ?)

Plusieurs enfants partagent le téléphone, chacun avec son pseudo ; ce lot livre l'écran « Qui joue ? » et la création d'un joueur.

**Domaine**

- [x] **F1-01** Entités `Profile` (identifiant UUID, pseudo, avatar, couleur, XP total, niveau, dates) et `ProfileSettings`.
- [x] **F1-02** Contrat `ProfileRepository`.
- [x] **F1-03** Règles du pseudo : 2 à 12 caractères, lettres, chiffres et espaces ; forme normalisée sans casse ni accents pour l'unicité.
- [x] **F1-04** Cas d'usage `GetProfiles`, `CreateProfile` (pseudo unique, 10 profils au plus), `UpdateProfile`, `DeleteProfile`, `SelectProfile`.

**Données**

- [x] **F1-05** Migration : tables `profile` (index unique sur le pseudo normalisé, colonne de compte distant laissée vide) et `profile_settings`.
- [x] **F1-06** Source de données locale, modèles et conversions, implémentation du repository.
- [x] **F1-07** Dernier joueur actif mémorisé dans shared_preferences.
- [x] **F1-08** Suppression d'un profil en cascade sur toutes ses données.

**Présentation**

- [x] **F1-09** `ProfilesBloc` (chargement, liste, erreurs « pseudo pris » et « limite atteinte ») et `ProfileSessionService`.
- [x] **F1-10** Écran « Qui joue ? » : grille de cartes (avatar, pseudo, niveau, série), carte « Nouveau joueur », mascotte.
- [x] **F1-11** Écran de création : pseudo, choix parmi 12 avatars, couleur de fond, messages d'erreur adaptés à l'enfant. Maquette : `02-profile-creation.png`.
- [x] **F1-12** Les 12 avatars en ressources vectorielles.
- [x] **F1-13** Premier lancement : ouverture directe de la création de profil.
- [x] **F1-14** Renommer un joueur et changer son avatar.
- [x] **F1-15** Supprimer un joueur après une confirmation où l'enfant retape son pseudo.

**Tests**

- [x] **F1-16** Tests unitaires : normalisation du pseudo, doublon à la casse et aux accents près, limite de 10 profils.
- [x] **F1-17** Tests du repository sur une base en mémoire, cascade comprise.
- [x] **F1-18** Tests de `ProfilesBloc` et test de widget de « Qui joue ? ».

**Terminé quand :** on crée trois joueurs, on en choisit un, on ferme l'app, et on retrouve la liste et le dernier joueur au relancement.

## F2 · Moteur de quiz et domaine multiplication

Ce lot est du Dart pur : il fabrique les questions et valide les réponses, sans écran ni base de données. Ses contrats génériques vivent dans le dossier core, et le domaine multiplication forme une fonctionnalité à part.

**Contrats génériques**

- [x] **F2-01** Contrats `LearningDomain`, unité et item, chaque item portant une clé stable.
- [x] **F2-02** Contrat `QuestionType` : modèle de question, règle de validation, nature de la réponse (reconnue ou produite).
- [x] **F2-03** Modèles `Question` (énoncé, choix, réponse attendue, type, clé de l'item) et `Answer`.
- [x] **F2-04** Registres `DomainRegistry` et `QuestionTypeRegistry`.

**Domaine multiplication**

- [ ] **F2-05** `MultiplicationDomain` : 12 unités (tables de 1 à 12), 120 items de clé `mul:7x8`, ordre du parcours, une astuce par table.
- [ ] **F2-06** Types de questions de la version 1.0 : choix multiple, saisie, opération à trous, vrai ou faux.
- [ ] **F2-07** `DistractorGenerator` : résultat voisin dans la même table, résultat de la table voisine, confusion avec l'addition, chiffres inversés ; jamais de doublon ni de nombre négatif ; position de la bonne réponse aléatoire.
- [ ] **F2-08** Vrai ou faux : affirmation vraie une fois sur deux, erreur plausible sinon.
- [ ] **F2-09** `QuestionGenerator` : construit les questions d'une liste d'items avec les types autorisés ; jamais le même fait deux fois de suite ; tirage reproductible avec une graine.

**Tests**

- [ ] **F2-10** Les 120 clés sont uniques et stables.
- [ ] **F2-11** Mauvaises réponses : 3 choix distincts, différents de la bonne réponse, pour les 120 faits.
- [ ] **F2-12** Même graine, mêmes questions ; validation de chaque type de question.

**Terminé quand :** tous les tests passent et le lot n'importe aucun paquet Flutter.

## F3 · Session de quiz et résultats

Ce lot livre la boucle de jeu : une série de questions avec chrono, un retour immédiat après chaque réponse, puis l'écran de résultats.

**Domaine**

- [ ] **F3-01** Entité `QuizSession` : identifiant UUID, mode, domaine, début, durée, nombre de questions et de réussites.
- [ ] **F3-02** `BuildQuiz` : construit la session à partir d'un mode et d'une liste d'items.
- [ ] **F3-03** `SubmitAnswer` : valide la réponse, mesure le temps, marque « Éclair » sous 3 secondes.
- [ ] **F3-04** Un fait raté revient 3 questions plus tard dans la session, une seule fois.
- [ ] **F3-05** `CompleteSession` écrit la session en une seule transaction ; `AbandonSession` garde les réponses données sans attribuer de récompense.

**Données**

- [ ] **F3-06** Migration : table `quiz_session`, conservée comme un journal jamais modifié ; repository associé.

**Présentation**

- [ ] **F3-07** `QuizBloc` : événements `QuizStarted`, `AnswerSubmitted`, `TimerTicked`, `TimeExpired`, `NextRequested`, `QuizPaused`, `QuizResumed`, `QuizAbandoned` ; états préparation, question en cours, retour sur réponse, terminé.
- [ ] **F3-08** Chrono dans le BLoC, alimenté par le `Ticker` : barre qui se vide, changement de couleur dans les 3 dernières secondes, temps écoulé compté comme une erreur.
- [ ] **F3-09** Trois modes de chrono lus dans les réglages du profil : normal, détendu (temps × 1,5), sans chrono.
- [ ] **F3-10** Pause du chrono quand l'app passe en arrière-plan.
- [ ] **F3-11** Écran Quiz : bouton quitter, barre de progression, compteur de combo, carte de la question.
- [ ] **F3-12** Zones de réponse : 4 boutons, pavé numérique intégré (0 à 9, Effacer, Valider), boutons Vrai et Faux, opération à trous.
- [ ] **F3-13** Retour en moins de 100 ms : couleur avec coche ou croix, opération complète après une erreur, bouton « Continuer ».
- [ ] **F3-14** Quitter le quiz avec une confirmation.
- [ ] **F3-15** Écran Résultats : bonnes réponses, temps moyen, faits à revoir, « Continuer » et « Rejouer ». L'écran reçoit seulement l'identifiant de la session et la charge avec son propre Cubit. Les étoiles arrivent avec F5, les XP et le niveau avec F7.

**Tests**

- [ ] **F3-16** Tests de `QuizBloc` avec un ticker factice : bonne réponse, erreur, temps écoulé, pause, reprise, abandon.
- [ ] **F3-17** Un test de widget de l'écran Quiz par format de question.
- [ ] **F3-18** Test du retour d'un fait raté 3 questions plus tard.

**Terminé quand :** depuis un bouton provisoire, un joueur répond à 10 questions de la table de 5 dans les 4 formats, avec chrono, et voit ses résultats.

## F4 · Maîtrise et répétition espacée

L'app suit chaque fait pour chaque joueur et fait revenir les faits fragiles au bon moment.

**Domaine**

- [ ] **F4-01** Entité `ItemProgress` : présentations, réussites, temps des 5 dernières réponses, boîte de 0 à 5, date de prochaine révision.
- [ ] **F4-02** `MasteryPolicy` : une bonne réponse monte d'une boîte, une erreur ou un temps écoulé ramène en boîte 1.
- [ ] **F4-03** Plafond à la boîte 3 pour une réponse en choix multiple ou en vrai ou faux ; seule une saisie fait monter plus haut.
- [ ] **F4-04** Délais de révision par boîte : le lendemain, 2, 4, 7 puis 15 jours.
- [ ] **F4-05** Statut « maîtrisé » : boîte 5 et temps médian des 5 dernières réponses sous 3 secondes.
- [ ] **F4-06** Cas d'usage `GetDueFacts` et `GetMasteryGrid`.
- [ ] **F4-07** Tirage pondéré : les boîtes basses sortent plus souvent ; hors de leur table, les faits en × 1 et × 10 sortent deux fois moins.
- [ ] **F4-08** Format selon le niveau : choix multiple d'abord pour les boîtes 1 et 2, saisie et opérations à trous à partir de la boîte 3.

**Données**

- [ ] **F4-09** Migration : table `item_progress`, une ligne par joueur, domaine et item, créée à la première présentation.
- [ ] **F4-10** Enregistrement à chaque réponse, pour qu'un abandon ou une fermeture de l'app ne perde rien.

**Présentation**

- [ ] **F4-11** Fiche d'aide après deux erreurs sur le même fait dans une session : la table et une grille de points.
- [ ] **F4-12** Rappel du fait inversé après une erreur (8 × 7 pour 7 × 8).

**Tests**

- [ ] **F4-13** Tests de `MasteryPolicy` : montées, retours en boîte 1, plafond, délais avec une horloge factice, médiane.
- [ ] **F4-14** Test du tirage pondéré avec une graine, et du choix du format selon la boîte.
- [ ] **F4-15** Test : fermer l'app en plein quiz conserve les réponses déjà données.

**Terminé quand :** rejouer une table fait évoluer les boîtes de ses faits, et les faits ratés reviennent en priorité à la session suivante.

## F5 · Parcours

La carte des 12 tables devient l'accueil : chaque table a 5 étapes, des étoiles et des règles de déblocage.

**Domaine**

- [ ] **F5-01** Entité `StageProgress` et description des 5 étapes d'une table : nombre de questions, formats autorisés, chrono (10 secondes par question à l'étape Vitesse).
- [ ] **F5-02** `StarPolicy` : 1 étoile dès 60 % de bonnes réponses, 2 dès 80 %, 3 pour un sans-faute ; le meilleur résultat est conservé.
- [ ] **F5-03** Déblocage : une étape s'ouvre quand la précédente a 1 étoile ; la table suivante s'ouvre dès l'étape 3 validée.
- [ ] **F5-04** Ordre des tables : 1, 2, 10, 5, 3, 4, 6, 9, 7, 8, 11, 12.
- [ ] **F5-05** Étape « Révision » de 15 questions après chaque groupe de 3 tables.
- [ ] **F5-06** `GetLearningPath` : tables, étapes, étoiles et verrous d'un joueur, réglage « Tout débloquer » pris en compte.

**Données**

- [ ] **F5-07** Migration : table `stage_progress` ; mise à jour dans la transaction de fin de session.

**Présentation**

- [ ] **F5-08** `LearningPathBloc`, rechargé après chaque session grâce au signal de changement.
- [ ] **F5-09** Écran Parcours : carte défilante, nœuds terminé, en cours et verrouillé, étoiles sous chaque table, carte d'appel « Jouer » sur la table en cours.
- [ ] **F5-10** Écran Détail d'une table : les 5 étapes, leurs étoiles, bouton « Voir la table ». Maquette : `04-table-detail.png`.
- [ ] **F5-11** Étape Découverte : la table affichée en entier, son astuce, puis ses 10 questions dans l'ordre.
- [ ] **F5-12** Étoiles sur l'écran Résultats ; « Continuer » ramène au parcours avec l'étape suivante mise en avant.
- [ ] **F5-13** Remplacement du bouton provisoire de F3 par le lancement depuis le parcours.

**Tests**

- [ ] **F5-14** Tests de `StarPolicy` et des règles de déblocage, « Tout débloquer » compris.
- [ ] **F5-15** Tests de `LearningPathBloc` et test de widget de la carte dans ses trois états de nœud.

**Terminé quand :** un nouveau joueur enchaîne les étapes 1 à 3 de la table de 1 et voit la table de 2 s'ouvrir.

## F6 · Combat de boss

La cinquième étape de chaque table est un duel contre le monstre de cette table ; le vaincre pose la couronne.

**Domaine**

- [ ] **F6-01** Règles du combat : le boss a 12 points de vie, une bonne réponse en retire 1, une réponse « Éclair » en retire 2.
- [ ] **F6-02** Une erreur ne coûte rien au joueur : la bonne réponse s'affiche et le fait revient plus tard dans le combat.
- [ ] **F6-03** Victoire quand la vie tombe à zéro ; après 20 questions sans y parvenir, le monstre s'enfuit et le combat peut être retenté.
- [ ] **F6-04** Questions : les 10 faits de la table, puis jusqu'à 10 faits des tables déjà vues parmi les plus fragiles ; 8 secondes par question.
- [ ] **F6-05** Étoiles calculées sur les questions jouées ; couronne à la victoire, dorée quand tous les faits de la table sont maîtrisés.
- [ ] **F6-06** Collection de monstres vaincus, déduite de `StageProgress` sans nouvelle table.

**Présentation**

- [ ] **F6-07** Mode boss du `QuizBloc` : vie du boss, coup, coup critique, riposte, fuite, victoire.
- [ ] **F6-08** Écran Combat de boss : fond sombre, monstre, barre de vie, question, pavé numérique.
- [ ] **F6-09** Animations courtes : coup, coup critique, riposte, fuite, victoire ; version fixe si les animations sont réduites.
- [ ] **F6-10** Les 12 monstres en ressources vectorielles, un par table.
- [ ] **F6-11** Couronnes affichées sur la carte du parcours.

**Tests**

- [ ] **F6-12** Tests des règles : victoire avec 60 % de bonnes réponses sans coup critique, fuite à la 20e question, coup critique, erreur sans coût.
- [ ] **F6-13** Tests du mode boss du `QuizBloc` et test de widget de l'écran.

**Terminé quand :** battre le boss de la table de 1 pose sa couronne sur la carte et ajoute le monstre à la collection.

## F7 · Récompenses

XP, niveaux, série quotidienne, objectif du jour, combo et badges récompensent chaque session terminée.

**Domaine**

- [ ] **F7-01** `XpPolicy`, avec un numéro de version : 10 XP par bonne réponse, + 5 pour une réponse « Éclair », + 20 par étape terminée, + 50 pour un sans-faute.
- [ ] **F7-02** Niveaux : le niveau N demande 100 × N XP de plus que le précédent.
- [ ] **F7-03** `StreakPolicy` : + 1 par jour avec une session terminée, selon l'horloge du téléphone ; une date qui recule ne change rien ; meilleure série conservée.
- [ ] **F7-04** Joker hebdomadaire qui sauve la série après un jour manqué.
- [ ] **F7-05** Objectif du jour : 20, 50 ou 100 XP au choix, avec la progression de la journée.
- [ ] **F7-06** Combo : compteur de bonnes réponses d'affilée, paliers à 3, 5 et 10.
- [ ] **F7-07** `BadgeEvaluator` et badges du lancement : Premier pas, Sans-faute, Éclair, Régulier, Dompteur de chaque table, Les 120. Sprinter arrive avec F9 et Survivant avec F12.
- [ ] **F7-08** Cas d'usage `GetStreak` et `GetBadges`.

**Données**

- [ ] **F7-09** Migration : tables `streak` et `badge_unlock` ; XP total et niveau sur le profil.
- [ ] **F7-10** Écriture de toutes les récompenses dans la transaction de fin de session.

**Présentation**

- [ ] **F7-11** Écran Résultats complet : XP gagnés, progression du niveau, badges obtenus.
- [ ] **F7-12** Célébrations de fin d'étape, de montée de niveau et de badge, que l'enfant passe d'un appui.
- [ ] **F7-13** Bandeau du Parcours : série, couronnes, jauge de l'objectif du jour.
- [ ] **F7-14** Compteur de combo et paliers fêtés pendant le quiz.
- [ ] **F7-15** Série affichée sur les cartes de « Qui joue ? ».

**Tests**

- [ ] **F7-16** Tests de `XpPolicy` et du calcul des niveaux.
- [ ] **F7-17** Tests de `StreakPolicy` avec une horloge factice : jour suivant, jour manqué avec et sans joker, date qui recule.
- [ ] **F7-18** Tests de `BadgeEvaluator`, un cas par badge.

**Terminé quand :** une étape terminée affiche les XP gagnés, fait avancer le niveau, l'objectif du jour et la série, et débloque le badge Premier pas.

## F8 · Mascotte qui grandit

La mascotte donne un but visible aux XP : elle grandit avec le niveau du joueur et porte les accessoires qu'il débloque.

**Domaine**

- [ ] **F8-01** Règles des 5 stades, atteints aux niveaux 1, 5, 10, 20 et 30 ; la mascotte ne régresse jamais.
- [ ] **F8-02** Catalogue d'accessoires et règles de déblocage par couronne et par badge.
- [ ] **F8-03** Cas d'usage `GetMascot` : stade, accessoires débloqués, accessoires portés, nom.

**Données**

- [ ] **F8-04** Migration : nom de la mascotte et accessoires portés sur le profil.

**Présentation**

- [ ] **F8-05** Widget Mascotte : 5 stades, accessoires, trois humeurs (neutre, joie, encouragement).
- [ ] **F8-06** Présence sur l'accueil, pendant le quiz et sur l'écran Résultats.
- [ ] **F8-07** Messages : encouragement après une erreur, félicitations aux paliers, rappel de l'objectif du jour.
- [ ] **F8-08** Carte Mascotte du Profil : stade en cours, prochain stade, choix des accessoires, changement du nom.
- [ ] **F8-09** Célébration au changement de stade.
- [ ] **F8-10** Dessins des 5 stades et des accessoires ; choix de l'outil d'animation (Rive, Lottie ou dessin vectoriel animé à la main) à trancher au début du lot.

**Tests**

- [ ] **F8-11** Tests des règles de stade et de déblocage des accessoires.
- [ ] **F8-12** Test de widget de la mascotte dans chaque stade.

**Terminé quand :** un joueur qui atteint le niveau 5 voit sa mascotte changer de stade, et peut lui mettre un accessoire gagné avec une couronne.

## F9 · Entraînement libre et Contre-la-montre

Deux modes hors parcours : l'enfant choisit ses tables pour s'entraîner, ou tente le plus de bonnes réponses en 60 secondes.

**Domaine**

- [ ] **F9-01** Entraînement libre : une ou plusieurs tables, 10, 20 ou 30 questions, avec ou sans chrono ; questions tirées avec le tirage pondéré de F4.
- [ ] **F9-02** Contre-la-montre : 60 secondes au total, score égal au nombre de bonnes réponses ; la question en cours est remplacée au retour d'arrière-plan.
- [ ] **F9-03** Entité `Record` et cas d'usage `GetRecords` : meilleur score par joueur et par mode.
- [ ] **F9-04** Badge Sprinter : 20 bonnes réponses en Contre-la-montre.

**Données**

- [ ] **F9-05** Migration : table `record`, mise à jour dans la transaction de fin de session.

**Présentation**

- [ ] **F9-06** Écran S'entraîner : choix des tables, du nombre de questions et du chrono, bouton « Lancer ». Maquette : `10-training.png`.
- [ ] **F9-07** Écran Défis : carte Contre-la-montre et records personnels ; les autres défis s'y ajoutent en version 1.1. Maquette : `11-challenges.png`.
- [ ] **F9-08** Chrono global de 60 secondes dans le `QuizBloc` et affichage du score en direct.
- [ ] **F9-09** « Nouveau record » sur l'écran Résultats.

**Tests**

- [ ] **F9-10** Tests du Contre-la-montre avec un ticker factice : fin à 60 secondes, pause, question remplacée.
- [ ] **F9-11** Tests des records et du badge Sprinter.

**Terminé quand :** un joueur lance un entraînement sur les tables de 2 et de 5, puis bat son propre record en Contre-la-montre.

## F10 · Profil et réglages

L'onglet Profil montre la progression du joueur ; les réglages règlent les sons, le chrono et l'objectif du jour.

**Domaine**

- [ ] **F10-01** Cas d'usage `GetProfileStats` : série, couronnes, badges, niveau.
- [ ] **F10-02** Cas d'usage `GetSettings`, `UpdateSettings` et `ResetProgress`.

**Présentation**

- [ ] **F10-03** `ProgressCubit` et `SettingsCubit`.
- [ ] **F10-04** Écran Profil : avatar, niveau, tuiles série, couronnes et badges, carte Mascotte.
- [ ] **F10-05** Grille de maîtrise 12 × 10 colorée par statut, avec sa légende ; chaque statut a aussi un libellé pour les lecteurs d'écran.
- [ ] **F10-06** Liste des badges obtenus et à obtenir, collection de monstres vaincus.
- [ ] **F10-07** Bouton « Changer de joueur », retour à « Qui joue ? ».
- [ ] **F10-08** Écran Réglages : sons, vibrations, mode de chrono, objectif du jour, « Tout débloquer », animations réduites. Maquette : `13-settings.png`.
- [ ] **F10-09** Ajout du paquet audioplayers ; sons et vibrations : bonne réponse, erreur, célébrations ; coupure séparée des deux.
- [ ] **F10-10** Réinitialiser la progression après une confirmation où l'enfant retape son pseudo.

**Tests**

- [ ] **F10-11** Tests des deux Cubit et de `ResetProgress`.
- [ ] **F10-12** Test de widget de la grille de maîtrise.

**Terminé quand :** le Profil reflète une session qui vient d'être jouée, et couper les sons ou passer en « sans chrono » s'applique au quiz suivant.

## F11 · Finition et publication de la version 1.0

Ce lot vérifie l'ensemble et prépare la mise en ligne sur les stores.

**Qualité**

- [ ] **F11-01** Accessibilité : zones tactiles de 48 dp au minimum et 56 dp pour les réponses, contraste AA, police du système jusqu'à 130 % sans texte coupé, libellés pour lecteurs d'écran.
- [ ] **F11-02** Performances sur un téléphone d'entrée de gamme : démarrage en moins de 2 secondes, 60 images par seconde pendant le quiz.
- [ ] **F11-03** Test d'intégration du trajet complet : créer un profil, jouer une étape, voir les résultats, retrouver la progression après redémarrage.
- [ ] **F11-04** Cas limites : deux pseudos identiques à la casse près, changement de date du téléphone, suppression du joueur actif, fermeture en plein quiz.
- [ ] **F11-05** Couverture de tests : 90 % sur le domaine et 80 % au moins sur les données.
- [ ] **F11-06** Mise en page utilisable sur tablette.

**Publication**

- [ ] **F11-07** Nom définitif de l'app, icône et écran de lancement.
- [ ] **F11-08** Aucun appel réseau ni SDK tiers qui communique dans la version 1.0 ; paquet de moins de 40 Mo.
- [ ] **F11-09** Politique de confidentialité et déclarations « public enfants » de Google Play et de l'App Store.
- [ ] **F11-10** Fiches des stores : textes et captures d'écran.
- [ ] **F11-11** Builds signés et obfusqués Android et iOS, envoyés en test interne.

**Terminé quand :** les deux builds sont installés depuis les canaux de test des stores et le trajet complet passe sur un vrai téléphone.

## F12 · Révision du jour et Survie

Deux défis s'ajoutent à l'onglet Défis : une révision choisie par le moteur et un mode à 3 vies.

- [ ] **F12-01** Révision du jour : 10 questions sans chrono, d'abord les faits dont la date de révision est passée, puis ceux au plus faible taux de réussite.
- [ ] **F12-02** Survie : 3 vies, une erreur en retire une ; le temps par question part de 10 secondes et raccourcit au fil de la partie.
- [ ] **F12-03** Record de Survie et badge Survivant (30 bonnes réponses).
- [ ] **F12-04** Mode Survie du `QuizBloc` : vies, temps décroissant, question remplacée au retour d'arrière-plan.
- [ ] **F12-05** Cartes Révision du jour et Survie dans l'écran Défis ; affichage des vies pendant le quiz.
- [ ] **F12-06** Tests : sélection des faits à revoir avec une horloge factice, fin de partie à la troisième erreur, record.

**Terminé quand :** la Révision du jour propose les faits ratés la veille, et une partie de Survie s'arrête à la troisième erreur.

## F13 · Mes monstres

Les faits les plus difficiles du joueur deviennent des petits monstres à apprivoiser.

- [ ] **F13-01** Règle : un fait raté au moins 2 fois et encore en boîte 1 à 3 devient un monstre ; 5 au plus sont montrés, les plus coriaces.
- [ ] **F13-02** Cas d'usage `GetMonsters`, calculé à partir de la maîtrise des items, sans nouvelle table.
- [ ] **F13-03** Chasse aux monstres : quiz de 10 questions centré sur ces faits.
- [ ] **F13-04** Un monstre est apprivoisé quand son fait atteint le statut « Acquis » ; il rejoint la collection.
- [ ] **F13-05** Carte Chasse aux monstres dans Défis ; monstres apprivoisés dans la collection du Profil.
- [ ] **F13-06** Dessins des petits monstres.
- [ ] **F13-07** Tests : apparition, limite de 5, apprivoisement.

**Terminé quand :** un fait raté deux fois apparaît comme monstre, puis rejoint la collection une fois acquis.

## F14 · Duel sur le même téléphone

Deux joueurs s'affrontent face à face sur un écran coupé en deux.

- [ ] **F14-01** Règles : le premier à 10 bonnes réponses gagne ; une erreur bloque les boutons du joueur pendant 2 secondes.
- [ ] **F14-02** Chaque joueur reçoit des questions de ses propres tables débloquées ; les tables proposées à un invité sans profil restent à trancher.
- [ ] **F14-03** Le duel rapporte des XP aux profils qui jouent et ne modifie pas la maîtrise des faits.
- [ ] **F14-04** `DuelBloc` : choix des joueurs, duel en cours, terminé avec vainqueur.
- [ ] **F14-05** Écran Duel : deux moitiés tête-bêche, une question et 4 boutons par joueur, les deux scores. Maquette : `15-duel.png`.
- [ ] **F14-06** Choix des deux joueurs, ou d'un invité, avant le duel.
- [ ] **F14-07** Tests de `DuelBloc` : appuis simultanés, blocage de 2 secondes, victoire.

**Terminé quand :** deux profils de niveaux différents jouent un duel complet et reçoivent chacun leurs XP.

## F15 · Nouveaux formats de questions

Deux formats s'ajoutent sans toucher au moteur : ils s'enregistrent dans le registre des types.

- [ ] **F15-01** Type « Trouver l'opération » : un résultat, 4 opérations au choix, une seule juste.
- [ ] **F15-02** Type « Relier les paires » : 4 opérations et 4 résultats à associer.
- [ ] **F15-03** Les deux types comptent comme réponse reconnue pour la maîtrise (plafond à la boîte 3).
- [ ] **F15-04** Widgets de réponse des deux types. Maquettes : `16-quiz-find-operation.png` et `17-quiz-match-pairs.png`.
- [ ] **F15-05** Ajout des deux types aux étapes Vitesse et Boss, et à l'Entraînement libre.
- [ ] **F15-06** Tests : génération sans ambiguïté (une seule opération juste, 4 résultats distincts), validation, tests de widget.

**Terminé quand :** les deux formats apparaissent dans un quiz de l'étape Vitesse, sans changement dans le code du `QuizBloc`.

## F16 · Test de départ

À la création du profil, un test rapide ouvre d'emblée les tables que l'enfant connaît déjà.

- [ ] **F16-01** Cas d'usage `RunPlacementTest` : 12 questions, une par table.
- [ ] **F16-02** Une table réussie est ouverte dans le parcours ; ses étoiles restent à gagner.
- [ ] **F16-03** Proposition du test en fin de création de profil, avec un bouton « Passer ».
- [ ] **F16-04** Écran de bilan du test : tables ouvertes. Maquette : `18-placement-test-result.png`.
- [ ] **F16-05** Tests : ouverture des bonnes tables, test passé, test abandonné en cours.

**Terminé quand :** un nouveau joueur qui réussit les questions des tables de 1, 2 et 10 démarre avec ces trois tables ouvertes.

## F17 · Classement local

Les joueurs du téléphone sont classés par XP gagnés dans la semaine.

- [ ] **F17-01** Contrat `LeaderboardRepository` avec une portée (téléphone, amis, monde) ; seule la portée téléphone est implémentée.
- [ ] **F17-02** Cas d'usage `GetLeaderboard` : XP de la semaine calculés à partir du journal des sessions, remise à zéro chaque lundi.
- [ ] **F17-03** `LeaderboardCubit` et écran Classement : avatar, pseudo, XP de la semaine. Maquette : `19-leaderboard.png`.
- [ ] **F17-04** Réglage pour masquer le classement.
- [ ] **F17-05** Tests : calcul hebdomadaire avec une horloge factice, passage du dimanche au lundi, égalités.

**Terminé quand :** deux joueurs qui ont joué dans la semaine apparaissent classés, et le classement repart de zéro le lundi.

## F18 · Rappel quotidien

Une notification locale rappelle à l'enfant de jouer, à l'heure choisie.

- [ ] **F18-01** Ajout de flutter_local_notifications et configuration Android et iOS.
- [ ] **F18-02** Demande d'autorisation au moment où le rappel est activé, jamais au premier lancement.
- [ ] **F18-03** Réglage : rappel activé ou non (désactivé par défaut) et heure du rappel.
- [ ] **F18-04** Programmation et annulation de la notification ; pas de rappel le jour où une session est déjà terminée.
- [ ] **F18-05** Tests : programmation, annulation, changement d'heure, avec un service de notification factice.

**Terminé quand :** un rappel réglé sur une heure proche s'affiche sur un vrai téléphone Android et sur un iPhone.

## F19 · Défi par code

Un joueur partage un code ; un ami rejoue exactement les mêmes questions sur un autre téléphone, sans réseau.

- [ ] **F19-01** Format du code, une dizaine de caractères : tables choisies, mode, graine du tirage, score à battre, version du générateur, caractère de contrôle.
- [ ] **F19-02** Cas d'usage `EncodeChallengeCode` et `BuildQuizFromCode`.
- [ ] **F19-03** Générateur de questions figé par version : une même graine donne les mêmes questions sur tout téléphone.
- [ ] **F19-04** Bouton « Défier un ami » en fin d'Entraînement libre et de Contre-la-montre ; affichage et copie du code.
- [ ] **F19-05** Saisie d'un code dans l'écran Défis, avec un message clair si le code est invalide ou d'une version inconnue.
- [ ] **F19-06** Écran de comparaison des deux scores. Maquette : `21-challenge-score.png`.
- [ ] **F19-07** Tests : encodage puis décodage, code altéré refusé, mêmes questions pour un même code.

**Terminé quand :** un code créé sur un téléphone donne les mêmes questions sur un second, qui affiche les deux scores.

## F20 · Sauvegarde par fichier

La progression survit à un changement de téléphone grâce à un fichier exporté puis importé.

- [ ] **F20-01** Format de fichier versionné contenant un profil et toutes ses données.
- [ ] **F20-02** Export d'un profil vers un fichier, partagé par la feuille de partage du système.
- [ ] **F20-03** Import : contrôle du format, puis choix entre remplacer le profil existant ou renommer en cas de pseudo déjà pris.
- [ ] **F20-04** Entrées « Exporter » et « Importer » dans les réglages. Maquette : `13-settings.png` (section Sauvegarde).
- [ ] **F20-05** Tests : aller-retour export puis import sans perte, fichier corrompu refusé, conflit de pseudo.

**Terminé quand :** un profil exporté puis importé sur un second téléphone retrouve son niveau, sa série, ses étoiles et sa grille de maîtrise.

## F21 · Autres langues et boutique

L'app s'ouvre à d'autres langues, et des pièces gagnées en jouant servent à débloquer des avatars et des thèmes.

- [ ] **F21-01** Fichiers de traduction supplémentaires ; la liste des langues reste à définir.
- [ ] **F21-02** Choix de la langue dans les réglages, langue du téléphone par défaut.
- [ ] **F21-03** Pièces gagnées en jouant : règles de gain à définir, solde par profil, migration.
- [ ] **F21-04** Catalogue d'avatars et de thèmes à débloquer avec des pièces ; aucun achat en argent réel.
- [ ] **F21-05** Écran Boutique : catalogue, solde, achat, élément actif. Maquette : `22-shop.png`.
- [ ] **F21-06** Tests : gain de pièces, achat, solde insuffisant, changement de langue.

**Terminé quand :** l'app s'affiche dans une seconde langue, et un joueur achète un avatar avec ses pièces.

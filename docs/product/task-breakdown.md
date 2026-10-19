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

L'application est découpée en lots, de F0 à F32, à intégrer dans cet ordre ; chaque lot livre une fonctionnalité utilisable et testée. Le détail fonctionnel est dans les [spécifications](specifications.md), les écrans dans le [design](../design/README.md), les décisions dans [decisions.md](../decisions.md) et l'avancement dans [status.md](../status.md).

## Vue d'ensemble

Les lots F0 à F11 forment la version 1.0, F12 à F18 la version 1.1, F19 à F21 la version 1.2, et F23 à F32 la version 2.0 « Kid Matix pour tous ». F22 est un lot hors plan. Un lot ne démarre que lorsque ceux dont il dépend sont terminés.

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
| F22 | Services de jeux Google Play | Hors plan | F11 | Aucun |
| F23 | Lecture à voix haute | 2.0 | F3, F10 | Aucun (bouton sur la carte de question) |
| F24 | Domaine « Nombres jusqu'à 100 » | 2.0 | F5, F15, F23 | À dessiner |
| F25 | Domaine « Additions et soustractions » | 2.0 | F24 | À dessiner |
| F26 | Domaine « Division » | 2.0 | F24 | À dessiner |
| F27 | Test de positionnement par compétence | 2.0 | F16, F24, F25, F26 | 18 (à adapter) |
| F28 | Les mots des maths | 2.0 | F23, F24 | À dessiner |
| F29 | Mode classe hors ligne | 2.0 | F20, F27 | À dessiner |
| F30 | Résoudre des problèmes | 2.0 | F25, F26, F28 | À dessiner |
| F31 | Mesure des progrès et outils de l'enseignant | 2.0 | F27, F28, F29 | À dessiner |
| F32 | Autres langues d'aide et suite | 2.0 | F28, F29 | Aucun |

Les numéros de la dernière colonne sont les préfixes des captures de `docs/design/screens/` (par exemple `01-who-is-playing.png`) ; l'index complet est dans `docs/design/README.md`.

Les nouveaux domaines et l'ouverture aux ONG et aux écoles sont découpés dans la version 2.0 (F23 à F32), à la fin de ce fichier. Le mode en ligne n'est plus une priorité : seule une synchronisation facultative des résultats de classe est envisagée (F32-03).

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

- [x] **F2-05** `MultiplicationDomain` : 12 unités (tables de 1 à 12), 120 items de clé `mul:7x8`, ordre du parcours, une astuce par table.
- [x] **F2-06** Types de questions de la version 1.0 : choix multiple, saisie, opération à trous, vrai ou faux.
- [x] **F2-07** `DistractorGenerator` : résultat voisin dans la même table, résultat de la table voisine, confusion avec l'addition, chiffres inversés ; jamais de doublon ni de nombre négatif ; position de la bonne réponse aléatoire.
- [x] **F2-08** Vrai ou faux : affirmation vraie une fois sur deux, erreur plausible sinon.
- [x] **F2-09** `QuestionGenerator` : construit les questions d'une liste d'items avec les types autorisés ; jamais le même fait deux fois de suite ; tirage reproductible avec une graine.

**Tests**

- [x] **F2-10** Les 120 clés sont uniques et stables.
- [x] **F2-11** Mauvaises réponses : 3 choix distincts, différents de la bonne réponse, pour les 120 faits.
- [x] **F2-12** Même graine, mêmes questions ; validation de chaque type de question.

**Terminé quand :** tous les tests passent et le lot n'importe aucun paquet Flutter.

## F3 · Session de quiz et résultats

Ce lot livre la boucle de jeu : une série de questions avec chrono, un retour immédiat après chaque réponse, puis l'écran de résultats.

**Domaine**

- [x] **F3-01** Entité `QuizSession` : identifiant UUID, mode, domaine, début, durée, nombre de questions et de réussites.
- [x] **F3-02** `BuildQuiz` : construit la session à partir d'un mode et d'une liste d'items.
- [x] **F3-03** `SubmitAnswer` : valide la réponse, mesure le temps, marque « Éclair » sous 3 secondes.
- [x] **F3-04** Un fait raté revient 3 questions plus tard dans la session, une seule fois.
- [x] **F3-05** `CompleteSession` écrit la session en une seule transaction ; `AbandonSession` garde les réponses données sans attribuer de récompense.

**Données**

- [x] **F3-06** Migration : table `quiz_session`, conservée comme un journal jamais modifié ; repository associé.

**Présentation**

- [x] **F3-07** `QuizBloc` : événements `QuizStarted`, `AnswerSubmitted`, `TimerTicked`, `TimeExpired`, `NextRequested`, `QuizPaused`, `QuizResumed`, `QuizAbandoned` ; états préparation, question en cours, retour sur réponse, terminé.
- [x] **F3-08** Chrono dans le BLoC, alimenté par le `Ticker` : barre qui se vide, changement de couleur dans les 3 dernières secondes, temps écoulé compté comme une erreur.
- [x] **F3-09** Trois modes de chrono lus dans les réglages du profil : normal, détendu (temps × 1,5), sans chrono.
- [x] **F3-10** Pause du chrono quand l'app passe en arrière-plan.
- [x] **F3-11** Écran Quiz : bouton quitter, barre de progression, compteur de combo, carte de la question.
- [x] **F3-12** Zones de réponse : 4 boutons, pavé numérique intégré (0 à 9, Effacer, Valider), boutons Vrai et Faux, opération à trous.
- [x] **F3-13** Retour en moins de 100 ms : couleur avec coche ou croix, opération complète après une erreur, bouton « Continuer ».
- [x] **F3-14** Quitter le quiz avec une confirmation.
- [x] **F3-15** Écran Résultats : bonnes réponses, temps moyen, faits à revoir, « Continuer » et « Rejouer ». L'écran reçoit seulement l'identifiant de la session et la charge avec son propre Cubit. Les étoiles arrivent avec F5, les XP et le niveau avec F7.

**Tests**

- [x] **F3-16** Tests de `QuizBloc` avec un ticker factice : bonne réponse, erreur, temps écoulé, pause, reprise, abandon.
- [x] **F3-17** Un test de widget de l'écran Quiz par format de question.
- [x] **F3-18** Test du retour d'un fait raté 3 questions plus tard.

**Terminé quand :** depuis un bouton provisoire, un joueur répond à 10 questions de la table de 5 dans les 4 formats, avec chrono, et voit ses résultats.

## F4 · Maîtrise et répétition espacée

L'app suit chaque fait pour chaque joueur et fait revenir les faits fragiles au bon moment.

**Domaine**

- [x] **F4-01** Entité `ItemProgress` : présentations, réussites, temps des 5 dernières réponses, boîte de 0 à 5, date de prochaine révision.
- [x] **F4-02** `MasteryPolicy` : une bonne réponse monte d'une boîte, une erreur ou un temps écoulé ramène en boîte 1.
- [x] **F4-03** Plafond à la boîte 3 pour une réponse en choix multiple ou en vrai ou faux ; seule une saisie fait monter plus haut.
- [x] **F4-04** Délais de révision par boîte : le lendemain, 2, 4, 7 puis 15 jours.
- [x] **F4-05** Statut « maîtrisé » : boîte 5 et temps médian des 5 dernières réponses sous 3 secondes.
- [x] **F4-06** Cas d'usage `GetDueFacts` et `GetMasteryGrid`.
- [x] **F4-07** Tirage pondéré : les boîtes basses sortent plus souvent ; hors de leur table, les faits en × 1 et × 10 sortent deux fois moins.
- [x] **F4-08** Format selon le niveau : choix multiple d'abord pour les boîtes 1 et 2, saisie et opérations à trous à partir de la boîte 3.

**Données**

- [x] **F4-09** Migration : table `item_progress`, une ligne par joueur, domaine et item, créée à la première présentation.
- [x] **F4-10** Enregistrement à chaque réponse, pour qu'un abandon ou une fermeture de l'app ne perde rien.

**Présentation**

- [x] **F4-11** Fiche d'aide après deux erreurs sur le même fait dans une session : la table et une grille de points.
- [x] **F4-12** Rappel du fait inversé après une erreur (8 × 7 pour 7 × 8).

**Tests**

- [x] **F4-13** Tests de `MasteryPolicy` : montées, retours en boîte 1, plafond, délais avec une horloge factice, médiane.
- [x] **F4-14** Test du tirage pondéré avec une graine, et du choix du format selon la boîte.
- [x] **F4-15** Test : fermer l'app en plein quiz conserve les réponses déjà données.

**Terminé quand :** rejouer une table fait évoluer les boîtes de ses faits, et les faits ratés reviennent en priorité à la session suivante.

## F5 · Parcours

La carte des 12 tables devient l'accueil : chaque table a 5 étapes, des étoiles et des règles de déblocage.

**Domaine**

- [x] **F5-01** Entité `StageProgress` et description des 5 étapes d'une table : nombre de questions, formats autorisés, chrono (10 secondes par question à l'étape Vitesse).
- [x] **F5-02** `StarPolicy` : 1 étoile dès 60 % de bonnes réponses, 2 dès 80 %, 3 pour un sans-faute ; le meilleur résultat est conservé.
- [x] **F5-03** Déblocage : une étape s'ouvre quand la précédente a 1 étoile ; la table suivante s'ouvre dès l'étape 3 validée.
- [x] **F5-04** Ordre des tables : 1, 2, 10, 5, 3, 4, 6, 9, 7, 8, 11, 12.
- [x] **F5-05** Étape « Révision » de 15 questions après chaque groupe de 3 tables.
- [x] **F5-06** `GetLearningPath` : tables, étapes, étoiles et verrous d'un joueur, réglage « Tout débloquer » pris en compte.

**Données**

- [x] **F5-07** Migration : table `stage_progress` ; mise à jour dans la transaction de fin de session.

**Présentation**

- [x] **F5-08** `LearningPathBloc`, rechargé après chaque session grâce au signal de changement.
- [x] **F5-09** Écran Parcours : carte défilante, nœuds terminé, en cours et verrouillé, étoiles sous chaque table, carte d'appel « Jouer » sur la table en cours.
- [x] **F5-10** Écran Détail d'une table : les 5 étapes, leurs étoiles, bouton « Voir la table ». Maquette : `04-table-detail.png`.
- [x] **F5-11** Étape Découverte : la table affichée en entier, son astuce, puis ses 10 questions dans l'ordre.
- [x] **F5-12** Étoiles sur l'écran Résultats ; « Continuer » ramène au parcours avec l'étape suivante mise en avant.
- [x] **F5-13** Remplacement du bouton provisoire de F3 par le lancement depuis le parcours.

**Tests**

- [x] **F5-14** Tests de `StarPolicy` et des règles de déblocage, « Tout débloquer » compris.
- [x] **F5-15** Tests de `LearningPathBloc` et test de widget de la carte dans ses trois états de nœud.

**Terminé quand :** un nouveau joueur enchaîne les étapes 1 à 3 de la table de 1 et voit la table de 2 s'ouvrir.

## F6 · Combat de boss

La cinquième étape de chaque table est un duel contre le monstre de cette table ; le vaincre pose la couronne.

**Domaine**

- [x] **F6-01** Règles du combat : le boss a 12 points de vie, une bonne réponse en retire 1, une réponse « Éclair » en retire 2.
- [x] **F6-02** Une erreur ne coûte rien au joueur : la bonne réponse s'affiche et le fait revient plus tard dans le combat.
- [x] **F6-03** Victoire quand la vie tombe à zéro ; après 20 questions sans y parvenir, le monstre s'enfuit et le combat peut être retenté.
- [x] **F6-04** Questions : les 10 faits de la table, puis jusqu'à 10 faits des tables déjà vues parmi les plus fragiles ; 8 secondes par question.
- [x] **F6-05** Étoiles calculées sur les questions jouées ; couronne à la victoire, dorée quand tous les faits de la table sont maîtrisés.
- [x] **F6-06** Collection de monstres vaincus, déduite de `StageProgress` sans nouvelle table.

**Présentation**

- [x] **F6-07** Mode boss du `QuizBloc` : vie du boss, coup, coup critique, riposte, fuite, victoire.
- [x] **F6-08** Écran Combat de boss : fond sombre, monstre, barre de vie, question, pavé numérique.
- [x] **F6-09** Animations courtes : coup, coup critique, riposte, fuite, victoire ; version fixe si les animations sont réduites.
- [x] **F6-10** Les 12 monstres en ressources vectorielles, un par table.
- [x] **F6-11** Couronnes affichées sur la carte du parcours.

**Tests**

- [x] **F6-12** Tests des règles : victoire avec 60 % de bonnes réponses sans coup critique, fuite à la 20e question, coup critique, erreur sans coût.
- [x] **F6-13** Tests du mode boss du `QuizBloc` et test de widget de l'écran.

**Terminé quand :** battre le boss de la table de 1 pose sa couronne sur la carte et ajoute le monstre à la collection.

## F7 · Récompenses

XP, niveaux, série quotidienne, objectif du jour, combo et badges récompensent chaque session terminée.

**Domaine**

- [x] **F7-01** `XpPolicy`, avec un numéro de version : 10 XP par bonne réponse, + 5 pour une réponse « Éclair », + 20 par étape terminée, + 50 pour un sans-faute.
- [x] **F7-02** Niveaux : le niveau N demande 100 × N XP de plus que le précédent.
- [x] **F7-03** `StreakPolicy` : + 1 par jour avec une session terminée, selon l'horloge du téléphone ; une date qui recule ne change rien ; meilleure série conservée.
- [x] **F7-04** Joker hebdomadaire qui sauve la série après un jour manqué.
- [x] **F7-05** Objectif du jour : 20, 50 ou 100 XP au choix, avec la progression de la journée.
- [x] **F7-06** Combo : compteur de bonnes réponses d'affilée, paliers à 3, 5 et 10.
- [x] **F7-07** `BadgeEvaluator` et badges du lancement : Premier pas, Sans-faute, Éclair, Régulier, Dompteur de chaque table, Les 120. Sprinter arrive avec F9 et Survivant avec F12.
- [x] **F7-08** Cas d'usage `GetStreak` et `GetBadges`.

**Données**

- [x] **F7-09** Migration : tables `streak` et `badge_unlock` ; XP total et niveau sur le profil.
- [x] **F7-10** Écriture de toutes les récompenses dans la transaction de fin de session.

**Présentation**

- [x] **F7-11** Écran Résultats complet : XP gagnés, progression du niveau, badges obtenus.
- [x] **F7-12** Célébrations de fin d'étape, de montée de niveau et de badge, que l'enfant passe d'un appui.
- [x] **F7-13** Bandeau du Parcours : série, couronnes, jauge de l'objectif du jour.
- [x] **F7-14** Compteur de combo et paliers fêtés pendant le quiz.
- [x] **F7-15** Série affichée sur les cartes de « Qui joue ? ».

**Tests**

- [x] **F7-16** Tests de `XpPolicy` et du calcul des niveaux.
- [x] **F7-17** Tests de `StreakPolicy` avec une horloge factice : jour suivant, jour manqué avec et sans joker, date qui recule.
- [x] **F7-18** Tests de `BadgeEvaluator`, un cas par badge.

**Terminé quand :** une étape terminée affiche les XP gagnés, fait avancer le niveau, l'objectif du jour et la série, et débloque le badge Premier pas.

## F8 · Mascotte qui grandit

La mascotte donne un but visible aux XP : elle grandit avec le niveau du joueur et porte les accessoires qu'il débloque.

**Domaine**

- [x] **F8-01** Règles des 5 stades, atteints aux niveaux 1, 5, 10, 20 et 30 ; la mascotte ne régresse jamais.
- [x] **F8-02** Catalogue d'accessoires et règles de déblocage par couronne et par badge.
- [x] **F8-03** Cas d'usage `GetMascot` : stade, accessoires débloqués, accessoires portés, nom.

**Données**

- [x] **F8-04** Migration : nom de la mascotte et accessoires portés sur le profil.

**Présentation**

- [x] **F8-05** Widget Mascotte : 5 stades, accessoires, trois humeurs (neutre, joie, encouragement).
- [x] **F8-06** Présence sur l'accueil, pendant le quiz et sur l'écran Résultats.
- [x] **F8-07** Messages : encouragement après une erreur, félicitations aux paliers, rappel de l'objectif du jour.
- [x] **F8-08** Carte Mascotte du Profil : stade en cours, prochain stade, choix des accessoires, changement du nom.
- [x] **F8-09** Célébration au changement de stade.
- [x] **F8-10** Dessins des 5 stades et des accessoires ; choix de l'outil d'animation (Rive, Lottie ou dessin vectoriel animé à la main) à trancher au début du lot.

**Tests**

- [x] **F8-11** Tests des règles de stade et de déblocage des accessoires.
- [x] **F8-12** Test de widget de la mascotte dans chaque stade.

**Terminé quand :** un joueur qui atteint le niveau 5 voit sa mascotte changer de stade, et peut lui mettre un accessoire gagné avec une couronne.

## F9 · Entraînement libre et Contre-la-montre

Deux modes hors parcours : l'enfant choisit ses tables pour s'entraîner, ou tente le plus de bonnes réponses en 60 secondes.

**Domaine**

- [x] **F9-01** Entraînement libre : une ou plusieurs tables, 10, 20 ou 30 questions, avec ou sans chrono ; questions tirées avec le tirage pondéré de F4.
- [x] **F9-02** Contre-la-montre : 60 secondes au total, score égal au nombre de bonnes réponses ; la question en cours est remplacée au retour d'arrière-plan.
- [x] **F9-03** Entité `Record` et cas d'usage `GetRecords` : meilleur score par joueur et par mode.
- [x] **F9-04** Badge Sprinter : 20 bonnes réponses en Contre-la-montre.

**Données**

- [x] **F9-05** Migration : table `record`, mise à jour dans la transaction de fin de session.

**Présentation**

- [x] **F9-06** Écran S'entraîner : choix des tables, du nombre de questions et du chrono, bouton « Lancer ». Maquette : `10-training.png`.
- [x] **F9-07** Écran Défis : carte Contre-la-montre et records personnels ; les autres défis s'y ajoutent en version 1.1. Maquette : `11-challenges.png`.
- [x] **F9-08** Chrono global de 60 secondes dans le `QuizBloc` et affichage du score en direct.
- [x] **F9-09** « Nouveau record » sur l'écran Résultats.

**Tests**

- [x] **F9-10** Tests du Contre-la-montre avec un ticker factice : fin à 60 secondes, pause, question remplacée.
- [x] **F9-11** Tests des records et du badge Sprinter.

**Terminé quand :** un joueur lance un entraînement sur les tables de 2 et de 5, puis bat son propre record en Contre-la-montre.

## F10 · Profil et réglages

L'onglet Profil montre la progression du joueur ; les réglages règlent les sons, le chrono et l'objectif du jour.

**Domaine**

- [x] **F10-01** Cas d'usage `GetProfileStats` : série, couronnes, badges, niveau.
- [x] **F10-02** Cas d'usage `GetSettings`, `UpdateSettings` et `ResetProgress`.

**Présentation**

- [x] **F10-03** `ProgressCubit` et `SettingsCubit`.
- [x] **F10-04** Écran Profil : avatar, niveau, tuiles série, couronnes et badges, carte Mascotte.
- [x] **F10-05** Grille de maîtrise 12 × 10 colorée par statut, avec sa légende ; chaque statut a aussi un libellé pour les lecteurs d'écran.
- [x] **F10-06** Liste des badges obtenus et à obtenir, collection de monstres vaincus.
- [x] **F10-07** Bouton « Changer de joueur », retour à « Qui joue ? ».
- [x] **F10-08** Écran Réglages : sons, vibrations, mode de chrono, objectif du jour, « Tout débloquer », animations réduites. Maquette : `13-settings.png`.
- [x] **F10-09** Ajout du paquet audioplayers ; sons et vibrations : bonne réponse, erreur, célébrations ; coupure séparée des deux.
- [x] **F10-10** Réinitialiser la progression après une confirmation où l'enfant retape son pseudo.

**Tests**

- [x] **F10-11** Tests des deux Cubit et de `ResetProgress`.
- [x] **F10-12** Test de widget de la grille de maîtrise.

**Terminé quand :** le Profil reflète une session qui vient d'être jouée, et couper les sons ou passer en « sans chrono » s'applique au quiz suivant.

## F11 · Finition et publication de la version 1.0

Ce lot vérifie l'ensemble et prépare la mise en ligne sur les stores.

**Qualité**

- [x] **F11-01** Accessibilité : zones tactiles de 48 dp au minimum et 56 dp pour les réponses, contraste AA, police du système jusqu'à 130 % sans texte coupé, libellés pour lecteurs d'écran.
- [x] **F11-02** Performances sur un téléphone d'entrée de gamme : démarrage en moins de 2 secondes, 60 images par seconde pendant le quiz.
- [x] **F11-03** Test d'intégration du trajet complet : créer un profil, jouer une étape, voir les résultats, retrouver la progression après redémarrage.
- [x] **F11-04** Cas limites : deux pseudos identiques à la casse près, changement de date du téléphone, suppression du joueur actif, fermeture en plein quiz.
- [x] **F11-05** Couverture de tests : 90 % sur le domaine et 80 % au moins sur les données.
- [x] **F11-06** Mise en page utilisable sur tablette.

**Publication**

- [x] **F11-07** Nom définitif de l'app, icône et écran de lancement.
- [x] **F11-08** Aucun appel réseau ni SDK tiers qui communique dans la version 1.0 ; paquet de moins de 40 Mo.
- [x] **F11-09** Politique de confidentialité et déclarations « public enfants » de Google Play et de l'App Store.
- [x] **F11-10** Fiches des stores : textes et captures d'écran.
- [ ] **F11-11** Builds signés et obfusqués Android et iOS, envoyés en test interne.

**Terminé quand :** les deux builds sont installés depuis les canaux de test des stores et le trajet complet passe sur un vrai téléphone.

## F12 · Révision du jour et Survie

Deux défis s'ajoutent à l'onglet Défis : une révision choisie par le moteur et un mode à 3 vies.

- [x] **F12-01** Révision du jour : 10 questions sans chrono, d'abord les faits dont la date de révision est passée, puis ceux au plus faible taux de réussite.
- [x] **F12-02** Survie : 3 vies, une erreur en retire une ; le temps par question part de 10 secondes et raccourcit au fil de la partie.
- [x] **F12-03** Record de Survie et badge Survivant (30 bonnes réponses).
- [x] **F12-04** Mode Survie du `QuizBloc` : vies, temps décroissant, question remplacée au retour d'arrière-plan.
- [x] **F12-05** Cartes Révision du jour et Survie dans l'écran Défis ; affichage des vies pendant le quiz.
- [x] **F12-06** Tests : sélection des faits à revoir avec une horloge factice, fin de partie à la troisième erreur, record.

**Terminé quand :** la Révision du jour propose les faits ratés la veille, et une partie de Survie s'arrête à la troisième erreur.

## F13 · Mes monstres

Les faits les plus difficiles du joueur deviennent des petits monstres à apprivoiser.

- [x] **F13-01** Règle : un fait raté au moins 2 fois et encore en boîte 1 à 3 devient un monstre ; 5 au plus sont montrés, les plus coriaces.
- [x] **F13-02** Cas d'usage `GetMonsters`, calculé à partir de la maîtrise des items, sans nouvelle table.
- [x] **F13-03** Chasse aux monstres : quiz de 10 questions centré sur ces faits.
- [x] **F13-04** Un monstre est apprivoisé quand son fait atteint le statut « Acquis » ; il rejoint la collection.
- [x] **F13-05** Carte Chasse aux monstres dans Défis ; monstres apprivoisés dans la collection du Profil.
- [x] **F13-06** Dessins des petits monstres.
- [x] **F13-07** Tests : apparition, limite de 5, apprivoisement.

**Terminé quand :** un fait raté deux fois apparaît comme monstre, puis rejoint la collection une fois acquis.

## F14 · Duel sur le même téléphone

Deux joueurs s'affrontent face à face sur un écran coupé en deux.

- [x] **F14-01** Règles : le premier à 10 bonnes réponses gagne ; une erreur bloque les boutons du joueur pendant 2 secondes.
- [x] **F14-02** Chaque joueur reçoit des questions de ses propres tables débloquées ; un invité sans profil joue les 12 tables.
- [x] **F14-03** Le duel rapporte des XP aux profils qui jouent et ne modifie pas la maîtrise des faits.
- [x] **F14-04** `DuelBloc` : choix des joueurs, duel en cours, terminé avec vainqueur.
- [x] **F14-05** Écran Duel : deux moitiés tête-bêche, une question et 4 boutons par joueur, les deux scores. Maquette : `15-duel.png`.
- [x] **F14-06** Choix des deux joueurs, ou d'un invité, avant le duel.
- [x] **F14-07** Tests de `DuelBloc` : appuis simultanés, blocage de 2 secondes, victoire.

**Terminé quand :** deux profils de niveaux différents jouent un duel complet et reçoivent chacun leurs XP.

## F15 · Nouveaux formats de questions

Deux formats s'ajoutent sans toucher au moteur : ils s'enregistrent dans le registre des types.

- [x] **F15-01** Type « Trouver l'opération » : un résultat, 4 opérations au choix, une seule juste.
- [x] **F15-02** Type « Relier les paires » : 4 opérations et 4 résultats à associer.
- [x] **F15-03** Les deux types comptent comme réponse reconnue pour la maîtrise (plafond à la boîte 3).
- [x] **F15-04** Widgets de réponse des deux types. Maquettes : `16-quiz-find-operation.png` et `17-quiz-match-pairs.png`.
- [x] **F15-05** Ajout des deux types aux étapes Vitesse et Boss, et à l'Entraînement libre.
- [x] **F15-06** Tests : génération sans ambiguïté (une seule opération juste, 4 résultats distincts), validation, tests de widget.

**Terminé quand :** les deux formats apparaissent dans un quiz de l'étape Vitesse, sans changement dans le code du `QuizBloc`.

## F16 · Test de départ

À la création du profil, un test rapide ouvre d'emblée les tables que l'enfant connaît déjà.

- [x] **F16-01** Cas d'usage `RunPlacementTest` : 12 questions, une par table.
- [x] **F16-02** Une table réussie est ouverte dans le parcours ; ses étoiles restent à gagner.
- [x] **F16-03** Proposition du test en fin de création de profil, avec un bouton « Passer ».
- [x] **F16-04** Écran de bilan du test : tables ouvertes. Maquette : `18-placement-test-result.png`.
- [x] **F16-05** Tests : ouverture des bonnes tables, test passé, test abandonné en cours.

**Terminé quand :** un nouveau joueur qui réussit les questions des tables de 1, 2 et 10 démarre avec ces trois tables ouvertes.

## F17 · Classement local

Les joueurs du téléphone sont classés par XP gagnés dans la semaine.

- [x] **F17-01** Contrat `LeaderboardRepository` avec une portée (téléphone, amis, monde) ; seule la portée téléphone est implémentée.
- [x] **F17-02** Cas d'usage `GetLeaderboard` : XP de la semaine calculés à partir du journal des sessions, remise à zéro chaque lundi.
- [x] **F17-03** `LeaderboardCubit` et écran Classement : avatar, pseudo, XP de la semaine. Maquette : `19-leaderboard.png`.
- [x] **F17-04** Réglage pour masquer le classement.
- [x] **F17-05** Tests : calcul hebdomadaire avec une horloge factice, passage du dimanche au lundi, égalités.

**Terminé quand :** deux joueurs qui ont joué dans la semaine apparaissent classés, et le classement repart de zéro le lundi.

## F18 · Rappel quotidien

Une notification locale rappelle à l'enfant de jouer, à l'heure choisie.

- [x] **F18-01** Ajout de flutter_local_notifications et configuration Android et iOS.
- [x] **F18-02** Demande d'autorisation au moment où le rappel est activé, jamais au premier lancement.
- [x] **F18-03** Réglage : rappel activé ou non (désactivé par défaut) et heure du rappel.
- [x] **F18-04** Programmation et annulation de la notification ; pas de rappel le jour où une session est déjà terminée.
- [x] **F18-05** Tests : programmation, annulation, changement d'heure, avec un service de notification factice.

**Terminé quand :** un rappel réglé sur une heure proche s'affiche sur un vrai téléphone Android et sur un iPhone.

## F19 · Défi par code

Un joueur partage un code ; un ami rejoue exactement les mêmes questions sur un autre téléphone, sans réseau.

- [x] **F19-01** Format du code, une dizaine de caractères : tables choisies, mode, graine du tirage, score à battre, version du générateur, caractère de contrôle.
- [x] **F19-02** Cas d'usage `EncodeChallengeCode` et `BuildQuizFromCode`.
- [x] **F19-03** Générateur de questions figé par version : une même graine donne les mêmes questions sur tout téléphone.
- [x] **F19-04** Bouton « Défier un ami » en fin d'Entraînement libre et de Contre-la-montre ; affichage et copie du code.
- [x] **F19-05** Saisie d'un code dans l'écran Défis, avec un message clair si le code est invalide ou d'une version inconnue.
- [x] **F19-06** Écran de comparaison des deux scores. Maquette : `21-challenge-score.png`.
- [x] **F19-07** Tests : encodage puis décodage, code altéré refusé, mêmes questions pour un même code.

**Terminé quand :** un code créé sur un téléphone donne les mêmes questions sur un second, qui affiche les deux scores.

## F20 · Sauvegarde par fichier

La progression survit à un changement de téléphone grâce à un fichier exporté puis importé.

- [x] **F20-01** Format de fichier versionné contenant un profil et toutes ses données.
- [x] **F20-02** Export d'un profil vers un fichier, partagé par la feuille de partage du système.
- [x] **F20-03** Import : contrôle du format, puis choix entre remplacer le profil existant ou renommer en cas de pseudo déjà pris.
- [x] **F20-04** Entrées « Exporter » et « Importer » dans les réglages. Maquette : `13-settings.png` (section Sauvegarde).
- [x] **F20-05** Tests : aller-retour export puis import sans perte, fichier corrompu refusé, conflit de pseudo.

**Terminé quand :** un profil exporté puis importé sur un second téléphone retrouve son niveau, sa série, ses étoiles et sa grille de maîtrise.

## F21 · Autres langues et boutique

L'app s'ouvre à d'autres langues, et des pièces gagnées en jouant servent à débloquer des avatars et des thèmes.

- [x] **F21-01** Fichiers de traduction supplémentaires : anglais et espagnol.
- [x] **F21-02** Choix de la langue dans les réglages, langue du téléphone par défaut.
- [x] **F21-03** Pièces gagnées en jouant : 1 pièce tous les 10 XP, 20 par couronne, 10 par badge ; solde par profil, migration.
- [x] **F21-04** Catalogue d'avatars et de thèmes à débloquer avec des pièces ; aucun achat en argent réel.
- [x] **F21-05** Écran Boutique : catalogue, solde, achat, élément actif. Maquette : `22-shop.png`.
- [x] **F21-06** Tests : gain de pièces, achat, solde insuffisant, changement de langue.

**Terminé quand :** l'app s'affiche dans une seconde langue, et un joueur achète un avatar avec ses pièces.

## F22 · Services de jeux Google Play

Lot ouvert hors plan pour publier Play Games sur un canal de test (voir `docs/decisions.md`). Les succès et le classement mondial ne sont pas planifiés : le mode en ligne n'est plus une priorité de la version 2.0.

- [x] **F22-01** Connexion à Google Play Games Services au démarrage, sur Android seulement, sans effet sur le jeu hors ligne.

## Version 2.0 · Kid Matix pour tous

La version 2.0 ouvre l'app au plus grand nombre d'enfants, en particulier en Afrique et auprès des ONG et des écoles : partir du niveau réel de l'enfant, lever la barrière de la lecture et de la langue grâce à l'audio (français et wolof), élargir les mathématiques, apprendre les mots des problèmes, outiller l'enseignant avec un mode classe hors ligne, et mesurer les progrès. La vision est décrite dans la section 17 des [spécifications](specifications.md) ; les choix et les points ouverts sont dans `docs/decisions.md`.

Règles propres à la version 2.0, en plus des règles communes :

- Tout fonctionne hors ligne, sur un Android d'entrée de gamme ; aucune nouvelle donnée ne quitte l'appareil.
- Aucun achat intégré, aucune publicité.
- Chaque nouveau domaine est une fonctionnalité de `lib/features/` qui implémente `LearningDomain` et s'enregistre dans `DomainRegistry`, avec des clés d'items stables qui ne changent plus après publication.
- Les écrans sans maquette sont proposés à partir des écrans existants et validés par le propriétaire avant d'être codés.
- Les textes sont en français, anglais et espagnol, comme le reste de l'app. Le wolof est une **aide audio**, pas une langue d'interface.

## F23 · Lecture à voix haute

Les enfants qui lisent mal entendent chaque question et chaque consigne en français (ou dans la langue de l'app).

- [x] **F23-01** Choix technique, noté dans `docs/decisions.md` : synthèse vocale du système pour les textes générés (les questions changent à chaque partie). Vérifier qu'une voix française fonctionne hors ligne sur Android d'entrée de gamme et sur iOS ; prévoir le cas où aucune voix n'est installée.
- [x] **F23-02** Interface `SpeechService` dans `core/services/` (parler, arrêter, disponibilité, langue) et son implémentation dans une fonctionnalité dédiée ; service factice pour les tests.
- [x] **F23-03** Bouton « Écouter » (haut-parleur, avec `tooltip`) sur la carte de question de tous les formats ; il lit l'énoncé comme une phrase, en réutilisant `PromptReading` (« 5 fois 7 égale combien »).
- [x] **F23-04** Réglage par joueur « Lire les questions à voix haute » : lecture automatique de chaque nouvelle question. Désactivé par défaut, proposé à la création du profil.
- [x] **F23-05** Lecture des consignes principales (« Touche la bonne réponse »), des astuces de l'étape Découverte et des messages de la mascotte.
- [x] **F23-06** Le chrono ne démarre qu'à la fin de la lecture ; il se met en pause pendant une lecture demandée par l'enfant.
- [x] **F23-07** Le bouton est masqué, sans message d'erreur, quand aucune voix n'est disponible.
- [x] **F23-08** Tests : service factice, chrono en attente de la lecture, bouton masqué sans voix, réglage par joueur.

**Terminé quand :** en mode avion, sur un téléphone d'entrée de gamme, une question est lue en français et le chrono attend la fin de la lecture.

## F24 · Domaine « Nombres jusqu'à 100 »

Le parcours commence plus bas, pour les enfants qui n'ont pas encore les bases : compter, lire un nombre, dizaines et unités, comparer.

- [x] **F24-01** Fonctionnalité `numbers` qui implémente `LearningDomain` : unités « compter jusqu'à 10 », « jusqu'à 20 », « jusqu'à 100 », « dizaines et unités », « comparer », « ranger », « avant et après » ; clés stables (`num:…`).
- [x] **F24-02** Nouveaux types de questions, enregistrés dans `QuestionTypeRegistry` : compter des objets, dizaines et unités (paquets de dix et bâtonnets), comparer (plus petit, égal, plus grand : 3 boutons), droite numérique.
- [x] **F24-03** Widgets visuels : groupes d'objets, paquets de dix, droite numérique ; chaque dessin a un libellé pour les lecteurs d'écran.
- [x] **F24-04** Parcours du domaine : étapes, étoiles et déblocage réutilisés de `learning_path`. Vérifier que `domainId` est bien pris en compte partout (`item_progress`, `stage_progress`, `quiz_session`, records), car il valait toujours « multiplication ».
- [x] **F24-05** Accueil : sélecteur de domaine dès que deux domaines existent, dernier domaine mémorisé par joueur. XP, niveau, série et mascotte restent globaux ; étoiles, couronnes, maîtrise et records sont tenus par domaine (spécifications, section 12).
- [x] **F24-06** Profil : grille de maîtrise et monstres par domaine, avec un choix du domaine.
- [x] **F24-07** Combat de boss à la fin de chaque unité, avec un monstre par unité (dessins provisoires).
- [x] **F24-08** Astuce et aide visuelle par unité (fiche d'aide après deux erreurs, comme en multiplication).
- [x] **F24-09** Maquettes à proposer et faire valider : sélecteur de domaine, carte du domaine, les quatre nouveaux formats.
- [x] **F24-10** Tests : clés uniques et stables, génération sans ambiguïté, validation de chaque type, progression de la multiplication intacte, test de widget de chaque format.

**Terminé quand :** un nouveau joueur choisit « Nombres », réussit l'étape « compter jusqu'à 20 », gagne ses étoiles, et sa progression en multiplication n'a pas bougé.

## F25 · Domaine « Additions et soustractions »

- [x] **F25-01** Fonctionnalité `addition` qui implémente `LearningDomain` : additions jusqu'à 10, jusqu'à 20, compléments à 10, soustractions jusqu'à 10, jusqu'à 20, puis additions et soustractions jusqu'à 100 sans et avec retenue ; clés stables (`add:7+8`, `sub:15-7`).
- [x] **F25-02** Mauvaises réponses plausibles : écart de 1, mauvaise opération, chiffres inversés, oubli de la retenue ; jamais de nombre négatif.
- [x] **F25-03** Familles de faits : 7 + 8, 8 + 7, 15 − 8 et 15 − 7 sont liés ; rappel après une erreur, comme le fait inversé de la multiplication (`mirrorOf`).
- [x] **F25-04** Aides visuelles : droite numérique, paquets de dix, « compléter jusqu'à 10 » ; une astuce par unité.
- [x] **F25-05** Parcours, étoiles, boss et maîtrise du domaine, sur le modèle de F24.
- [x] **F25-06** Tests : clés, génération, familles de faits, mauvaises réponses sans doublon pour tous les faits.

**Terminé quand :** un joueur enchaîne les additions jusqu'à 20, une erreur sur 7 + 8 rappelle 8 + 7, et les faits ratés reviennent le lendemain.

## F26 · Domaine « Division »

- [x] **F26-01** Fonctionnalité `division` qui implémente `LearningDomain`, calculée à partir des 120 faits de multiplication : clés `div:56/7`, une unité par table, même ordre que le parcours de multiplication.
- [x] **F26-02** Lien avec la multiplication : après une erreur sur 56 ÷ 7, rappel de 7 × 8 = 56.
- [x] **F26-03** Aide visuelle : partager des objets en groupes égaux ; astuce par table.
- [x] **F26-04** Parcours, étoiles, boss et maîtrise du domaine.
- [x] **F26-05** Tests : clés, génération, lien avec la multiplication.

**Terminé quand :** un joueur fait le parcours de la division par 2 et voit le rappel de la multiplication après une erreur.

## F27 · Test de positionnement par compétence

Le test de départ (F16) devient un vrai positionnement : l'enfant est placé selon ce qu'il sait faire, pas selon son âge, dans l'esprit de l'approche « Teaching at the Right Level ».

- [ ] **F27-01** Niveaux de compétence ordonnés : nombres, addition, soustraction, multiplication, division ; chaque niveau a quelques questions types.
- [ ] **F27-02** Test adaptatif d'environ 5 minutes : il monte de niveau tant que l'enfant réussit et s'arrête au premier niveau non acquis.
- [ ] **F27-03** Résultat : un niveau par domaine ; les unités acquises sont ouvertes, et le domaine et l'unité de départ sont recommandés sur l'accueil.
- [ ] **F27-04** Le test se lit à voix haute (F23) et se repasse depuis le Profil.
- [ ] **F27-05** Chaque résultat est conservé avec sa date (migration), pour comparer un début et une fin de période (F31).
- [ ] **F27-06** Écran de bilan mis à jour (sur le modèle de `18-placement-test-result.png`).
- [ ] **F27-07** Tests : arrêt au premier niveau non acquis, unités ouvertes, test abandonné, historique des résultats.

**Terminé quand :** un enfant qui sait compter mais ne sait pas additionner démarre sur les additions jusqu'à 10, et son résultat daté apparaît dans le Profil.

## F28 · Les mots des maths

Beaucoup d'enfants ne bloquent pas sur le calcul, mais sur les mots de l'énoncé. Ce lot leur apprend les mots et expressions des problèmes, avec une explication audio en wolof enregistrée par le propriétaire.

- [x] **F28-01** Tableau de contenu `docs/product/math-words.md` : environ 40 mots et expressions en six familles (ajouter, enlever, comparer, grouper, partager, questions). Pour chacun : clé stable, mot en français, sens simple, idée d'image, phrase d'exemple, et des colonnes vides pour le propriétaire (explication en wolof, exemple en wolof, nom du fichier audio). Un glossaire de cohérence note le mot wolof retenu pour chaque notion.
- [x] **F28-02** Guide d'enregistrement `docs/product/audio-recording.md` (pièce calme, deux fichiers par mot, `wo_<clé>.m4a` pour l'explication et `wo_<clé>_exemple.m4a` pour l'exemple, ton lent, 2 s de silence avant et après) et un script dans `tool/` qui coupe les silences, égalise le volume, convertit en un format mono compressé et vérifie que chaque clé a ses deux fichiers.
- [x] **F28-03** Packs audio : `assets/audio/<langue>/` avec un manifeste ; le pack wolof est intégré à l'app ; un fichier manquant masque simplement le bouton. Le code ne dépend d'aucune langue en particulier.
- [x] **F28-04** Fonctionnalité `math_words` qui implémente `LearningDomain` : chaque mot est un item (`word:il_reste`) suivi par la répétition espacée.
- [x] **F28-05** Une illustration vectorielle simple par mot (provisoire, remplaçable sans changer le code).
- [x] **F28-06** Type de question « Écoute et touche » : on entend le mot (français, puis wolof à la demande), on touche la bonne image parmi 4.
- [x] **F28-07** Type de question « Mot et image » : relier des expressions à leurs dessins (réutiliser le widget de « Relier les paires »).
- [x] **F28-08** Type de question « Toucher pour comprendre » : dans une phrase, chaque mot important se touche pour l'entendre en français et en wolof et voir son image.
- [x] **F28-09** Type de question « Quelle opération ? » : un petit énoncé lu à voix haute, l'enfant choisit +, −, × ou ÷ sans calculer ; une vingtaine d'énoncés courts dans le tableau de contenu.
- [x] **F28-10** Bouton « Écouter en wolof » partout où un mot est présenté ; réglage par joueur « Aide audio : wolof / aucune ».
- [x] **F28-11** Parcours des mots : une unité par famille, dans le sélecteur de domaine.
- [ ] **F28-12** Maquettes à proposer et faire valider : les quatre activités et le bouton wolof.
- [x] **F28-13** Tests : clés, manifeste du pack audio, fichier manquant, activités, répétition espacée des mots.

**Terminé quand :** en mode avion, un enfant entend « il reste » en français puis en wolof, touche la bonne image, et un mot raté revient le lendemain ; « Quelle opération ? » fonctionne sur les énoncés du tableau.

## F29 · Mode classe hors ligne

L'enseignant suit sa classe sans Internet : élèves, devoirs, tableau de bord, groupes de niveau et défi de classe.

- [ ] **F29-01** Trancher avec le propriétaire, avant de coder, le contexte principal : tablettes partagées à l'école, ou téléphones des familles ; et la taille maximale d'une classe. Noter la réponse dans `docs/decisions.md`.
- [ ] **F29-02** Entités `ClassroomEntity`, élève (un profil rattaché à une classe) et `AssignmentEntity` (domaine, unité, échéance) ; migration.
- [ ] **F29-03** Mode enseignant protégé par un code à 4 chiffres choisi par l'enseignant (aucun compte) ; entrée discrète depuis « Qui joue ? ».
- [ ] **F29-04** Créer une classe et ajouter ses élèves en une fois (une liste de pseudos ou de numéros, pas de vrais noms conseillés) ; la limite de 10 profils ne s'applique pas aux élèves d'une classe.
- [ ] **F29-05** « Qui joue ? » en mode classe : choisir sa classe, puis son nom ou son avatar, avec recherche pour une classe nombreuse.
- [ ] **F29-06** Devoirs : l'enseignant donne une unité à travailler ; l'élève voit « Le devoir de la classe » en tête de l'accueil.
- [ ] **F29-07** Tableau de bord : par élève (progression, temps de pratique, dernière séance) et par compétence (faits et mots les plus ratés, par exemple « 8 élèves se trompent sur 7 × 8 »).
- [ ] **F29-08** Groupes de niveau proposés à partir du positionnement (F27) et de la maîtrise.
- [ ] **F29-09** Défi de classe : un objectif commun de la semaine (par exemple 1 000 bonnes réponses), une jauge visible par toute la classe, aucun classement individuel.
- [ ] **F29-10** Transfert sans réseau : exporter les résultats d'une tablette vers celle de l'enseignant par fichier (format versionné de F20, partagé par la feuille de partage ou Bluetooth), puis fusion sans doublon.
- [ ] **F29-11** Maquettes à proposer et faire valider : accès enseignant, classe, devoirs, tableau de bord, défi de classe.
- [ ] **F29-12** Tests : code enseignant, classe de 40 élèves, devoirs, calculs du tableau de bord, fusion d'un fichier reçu deux fois.

**Terminé quand :** sur une tablette, un enseignant crée une classe de 30 élèves et donne un devoir sur les additions jusqu'à 20 ; trois élèves jouent, et le tableau de bord montre qui bloque et sur quels faits.

## F30 · Résoudre des problèmes

Les enfants apprennent à comprendre une situation, pas à réagir à un mot-clé : énoncés du quotidien, schémas en barres et résolution guidée.

- [ ] **F30-01** Contenu `docs/product/problems.md` : une trentaine de problèmes en trois niveaux (avec images, phrase courte, énoncé complet), dans des contextes d'ici (marché, francs CFA, mangues, car rapide, Tabaski, thé) avec des prénoms d'ici ; colonnes pour l'audio wolof enregistré par le propriétaire.
- [ ] **F30-02** Gabarits de problèmes avec des nombres tirés au sort, pour varier les énoncés ; clé stable par gabarit. Les versions enregistrées en wolof ont des nombres fixes ; les variantes générées sont lues en français par la synthèse vocale (F23).
- [ ] **F30-03** Type « Schéma en barres » : placer les nombres sur le tout et les parties, choisir l'opération, puis calculer.
- [ ] **F30-04** Résolution guidée en étapes : écouter, faire le schéma, choisir l'opération, calculer, vérifier.
- [ ] **F30-05** Dans chaque énoncé, les mots des maths (F28) se touchent ; bouton « Écouter en wolof » sur les énoncés enregistrés.
- [ ] **F30-06** Problèmes « piège du mot-clé » (« 3 de plus que » qui demande une soustraction) : la correction montre le schéma.
- [ ] **F30-07** Parcours « Problèmes » par opération et par niveau ; maîtrise suivie par gabarit.
- [ ] **F30-08** Monnaie et unités : francs CFA par défaut, prévu pour d'autres monnaies selon la région.
- [ ] **F30-09** Maquettes à proposer et faire valider : énoncé, schéma en barres, étapes guidées.
- [ ] **F30-10** Tests : gabarits sans ambiguïté, schéma, étapes, piège du mot-clé.

**Terminé quand :** un enfant résout « Awa a 12 mangues, elle en donne 5 » avec le schéma en barres, en écoutant l'énoncé en wolof, puis réussit la version piège du même problème.

## F31 · Mesure des progrès et outils de l'enseignant

Ce que les ONG doivent pouvoir montrer : des progrès mesurés, des rapports simples, sans donnée personnelle.

- [ ] **F31-01** Évaluation de début et de fin de période, lancée depuis le mode enseignant : positionnement (F27) et compréhension des mots (F28), datée et conservée.
- [ ] **F31-02** Rapport de classe : progression entre deux évaluations, compétences acquises, temps de pratique, mots compris ; export en PDF et en CSV par la feuille de partage.
- [ ] **F31-03** Rapport d'école ou de programme : un appareil coordinateur (celui de l'ONG) importe les fichiers de plusieurs classes et produit un rapport consolidé.
- [ ] **F31-04** Exports anonymes : numéros à la place des pseudos ; aucune donnée personnelle dans les rapports.
- [ ] **F31-05** Transfert de petits résultats par QR code, sans fichier.
- [ ] **F31-06** L'enseignant enregistre lui-même l'explication d'un mot ou d'un énoncé dans sa langue, depuis le mode enseignant ; l'enregistrement remplace le pack audio sur cet appareil et s'exporte comme pack.
- [ ] **F31-07** Fiches à imprimer générées en PDF : exercices et cartes de mots en français et en wolof.
- [ ] **F31-08** Tests : calcul de progression, consolidation de plusieurs classes, anonymisation, QR code, enregistrement.

**Terminé quand :** deux évaluations faites à un mois d'écart donnent un rapport PDF de la classe qui montre la progression, sans aucun pseudo dans la version anonyme.

## F32 · Autres langues d'aide et suite

À lancer avec des partenaires, quand le terrain le demande.

- [ ] **F32-01** Nouveaux packs audio (pulaar, sérère, bambara, haoussa…) enregistrés avec des partenaires ; import d'un pack par fichier, sans mise à jour de l'app.
- [ ] **F32-02** Guide de prise en main du mode classe pour les animateurs d'ONG (PDF et courte vidéo).
- [ ] **F32-03** Synchronisation en ligne facultative des résultats de classe : choix du serveur, consentement et protection des données à trancher avec les partenaires avant toute tâche technique.

**Terminé quand :** un pack audio d'une nouvelle langue s'importe par fichier et remplace l'aide wolof sur un appareil.

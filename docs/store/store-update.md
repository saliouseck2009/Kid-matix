# Mise à jour des fiches des stores — version complète (F0 à F21)

> **À faire par le propriétaire.** Les fiches remplies en F11 décrivent la
> version 1.0. L'app publiée contiendra tout ce qui a été construit jusqu'à
> F21 : défis, monstres, duel, défi par code, test de départ, classement,
> rappel, sauvegarde, boutique, anglais et espagnol. Ce document liste, store
> par store, chaque champ à changer avec son texte. Les textes français
> remplacent ceux de `listing.md` ; l'anglais et l'espagnol sont nouveaux.
> Les longueurs sont comptées en caractères, espaces comprises.

## 0. Avant les stores

| # | Action | Détail |
| --- | --- | --- |
| 0.1 | Numéro de build | `pubspec.yaml` passe à `1.0.0+2` : un bundle `+1` a peut-être déjà été envoyé à Google Play, et chaque envoi demande un numéro plus grand (même règle pour TestFlight). |
| 0.2 | Construire | `bash tool/build_release.sh` (Android et iOS), avec `android/key.properties`. Garder `build/symbols/`. |
| 0.3 | Captures | 8 captures par format (liste en section 3), à prendre sur un joueur avancé, en français, puis en anglais et en espagnol si l'on veut des captures traduites (sinon les captures françaises servent pour les trois langues). |
| 0.4 | Politique de confidentialité | Déjà à jour sur GitHub Pages (rappel et sauvegarde par fichier ajoutés par F18 et F20). Rien à faire. |

## 1. Textes français (remplacent la fiche actuelle)

### Nom et titres

| Champ | Texte | Longueur |
| --- | --- | --- |
| Titre Google Play / nom App Store | Kid Matix : tables de 1 à 12 | 28 / 30 |
| Sous-titre App Store | Les tables de multiplication | 28 / 30 |
| Description courte Google Play | Les tables de multiplication en jouant, sans pub et sans Internet ! | 67 / 80 |

### Texte promotionnel (App Store, 170 au plus)

> Les tables de 1 à 12 en jouant : un parcours, des défis, des monstres à apprivoiser et une mascotte qui grandit. Sans pub, sans achat, sans Internet.

### Mots-clés (App Store, 100 au plus)

```
calcul,maths,CE1,CE2,CM1,CM2,école,primaire,enfant,révisions,jeu,apprendre,défi,duel,mascotte
```

### Description complète (Google Play et App Store)

```
Kid Matix aide les enfants à connaître par cœur les tables de multiplication, de 1 à 12, en jouant quelques minutes par jour.

UN PARCOURS PAS À PAS
Chaque table est un monde sur la carte, avec 5 étapes : Découverte (la table et son astuce), Entraînement, Écriture, Vitesse, puis un combat contre le monstre de la table. Chaque étape rapporte jusqu'à 3 étoiles, et vaincre le monstre pose une couronne sur la table. Un test de départ, au choix, ouvre d'emblée les tables déjà connues.

SIX FAÇONS DE RÉPONDRE
Choix multiple, vrai ou faux, réponse à taper, opération à trous, trouver l'opération, relier les paires : les formats changent pour ne jamais s'ennuyer. Après une erreur, la bonne réponse s'affiche et la question revient un peu plus tard.

UN JEU QUI S'ADAPTE À L'ENFANT
Kid Matix suit la maîtrise de chacune des multiplications et fait revenir les plus fragiles au bon moment. La Révision du jour propose 10 questions choisies pour l'enfant. Les calculs qui résistent deviennent de petits monstres à apprivoiser dans la Chasse aux monstres.

DES DÉFIS POUR S'AMUSER
Contre-la-montre : un maximum de bonnes réponses en 60 secondes. Survie : 3 vies, de plus en plus vite. Duel : deux joueurs face à face sur le même téléphone. Défi par code : un code à donner à un ami pour qu'il rejoue les mêmes questions, sans Internet.

DES RÉCOMPENSES QUI DONNENT ENVIE DE REVENIR
Points d'expérience et niveaux, étoiles, couronnes, série de jours joués, objectif du jour et badges. Une mascotte accompagne l'enfant et grandit avec lui. Les pièces gagnées en jouant débloquent des avatars et des thèmes de couleur dans la boutique, sans argent réel. Un classement de la semaine réunit les joueurs du téléphone ; il se masque dans les réglages.

PLUSIEURS ENFANTS, UN SEUL TÉLÉPHONE
Jusqu'à 10 joueurs, chacun avec son pseudo, son avatar, sa progression et ses réglages. Pas de compte, pas d'e-mail, pas de mot de passe. Un adulte peut exporter un profil dans un fichier et le reprendre sur un autre téléphone.

À CHACUN SON RYTHME
Le chrono peut être détendu ou coupé, une erreur ne fait rien perdre, et un rappel quotidien peut être activé à l'heure choisie.

UN ESPACE SÛR
Aucune publicité, aucun achat, aucun lien vers l'extérieur. L'export et l'import d'un profil sont protégés par un contrôle parental. L'application fonctionne entièrement hors ligne : aucune donnée ne quitte le téléphone sans l'action d'un adulte.

Pour les enfants à partir de 6 ans. En français, en anglais et en espagnol.
```

### Notes de version (premier envoi en production)

Google Play (balises comprises, 500 au plus) :

```
<fr-FR>
Première version de Kid Matix !
• Les tables de 1 à 12 sur un parcours, jusqu'au combat contre le monstre de chaque table
• Révision du jour, Contre-la-montre, Survie, Chasse aux monstres et Duel
• Défi par code entre amis, sans Internet
• Pièces, avatars et thèmes à débloquer, sans argent réel
• En français, anglais et espagnol, sans pub et hors ligne
</fr-FR>
```

App Store, « Nouveautés » : non demandé pour la première version.

## 2. Textes anglais et espagnols (nouvelles langues de fiche)

### Anglais (Google Play `en-US`, App Store « English (U.S.) »)

| Champ | Texte | Longueur |
| --- | --- | --- |
| Titre / nom | Kid Matix: Times Tables 1-12 | 28 / 30 |
| Sous-titre App Store | Learn your times tables | 23 / 30 |
| Description courte Google Play | Learn your times tables by playing, with no ads and no internet! | 64 / 80 |
| Texte promotionnel | Times tables 1 to 12 through play: a path, challenges, monsters to tame and a mascot that grows. No ads, no purchases, no internet. | 131 / 170 |
| Mots-clés | `math,maths,multiplication,school,kids,learn,practice,game,arithmetic,homework,challenge,mascot` | 94 / 100 |

```
Kid Matix helps children learn their multiplication tables by heart, from 1 to 12, by playing a few minutes a day.

A STEP-BY-STEP PATH
Each table is a world on the map, with 5 stages: Discovery (the table and its trick), Practice, Writing, Speed, then a fight against the table's monster. Each stage earns up to 3 stars, and beating the monster puts a crown on the table. An optional placement test opens the tables your child already knows.

SIX WAYS TO ANSWER
Multiple choice, true or false, typed answer, missing number, find the operation, match the pairs: the formats keep changing so it never gets boring. After a mistake, the right answer shows and the question comes back a little later.

A GAME THAT ADAPTS TO YOUR CHILD
Kid Matix tracks how well each multiplication is known and brings back the shakiest ones at the right time. The Daily Review offers 10 questions picked for your child. Facts that keep resisting turn into little monsters to tame in the Monster Hunt.

CHALLENGES FOR FUN
Beat the Clock: as many right answers as possible in 60 seconds. Survival: 3 lives, faster and faster. Duel: two players face to face on the same phone. Challenge code: give a friend a code to replay the same questions, with no internet.

REWARDS THAT MAKE THEM COME BACK
Experience points and levels, stars, crowns, daily streak, daily goal and badges. A mascot keeps your child company and grows with them. Coins earned by playing unlock avatars and color themes in the shop, with no real money. A weekly leaderboard brings together the players of the phone; it can be hidden in the settings.

SEVERAL CHILDREN, ONE PHONE
Up to 10 players, each with their own nickname, avatar, progress and settings. No account, no email, no password. An adult can export a profile to a file and bring it to another phone.

AT THEIR OWN PACE
The timer can be relaxed or turned off, a mistake never costs anything, and an optional daily reminder rings at the chosen time.

A SAFE SPACE
No ads, no purchases, no links outside the app. Exporting and importing a profile are protected by a parental gate. The app works fully offline: no data leaves the phone without an adult's action.

For children aged 6 and up. In English, French and Spanish.
```

Notes de version Google Play :

```
<en-US>
First version of Kid Matix!
• Times tables 1 to 12 on a path, up to the fight against each table's monster
• Daily Review, Beat the Clock, Survival, Monster Hunt and Duel
• Challenge codes between friends, with no internet
• Coins, avatars and themes to unlock, with no real money
• In English, French and Spanish, ad-free and offline
</en-US>
```

### Espagnol (Google Play `es-ES`, App Store « Spanish (Spain) » ; ajouter aussi `es-419` / « Spanish (Mexico) » avec les mêmes textes si l'on vise l'Amérique latine)

| Champ | Texte | Longueur |
| --- | --- | --- |
| Titre / nom | Kid Matix: tablas del 1 al 12 | 29 / 30 |
| Sous-titre App Store | Las tablas de multiplicar | 25 / 30 |
| Description courte Google Play | ¡Las tablas de multiplicar jugando, sin anuncios y sin Internet! | 64 / 80 |
| Texto promocional | Las tablas del 1 al 12 jugando: un recorrido, retos, monstruos que domar y una mascota que crece. Sin anuncios, sin compras, sin Internet. | 138 / 170 |
| Mots-clés | `matemáticas,multiplicar,niños,escuela,primaria,aprender,juego,cálculo,repaso,reto,duelo,mascota` | 95 / 100 |

```
Kid Matix ayuda a los niños a aprenderse de memoria las tablas de multiplicar, del 1 al 12, jugando unos minutos al día.

UN RECORRIDO PASO A PASO
Cada tabla es un mundo en el mapa, con 5 etapas: Descubrimiento (la tabla y su truco), Entrenamiento, Escritura, Velocidad y, al final, un combate contra el monstruo de la tabla. Cada etapa da hasta 3 estrellas, y vencer al monstruo pone una corona en la tabla. Una prueba inicial opcional abre desde el principio las tablas que ya se saben.

SEIS FORMAS DE RESPONDER
Opción múltiple, verdadero o falso, respuesta escrita, número que falta, encontrar la operación y unir las parejas: los formatos cambian para no aburrirse nunca. Tras un error, aparece la respuesta correcta y la pregunta vuelve un poco más tarde.

UN JUEGO QUE SE ADAPTA AL NIÑO
Kid Matix sigue el dominio de cada multiplicación y hace volver las más frágiles en el momento justo. El Repaso del día propone 10 preguntas elegidas para el niño. Las operaciones que se resisten se convierten en pequeños monstruos que domar en la Caza de monstruos.

RETOS PARA DIVERTIRSE
Contrarreloj: el máximo de respuestas correctas en 60 segundos. Supervivencia: 3 vidas, cada vez más rápido. Duelo: dos jugadores cara a cara en el mismo teléfono. Reto por código: un código para que un amigo juegue las mismas preguntas, sin Internet.

RECOMPENSAS QUE DAN GANAS DE VOLVER
Puntos de experiencia y niveles, estrellas, coronas, racha de días, objetivo diario e insignias. Una mascota acompaña al niño y crece con él. Las monedas ganadas jugando desbloquean avatares y temas de color en la tienda, sin dinero real. Una clasificación semanal reúne a los jugadores del teléfono; se puede ocultar en los ajustes.

VARIOS NIÑOS, UN SOLO TELÉFONO
Hasta 10 jugadores, cada uno con su apodo, su avatar, su progreso y sus ajustes. Sin cuenta, sin correo, sin contraseña. Un adulto puede exportar un perfil a un archivo y recuperarlo en otro teléfono.

CADA UNO A SU RITMO
El cronómetro puede ser más lento o desactivarse, un error nunca hace perder nada, y se puede activar un recordatorio diario a la hora elegida.

UN ESPACIO SEGURO
Sin anuncios, sin compras, sin enlaces externos. Exportar e importar un perfil está protegido por un control parental. La aplicación funciona totalmente sin conexión: ningún dato sale del teléfono sin la acción de un adulto.

Para niños a partir de 6 años. En español, francés e inglés.
```

Notes de version Google Play :

```
<es-ES>
¡Primera versión de Kid Matix!
• Las tablas del 1 al 12 en un recorrido, hasta el combate contra el monstruo de cada tabla
• Repaso del día, Contrarreloj, Supervivencia, Caza de monstruos y Duelo
• Retos por código entre amigos, sin Internet
• Monedas, avatares y temas que desbloquear, sin dinero real
• En español, francés e inglés, sin anuncios y sin conexión
</es-ES>
```

Les noms des modes reprennent ceux de l'app (`app_en.arb`, `app_es.arb`) : à vérifier avec la relecture des traductions.

## 3. Captures d'écran (les deux stores)

Huit captures, sur un joueur avancé (plusieurs couronnes, une série, des badges, des pièces). Formats : Google Play téléphone 1080 × 1920 ou plus ; App Store iPhone 6,9" (1320 × 2868) ou 6,3" (1206 × 2622) et iPad 13" (2064 × 2752 ou 2048 × 2732).

| # | Écran | Légende proposée (fr / en / es) |
| --- | --- | --- |
| 1 | Carte du parcours | Une table, cinq étapes, une couronne / One table, five stages, a crown / Una tabla, cinco etapas, una corona |
| 2 | Quiz « Relier les paires » ou « Trouver l'opération » | Six façons de répondre / Six ways to answer / Seis formas de responder |
| 3 | Combat de boss | Bats le monstre de chaque table / Beat each table's monster / Vence al monstruo de cada tabla |
| 4 | Onglet Défis | Révision, Contre-la-montre, Survie… / Review, Beat the Clock, Survival… / Repaso, Contrarreloj, Supervivencia… |
| 5 | Duel | À deux sur le même téléphone / Two players, one phone / Dos jugadores, un teléfono |
| 6 | Mes monstres | Apprivoise les calculs qui résistent / Tame the tricky facts / Doma las operaciones difíciles |
| 7 | Boutique | Des avatars et des thèmes à débloquer / Avatars and themes to unlock / Avatares y temas que desbloquear |
| 8 | Profil | Ta mascotte grandit avec toi / Your mascot grows with you / Tu mascota crece contigo |

Je peux prendre ces captures sur le simulateur iPhone et iPad et sur l'émulateur Android, comme en F11, si tu le demandes.

## 4. Google Play Console

| # | Écran de la console | Action | Texte ou réponse |
| --- | --- | --- | --- |
| 4.1 | Fiche principale du Store (fr-FR) | Remplacer la description courte et la description complète, puis les 8 captures | Section 1 et section 3 |
| 4.2 | Fiche principale → « Gérer les traductions » | Ajouter `en-US` et `es-ES` : titre, descriptions, captures | Section 2 |
| 4.3 | Classification du contenu | Rouvrir le questionnaire et vérifier : réponses inchangées. Achats numériques : **Non** (les pièces se gagnent seulement en jouant). Interaction entre utilisateurs : **Non** (le duel se joue sur un seul téléphone ; le code de défi est recopié à la main) | — |
| 4.4 | Public cible et contenu | Inchangé : 6-8 et 9-12 ans | — |
| 4.5 | Sécurité des données | Inchangé : aucune donnée collectée ni partagée. L'export d'un profil est fait par l'utilisateur, sur son choix : ce n'est ni une collecte ni un partage au sens de Google | — |
| 4.6 | Annonces | Inchangé : aucune | — |
| 4.7 | Autorisations | Rien à déclarer : `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` et `VIBRATE` ne demandent pas de formulaire ; pas d'alarme exacte | — |
| 4.8 | Tests → Test interne | Créer une version avec le bundle `1.0.0+2`, notes de version de la section 1 et 2 | — |
| 4.9 | Tests → Test fermé | Si la console l'exige (compte personnel récent) : 12 testeurs pendant 14 jours avant la production | — |
| 4.10 | Production | Après le test fermé : même bundle, mêmes notes de version, pays : tous | — |

## 5. App Store Connect

| # | Écran | Action | Texte ou réponse |
| --- | --- | --- | --- |
| 5.1 | Informations de l'app → Localisations | Ajouter « English (U.S.) » et « Spanish (Spain) » (et « Spanish (Mexico) » si voulu) : nom et sous-titre | Section 2 |
| 5.2 | Version 1.0, chaque langue | Description, mots-clés, texte promotionnel, URL d'assistance (la même pour les trois langues) | Sections 1 et 2 |
| 5.3 | Version 1.0 → Captures | Remplacer les 6 captures iPhone et iPad par les 8 de la section 3 | Section 3 |
| 5.4 | Classification par âge | Rouvrir et vérifier : réponses inchangées, 4+, Made for Kids 6-8. Contrôles parentaux : Non (le contrôle parental protège seulement l'export et l'import) | — |
| 5.5 | Confidentialité de l'app | Inchangé : « Données non collectées ». Cliquer sur **Publish** | — |
| 5.6 | Informations pour la revue | Ajouter ton numéro de téléphone ; remplacer les notes | Texte ci-dessous |
| 5.7 | Build | Envoyer l'ipa `1.0.0 (2)` avec Transporter, puis la choisir dans la version | — |
| 5.8 | Envoi en revue | Seulement quand tout est prêt | — |

Notes pour la revue (App Store, en anglais) :

```
Kid Matix works fully offline: no account, no sign-in, no ads, no purchases, no network calls.
On first launch, create a player with any nickname (for example "Awa"), pick an avatar, then skip or take the optional placement test.
Coins in the shop are earned only by playing; there is no real-money purchase.
The Duel is played by two people on the same device. Challenge codes are typed by hand; nothing is sent over a network.
Exporting or importing a profile (Settings > Backup) opens the system share sheet or file picker, behind a parental gate: type in digits the number written in words (for example "three hundred forty-seven" = 347).
The optional daily reminder is a local notification; the permission is asked only when the reminder is switched on.
The app is available in English, French and Spanish.
```

## 6. Récapitulatif dans l'ordre

1. Fusionner la PR qui porte ce document et le build `1.0.0+2`.
2. Construire les builds (0.2) et prendre les captures (0.3).
3. Google Play : 4.1, 4.2, 4.3, puis 4.8 (test interne) et l'installation sur un téléphone (F11-11).
4. App Store : 5.1 à 5.6, puis 5.7 (TestFlight) et l'installation sur un iPhone (F11-11).
5. Faire relire les traductions et les textes à confirmer (`docs/status.md`).
6. Test fermé Google Play si demandé (4.9), puis production (4.10) et envoi en revue Apple (5.8).

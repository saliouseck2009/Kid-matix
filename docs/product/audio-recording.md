# Enregistrer les mots en wolof : guide du propriétaire

Pour le propriétaire. Ce guide sert à enregistrer, en wolof, l'explication et l'exemple de chaque mot du tableau `math-words.md` (quarante mots). Il est la moitié de la tâche F28-02 : la partie guide est faite, le script de traitement ne l'est pas (voir la fin du document).

## En bref

- Un fichier par mot, nommé `wo_<clé>.m4a`, par exemple `wo_il_reste.m4a`.
- Dans chaque fichier : l'explication, une courte pause, puis l'exemple.
- Deux secondes de silence avant et après.
- Une voix lente et chaleureuse, comme pour un petit enfant qui apprend.
- Environ 10 à 20 secondes par mot. Compte deux ou trois séances.

## 0. Préparer le texte

- Avant d'ouvrir l'enregistreur, remplis dans `math-words.md` le mot wolof retenu de chaque notion (section 2), puis les deux colonnes wolof de chaque mot : « Explication en wolof » et « Exemple en wolof ».
- Relis chaque texte à voix haute, une fois, sans enregistrer. Si une phrase te gêne, change-la avant.
- Enregistre ensuite le fichier du mot.

## 1. Choisir la pièce

- Une pièce fermée, avec des tissus (rideaux, tapis, vêtements) plutôt qu'une pièce vide ou carrelée : moins d'écho.
- Éteins le ventilateur, le climatiseur et la télévision. Leur bruit reste sur l'enregistrement.
- Ferme portes et fenêtres. Évite les heures où la rue est bruyante (marché, car rapide, klaxons). Le matin tôt ou le soir sont souvent plus calmes.
- Mets le téléphone en mode avion et désactive les notifications : un bip pendant un enregistrement oblige à tout refaire.
- Test : enregistre 10 secondes de silence et écoute-les au casque. Si tu entends un ronronnement, la rue ou un grésillement, change de pièce ou d'heure.

## 2. Placer le téléphone ou le micro

- Téléphone à environ 20 centimètres de la bouche, un peu sur le côté et pas droit devant : on évite le souffle des « p » et des « f ».
- Pose le téléphone sur un coussin ou un livre, sur une surface qui ne vibre pas. Ne le tiens pas pendant l'enregistrement.
- Un micro-cravate ou un micro branché au téléphone donne un son plus net. Si tu en as un, utilise-le.
- Garde la même pièce, le même téléphone et la même distance du début à la fin, et à chaque séance, pour que tous les fichiers sonnent pareil.
- Format : prends M4A (AAC) si l'enregistreur le propose. Si le fichier n'est pas en `.m4a`, garde son extension (par exemple `wo_il_reste.mp3`) ; ne change jamais l'extension à la main, le script convertira.

## 3. Un fichier par mot, et son nom

- Un mot, un fichier. Ne mets jamais deux mots dans un même fichier, et ne coupe pas un mot en plusieurs fichiers.
- Le nom vient de la colonne « Clé » du tableau : `wo_<clé>.m4a`. La colonne « Fichier audio » donne le nom exact (pour l'extension, voir la section 2).
- Exemples : `wo_il_reste.m4a`, `wo_de_plus_que.m4a`, `wo_a_la_fin.m4a`.
- En minuscules, sans accent, sans espace, sans majuscule. Les `_` restent : `wo_de_plus_que.m4a`, pas `wo-de-plus-que.m4a` ni `Wo de plus que.m4a`.
- Renomme le fichier tout de suite après l'enregistrement, pour ne pas le mélanger avec les autres.

## 4. Le ton

- Lent : un peu plus lentement que dans une conversation. Un enfant de 6 ans doit pouvoir suivre du premier coup.
- Chaleureux : parle comme à un enfant qu'on aime, avec le sourire dans la voix.
- Clair : prononce chaque mot en entier, sans avaler la fin des phrases.
- Constant : même volume et même ton d'un fichier à l'autre.
- Pas de musique, pas de chant, pas de bruit de fond.
- Si tu te trompes, arrête, supprime l'essai raté, puis recommence tout le fichier depuis le début. Le script ne coupe pas les erreurs au milieu d'un fichier.

## 5. Le silence : deux secondes avant et après

- Lance l'enregistrement, compte lentement jusqu'à trois, puis commence à parler.
- Après la dernière phrase, compte lentement jusqu'à trois, puis arrête.
- Ces deux secondes donnent au script une marge sûre pour couper le début et la fin sans toucher à ta voix.

## 6. Ce qu'on enregistre : l'explication, puis l'exemple

Pour chaque mot, dans le même fichier, dans cet ordre :

1. **L'explication** (colonne « Explication en wolof ») : ce que veut dire le mot, en une ou deux phrases simples, comme à un enfant.
2. **Une pause** d'environ une seconde.
3. **L'exemple** (colonne « Exemple en wolof ») : une courte situation du quotidien.

Le mot français n'est pas enregistré : l'app le fait lire par la voix du téléphone. Vise 10 à 20 secondes par fichier. Au-delà de 30 secondes, raccourcis l'explication.

## 7. Vérifier chaque fichier

Avant de livrer, écoute chaque fichier au casque, dans l'ordre du tableau :

- [ ] Le fichier commence et finit par du silence, sans bruit de rue, de voix ou de téléphone.
- [ ] La voix est claire, sans souffle ni coupure au milieu.
- [ ] Le volume ne baisse pas au cours du fichier.
- [ ] L'explication puis l'exemple sont là, avec une pause entre les deux.
- [ ] Le contenu correspond à la ligne du tableau (le bon mot, le bon exemple).
- [ ] Le nom est exactement `wo_<clé>.m4a`.
- [ ] La durée reste entre 10 et 20 secondes environ, 30 au plus.

## 8. Livrer les fichiers

- Mets les fichiers dans un seul dossier, sans les renommer ni les convertir.
- Envoie-les par un lien de partage (Google Drive, par exemple), par e-mail ou sur une clé USB.
- Évite les messages vocaux WhatsApp : l'application recode le son et peut en altérer la qualité. Si tu passes par WhatsApp, envoie les fichiers comme documents.
- Dans le message, indique quels mots sont prêts et lesquels manquent.
- Lieu de dépôt à confirmer avec le développeur (point à valider).

## 9. Ce qui se passe ensuite

Après la livraison, tu n'as rien d'autre à faire. Le script de traitement (à venir) prépare les fichiers pour l'app. Un mot sans fichier audio n'affiche simplement pas le bouton « Écouter en wolof » : l'app continue de fonctionner.

## 10. Script de traitement (à venir, F28-02)

Cette partie n'est pas encore écrite. Elle sera ajoutée par un agent de code, dans `tool/`, avec la suite de F28-02. Le script devra :

- couper les silences au début et à la fin, en gardant une marge ;
- égaliser le volume entre les fichiers ;
- convertir chaque fichier en un format mono compressé ;
- vérifier que chaque mot du tableau a son fichier `wo_<clé>.m4a`, et signaler les fichiers manquants.

Le format de sortie et le dossier de destination dans l'app (probablement `assets/audio/wo/`, à confirmer avec F28-03) restent à valider. Le propriétaire ne lance rien : le développeur traitera les fichiers reçus.

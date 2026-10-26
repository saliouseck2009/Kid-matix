# Problèmes : tableau de contenu

Statut : brouillon. Ce document est le tableau de contenu du lot F30 (tâche F30-01). Il prépare les gabarits (F30-02), le schéma en barres (F30-03), la résolution guidée (F30-04), les mots touchables (F30-05), les pièges du mot-clé (F30-06) et le parcours (F30-07). Les énoncés, les nombres et les pièges sont à valider par le propriétaire ; les énoncés en wolof et leurs audios restent à enregistrer.

Wolof provisoire : les colonnes en wolof sont un texte provisoire, traduit par une machine (Meta NLLB-200 ou Google Translate) et non relu ; chaque cellule porte la mention « (machine, à relire) » ou « (Google, à relire) ». Les voix sont une synthèse automatique (Meta MMS) à remplacer par de vrais enregistrements (voir `tool/placeholder_audio/README.md` et `docs/product/audio-recording.md`).

**Les clés ne changent jamais une fois publiées.** Une clé est l'identifiant d'un problème dans l'app (`problem:<clé>`) et donne le nom de son audio (`wo_problem_<clé>.m4a`). Une nouvelle situation reçoit une nouvelle clé ; une clé retirée reste réservée.

Trente problèmes : dix par niveau. Chaque problème a une ligne dans le tableau « Énoncé et schéma » de son niveau et une ligne dans le tableau « Gabarit » du même niveau, reliées par la clé.

## Comment lire les tableaux

- **Niveau 1** : avec images. Une phrase courte qu'un enfant qui lit mal suit avec un dessin. Tous les nombres et tous les résultats sont inférieurs ou égaux à 20. Chaque problème a une idée d'image, décrite à partir des nombres du gabarit, sans aucun texte dans le dessin et sans le résultat.
- **Niveau 2** : une phrase courte. Nombres et résultats inférieurs ou égaux à 50.
- **Niveau 3** : énoncé complet. Nombres et résultats inférieurs ou égaux à 100. Les sommes d'argent sont en francs CFA, par multiples de 25, et restent inférieures ou égales à 100 francs.
- **Clé** : lettres minuscules, sans accent, mots reliés par `_`.
- **Opération** : `+`, `−`, `×` ou `÷`. C'est l'opération attendue, celle du calcul.
- **Situation** : une des situations du glossaire de F28 : réunir, retirer, comparer, groupes égaux ou partage. Elle décrit l'histoire, jamais un mot.
- **Forme** : la forme du schéma en barres, en code : `reunir`, `retirer`, `comparer`, `groupes`, `groupement` ou `partage` (vocabulaire en fin de document).
- **Tout, Parties, Cherché** : les nombres connus du schéma et ce qu'il faut trouver, avec les nombres de l'enregistrement. Une valeur cherchée n'est jamais donnée.
- **Calcul** : le calcul qui donne la réponse, avec les nombres de l'enregistrement.
- **Énoncé** : la phrase française enregistrée en wolof (F30-05). Les nombres sont fixes.
- **Wolof : énoncé** : vide. Le propriétaire le remplit ; le rédacteur n'écrit aucun wolof.
- **Audio** : le nom attendu du fichier, fixé par la clé.
- **Gabarit** : la même phrase avec des nombres tirés au sort, `{a}`, `{b}` et `{r}` (F30-02). Quand le gabarit et l'énoncé fixe diffèrent d'une valeur, c'est que le gabarit a été écrit pour la forme ; l'énoncé fixe reste la référence.
- **Rôles** : ce que désigne chaque placeholder dans le schéma, par exemple `tout=a ; partie=b ; reste=r`. Les noms de rôles sont fixes pour chaque forme (voir le vocabulaire en fin de document) ; la ligne indique seulement quel placeholder tient quel rôle.
- **Plages** : l'ordre de tirage et les contraintes, dans la grammaire décrite en fin de document. Le tirage se fait de gauche à droite.
- **Mots des maths** : les clés `word:` de F28 présentes dans la phrase. Un mot est touchable quand son mot ou sa forme (colonnes « Mot ou expression » et « Forme dans l'exemple » de F28) apparaît dans l'énoncé. Cette colonne est une vérification : elle doit correspondre aux occurrences de la phrase.
- **Vérification** : la phrase de la dernière étape guidée (F30-04). Elle reprend les nombres du gabarit.
- **Piège ou jumeau** : « Piège » décrit le mot qui induit en erreur et l'opération réelle ; « Jumeau » donne le problème sans piège, avec les mêmes nombres ou le même schéma. Cette colonne sert au développeur et à la relecture, jamais à l'enfant.

Aucun énoncé ne dit qu'un mot donne une opération : l'enfant lit l'histoire, il ne retient pas une règle. Un mot-clé est parfois trompeur, et le schéma aide à voir la situation.

## Niveau 1 · avec images

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees` | 1 | − | retirer | `retirer` | 12 | 5 (donnés) et ? | la partie qui reste | 12 − 5 = 7 | Awa a 12 mangues. Elle en donne 5 à sa petite sœur. Combien de mangues lui reste-t-il ? | Awa am na fukk ak ñaar ay mangal. Mu jox ay juróomi ay mangal ci sa jigéen ju ndaw. Ñaata mangal la am? (machine, à relire) | `wo_problem_mangues_donnees.m4a` |
| `mangues_donnees_piege` | 1 | + | retirer | `retirer` | ? (Awa) | 5 (donnés) et 7 (restants) | le tout, au départ | 7 + 5 = 12 | Awa donne 5 mangues à sa petite sœur. Il lui en reste 7. Combien de mangues avait-elle au départ ? | Awa jox na ndaw ya juróom-ñaari mango, ba noppi am na juróom-ñaari. (machine, à relire) | `wo_problem_mangues_donnees_piege.m4a` |
| `billes_recues` | 1 | + | réunir | `reunir` | ? | 6 et 4 | le tout | 6 + 4 = 10 | Mamadou a 6 billes. Il reçoit 4 billes de son ami. Combien de billes a-t-il maintenant ? | Mamadou am na juróom ñaari ball. Mu jot na ñeenti ball ci xaritam. Ñaata ball la am léegi? (machine, à relire) | `wo_problem_billes_recues.m4a` |
| `mangues_caisses` | 1 | × | groupes égaux | `groupes` | ? | 3 groupes de 5 | le total | 3 × 5 = 15 | Au marché, Fatou a 3 caisses. Dans chaque caisse, il y a 5 mangues. Combien de mangues a-t-elle ? | Fatou am na ñetti caatu ci xarnu bi. Ci benn caatu bi am na juróomi mango. Ñaata mango la am? (machine, à relire) | `wo_problem_mangues_caisses.m4a` |
| `mangues_partagees` | 1 | ÷ | partage | `partage` | 12 | 3 parts égales | une part | 12 ÷ 3 = 4 | Fatou a 12 mangues. Elle les partage également entre 3 amis. Combien de mangues reçoit chacun ? | Fatou am na fukki mango, di leen di séddoo ak ñetti xarit. (machine, à relire) | `wo_problem_mangues_partagees.m4a` |
| `chaises_tabaski` | 1 | ÷ | partage | `partage` | 10 | 2 rangées égales | une rangée | 10 ÷ 2 = 5 | Pour la Tabaski, Awa a 10 chaises. Elle les range en 2 rangées égales. Combien de chaises y a-t-il dans chaque rangée ? | Ci Tabaski Awa am na fukki gànnaaw, di leen teg ci ñaari xët yu mel ni ñoom. (machine, à relire) | `wo_problem_chaises_tabaski.m4a` |
| `car_personnes` | 1 | − | retirer | `retirer` | 9 | 4 (descendues) et ? | la partie qui reste | 9 − 4 = 5 | Dans le car rapide, il y a 9 personnes. 4 personnes descendent. Il reste combien de personnes ? | Ci otobus bi, amoon na ñetti nit, ñeenti nit ñu wàcc. Ñaata nit ñu sax? (machine, à relire) | `wo_problem_car_personnes.m4a` |
| `sucre_theieres` | 1 | ÷ | partage | `partage` | 8 | 2 parts égales | une part | 8 ÷ 2 = 4 | Mamadou a 8 morceaux de sucre. Il les répartit dans 2 théières, le même nombre dans chaque. Combien de morceaux y a-t-il dans chaque théière ? | Mamadou am na juróom-ñetti xarnu sukari. Mu di leen séddale ci ñaari xërëm, ñu mel ni ñoom. Ñaata xarnu xaalis la nekk? (machine, à relire) | `wo_problem_sucre_theieres.m4a` |
| `biscuits_en_tout_piege` | 1 | × | groupes égaux | `groupes` | ? | 5 groupes de 3 | le total | 5 × 3 = 15 | Aminata achète 5 paquets de 3 biscuits. Combien de biscuits a-t-elle en tout ? | Aminata di jënd juróomi pakk yu ñetti biskuit. Ñaata biskuit la am? (machine, à relire) | `wo_problem_biscuits_en_tout_piege.m4a` |
| `pains_vendus` | 1 | − | retirer | `retirer` | 10 | 4 (vendus) et ? | la partie qui reste | 10 − 4 = 6 | Aminata a 10 pains. Elle en vend 4 au marché. Combien de pains lui reste-t-il ? | Aminata am na fukki mburu. Am na ñeenti mburu ci xaalis bi. (machine, à relire) | `wo_problem_pains_vendus.m4a` |

### Gabarit

| Clé | Gabarit | Rôles | Plages | Mots des maths | Vérification | Piège ou jumeau | Idée d'image |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees` | Awa a {a} mangues. Elle en donne {b} à sa petite sœur. Combien de mangues lui reste-t-il ? | `tout=a ; partie=b ; reste=r` | `a ∈ [6, 20] ; b ∈ [2, a − 2] ; r = a − b` | `word:donner`, `word:il_reste`, `word:combien` | Vérifie : {b} + {r} = {a}, c'est bien le nombre de mangues d'Awa. | Jumeau du piège `mangues_donnees_piege` : même tout (12), mêmes parties (5 et 7). | Un panier avec {a} mangues dessinées ; {b} mangues sortent du panier vers une petite fille. |
| `mangues_donnees_piege` | Awa donne {b} mangues à sa petite sœur. Il lui en reste {a}. Combien de mangues avait-elle au départ ? | `tout=r ; partie=b ; reste=a` | `a ∈ [2, 18] ; b ∈ [2, 20 − a] ; r = a + b` | `word:donner`, `word:il_reste`, `word:au_depart`, `word:combien` | Vérifie : {a} + {b} = {r}, c'est bien le nombre de mangues d'Awa au départ. | Piège : « donne » fait penser à retirer ; ici il faut retrouver le tout, donc 7 + 5. Jumeau : `mangues_donnees` (mêmes nombres, 12, 5 et 7). | Un panier dessiné en pointillés, sans mangues visibles ; {b} mangues sortent vers une petite fille ; le panier qui reste contient {a} mangues dessinées. |
| `billes_recues` | Mamadou a {a} billes. Il reçoit {b} billes de son ami. Combien de billes a-t-il maintenant ? | `tout=r ; partie1=a ; partie2=b` | `a ∈ [2, 10] ; b ∈ [2, 10] ; r = a + b` | `word:recevoir`, `word:combien` | Vérifie : {a} + {b} = {r}, Mamadou a plus de billes qu'avant. | — | Un garçon avec {a} billes dessinées ; un autre garçon tend {b} billes vers lui. |
| `mangues_caisses` | Au marché, Fatou a {a} caisses. Dans chaque caisse, il y a {b} mangues. Combien de mangues a-t-elle ? | `groupes=a ; taille=b ; tout=r` | `a ∈ [2, 5] ; b ∈ [2, 5] ; r = a × b ≤ 20` | `word:dans_chaque`, `word:combien` | Vérifie : {a} × {b} = {r}, c'est bien le nombre de mangues de Fatou. | Jumeau du piège `biscuits_en_tout_piege`. | {a} caisses ouvertes, chacune avec {b} mangues dessinées. |
| `mangues_partagees` | Fatou a {a} mangues. Elle les partage également entre {b} amis. Combien de mangues reçoit chacun ? | `tout=a ; parts=b ; part=r` | `b ∈ [2, 5] ; r ∈ [2, 5] ; a = b × r ≤ 20` | `word:partager_egalement`, `word:chacun`, `word:combien`, `word:recevoir` | Vérifie : {b} × {r} = {a}, chaque ami a bien {r} mangues. | — | Un grand plat avec {a} mangues dessinées ; à côté, {b} assiettes vides de même taille. |
| `chaises_tabaski` | Pour la Tabaski, Awa a {a} chaises. Elle les range en {b} rangées égales. Combien de chaises y a-t-il dans chaque rangée ? | `tout=a ; parts=b ; part=r` | `b ∈ [2, 4] ; r ∈ [2, 5] ; a = b × r ≤ 20` | `word:rangee`, `word:dans_chaque`, `word:combien` | Vérifie : {b} × {r} = {a}, il y a bien {a} chaises. | — | {a} chaises dessinées, réparties en {b} lignes de même longueur. |
| `car_personnes` | Dans le car rapide, il y a {a} personnes. {b} personnes descendent. Il reste combien de personnes ? | `tout=a ; partie=b ; reste=r` | `a ∈ [5, 20] ; b ∈ [1, a − 1] ; r = a − b` | `word:il_reste`, `word:combien` | Vérifie : {b} + {r} = {a} personnes. | — | Un car rapide vu de côté, avec {a} personnes dessinées dedans ; {b} personnes près de la porte, qui sortent. |
| `sucre_theieres` | Mamadou a {a} morceaux de sucre. Il les répartit dans {b} théières, le même nombre dans chaque. Combien de morceaux y a-t-il dans chaque théière ? | `tout=a ; parts=b ; part=r` | `b ∈ [2, 4] ; r ∈ [2, 5] ; a = b × r ≤ 20` | `word:repartir`, `word:dans_chaque`, `word:combien` | Vérifie : {b} × {r} = {a} morceaux. | — | {a} morceaux de sucre dessinés ; {b} théières vides, côte à côte. |
| `biscuits_en_tout_piege` | Aminata achète {a} paquets de {b} biscuits. Combien de biscuits a-t-elle en tout ? | `groupes=a ; taille=b ; tout=r` | `a ∈ [2, 5] ; b ∈ [2, 5] ; r = a × b ≤ 20` | `word:en_tout`, `word:acheter`, `word:combien` | Vérifie : {a} × {b} = {r} biscuits. | Piège : « en tout » fait penser à réunir ; ici les paquets ont la même taille, donc 5 × 3. Jumeau : `mangues_caisses`. | {a} petits paquets, chacun avec {b} biscuits dessinés. |
| `pains_vendus` | Aminata a {a} pains. Elle en vend {b} au marché. Combien de pains lui reste-t-il ? | `tout=a ; partie=b ; reste=r` | `a ∈ [5, 20] ; b ∈ [1, a − 1] ; r = a − b` | `word:vendre`, `word:il_reste`, `word:combien` | Vérifie : {b} + {r} = {a} pains. | — | Une vendeuse avec {a} pains dessinés sur la table ; {b} pains partent vers une cliente. |

Note : `billes_recues` n'a pas de jumeau ; c'est un problème réunir ordinaire.

## Niveau 2 · phrase courte

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `billes_chacun_piege` | 2 | × | groupes égaux | `groupes` | ? | 4 groupes de 6 | le total | 4 × 6 = 24 | Chacun des 4 enfants reçoit 6 billes. Combien de billes faut-il ? | Ñi nekk ci ñeenti xale yi, am na juróom-ñeen fànn. Ñaat fànn lañu war? (machine, à relire) | `wo_problem_billes_chacun_piege.m4a` |
| `billes_sacs` | 2 | × | groupes égaux | `groupes` | ? | 4 groupes de 6 | le total | 4 × 6 = 24 | Il y a 4 sacs. Dans chaque sac, il y a 6 billes. Combien de billes y a-t-il ? | Am na ñeenti sàrt, ci benn sàrt am na juróom-ñeen ball. (machine, à relire) | `wo_problem_billes_sacs.m4a` |
| `tas_fois_piege` | 2 | ÷ | partage | `groupement` | 24 | tas de 3 | le nombre de tas | 24 ÷ 3 = 8 | Awa a 24 billes. Combien de fois peut-elle faire un tas de 3 billes ? | Awa am na ñaar fukk ak ñeent bala. (machine, à relire) | `wo_problem_tas_fois_piege.m4a` |
| `billes_tas` | 2 | ÷ | partage | `groupement` | 24 | tas de 3 | le nombre de tas | 24 ÷ 3 = 8 | Awa a 24 billes. Elle fait des tas de 3 billes. Combien de tas peut-elle faire ? | Awa am na ñaar fukk ak ñeent fànn. Mu def na ñetti fànn. Ñaata fànn mu mën a def? (machine, à relire) | `wo_problem_billes_tas.m4a` |
| `moussa_paniers` | 2 | + | réunir | `reunir` | ? | 18 et 15 | le total | 18 + 15 = 33 | Moussa met ensemble ses 18 et ses 15 mangues dans un grand panier. Combien de mangues y a-t-il dans le grand panier ? | Musaa dajale juróom-ñaari fukk ak juroom-ñett yi ci benn sàq. Lu ëpp màngoon ca benn sàqa? (machine, à relire) | `wo_problem_moussa_paniers.m4a` |
| `fatou_sachets` | 2 | − | retirer | `retirer` | 36 | 14 (vendus) et ? | la partie qui reste | 36 − 14 = 22 | Fatou a 36 sachets d'eau. Elle en vend 14 au marché. Combien lui en reste-t-il ? | Fatou am na ñetti fukk ak juróom-ñett ak juroom-ñett ak juroom-ñett ci ndox. (machine, à relire) | `wo_problem_fatou_sachets.m4a` |
| `billes_difference` | 2 | − | comparer | `comparer` | 8 (Ibrahima) | 5 (Mamadou) et ? (écart) | l'écart | 8 − 5 = 3 | Mamadou a 5 billes. Ibrahima en a 8. Quelle est la différence entre leurs billes ? | Mamadou am na juróomi xumb, Ibrahima am na ñetti xumb. (machine, à relire) | `wo_problem_billes_difference.m4a` |
| `biscuits_range` | 2 | ÷ | partage | `partage` | 48 | 6 parts égales | une part | 48 ÷ 6 = 8 | Aminata a 48 biscuits. Elle les range en 6 paquets égaux. Combien de biscuits y a-t-il dans chaque paquet ? | Aminata am na ñeent fukk ak juróom-ñeen biskuit. Mu sàkk leen ci ñetti xëtu yu mel noonu. Ñaari biskuyt la nekk ca benn xëttu? (machine, à relire) | `wo_problem_biscuits_range.m4a` |
| `mamadou_gagne` | 2 | + | réunir | `reunir` | ? | 30 (au départ) et 12 (gagnées) | le total à la fin | 30 + 12 = 42 | Au départ, Mamadou a 30 billes. Il joue et gagne 12 billes. Après le jeu, combien en a-t-il ? | Ci njàlbéen bi, Mamadou am na 30 ball. Mu xeex te am na 12 ball. Bi xeex ba noppi, meloon la am? (machine, à relire) | `wo_problem_mamadou_gagne.m4a` |
| `billes_mamadou_moins_piege` | 2 | + | comparer | `comparer` | ? (Ibrahima) | 5 (Mamadou) et 3 (écart) | Ibrahima | 5 + 3 = 8 | Mamadou a 5 billes. Il en a 3 de moins que son ami Ibrahima. Combien de billes a Ibrahima ? | Mamadou am na juróomi xànk. Am na ñetti xànk yu néew ni sa xarit Ibraayma. (machine, à relire) | `wo_problem_billes_mamadou_moins_piege.m4a` |

### Gabarit

| Clé | Gabarit | Rôles | Plages | Mots des maths | Vérification | Piège ou jumeau |
| --- | --- | --- | --- | --- | --- | --- |
| `billes_chacun_piege` | Chacun des {a} enfants reçoit {b} billes. Combien de billes faut-il ? | `groupes=a ; taille=b ; tout=r` | `a ∈ [2, 9] ; b ∈ [2, 9] ; r = a × b ≤ 50` | `word:chacun`, `word:recevoir`, `word:combien` | Vérifie : {a} × {b} = {r} billes. | Piège : « chacun » fait penser à partager ; ici chaque enfant reçoit la même quantité, donc 4 × 6. Jumeau : `billes_sacs`. |
| `billes_sacs` | Il y a {a} sacs. Dans chaque sac, il y a {b} billes. Combien de billes y a-t-il ? | `groupes=a ; taille=b ; tout=r` | `a ∈ [2, 9] ; b ∈ [2, 9] ; r = a × b ≤ 50` | `word:dans_chaque`, `word:combien` | Vérifie : {a} × {b} = {r} billes. | Jumeau du piège `billes_chacun_piege`. |
| `tas_fois_piege` | Awa a {a} billes. Combien de fois peut-elle faire un tas de {b} billes ? | `tout=a ; taille=b ; groupes=r` | `b ∈ [2, 5] ; r ∈ [2, 9] ; a = b × r ≤ 50` | `word:combien_de_fois` | Vérifie : {b} × {r} = {a} billes. | Piège : « combien de fois » fait penser à multiplier ; ici on cherche combien de tas de 3 on peut faire avec 24 billes, donc 24 ÷ 3. Jumeau : `billes_tas`. |
| `billes_tas` | Awa a {a} billes. Elle fait des tas de {b} billes. Combien de tas peut-elle faire ? | `tout=a ; taille=b ; groupes=r` | `b ∈ [2, 5] ; r ∈ [2, 9] ; a = b × r ≤ 50` | `word:combien` | Vérifie : {b} × {r} = {a} billes. | Jumeau du piège `tas_fois_piege`. |
| `moussa_paniers` | Moussa met ensemble ses {a} et ses {b} mangues dans un grand panier. Combien de mangues y a-t-il dans le grand panier ? | `tout=r ; partie1=a ; partie2=b` | `a ∈ [5, 30] ; b ∈ [5, 30] ; r = a + b ≤ 50` | `word:ensemble`, `word:combien` | Vérifie : {a} + {b} = {r} mangues. | — |
| `fatou_sachets` | Fatou a {a} sachets d'eau. Elle en vend {b} au marché. Combien lui en reste-t-il ? | `tout=a ; partie=b ; reste=r` | `a ∈ [10, 50] ; b ∈ [1, a − 2] ; r = a − b` | `word:vendre`, `word:il_reste`, `word:combien` | Vérifie : {b} + {r} = {a} sachets. | — |
| `billes_difference` | Mamadou a {b} billes. Ibrahima en a {a}. Quelle est la différence entre leurs billes ? | `grand=a ; petit=b ; ecart=r` | `a ∈ [5, 30] ; b ∈ [1, a − 1] ; r = a − b` | `word:difference` | Vérifie : {b} + {r} = {a} billes. | Jumeau du piège `billes_mamadou_moins_piege`. |
| `biscuits_range` | Aminata a {a} biscuits. Elle les range en {b} paquets égaux. Combien de biscuits y a-t-il dans chaque paquet ? | `tout=a ; parts=b ; part=r` | `b ∈ [2, 6] ; r ∈ [2, 9] ; a = b × r ≤ 50` | `word:egal`, `word:dans_chaque`, `word:combien` | Vérifie : {b} × {r} = {a} biscuits. | — |
| `mamadou_gagne` | Au départ, Mamadou a {a} billes. Il joue et gagne {b} billes. Après le jeu, combien en a-t-il ? | `tout=r ; partie1=a ; partie2=b` | `a ∈ [5, 30] ; b ∈ [2, 20] ; r = a + b ≤ 50` | `word:au_depart`, `word:gagner`, `word:apres`, `word:combien` | Vérifie : {a} + {b} = {r} billes. | — |
| `billes_mamadou_moins_piege` | Mamadou a {a} billes. Il en a {b} de moins que son ami Ibrahima. Combien de billes a Ibrahima ? | `petit=a ; ecart=b ; grand=r` | `a ∈ [2, 40] ; b ∈ [1, 10] ; r = a + b ≤ 50` | `word:de_moins_que`, `word:combien` | Vérifie : {a} + {b} = {r}, Ibrahima a bien {r} billes. | Piège : « de moins que » fait penser à retirer ; ici Ibrahima a la plus grande quantité, il faut ajouter : 5 + 3. Jumeau : `billes_difference`. |

## Niveau 3 · énoncé complet

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_de_plus_que_piege` | 3 | − | comparer | `comparer` | 84 (Awa) | ? (Moussa) et 45 (écart) | Moussa | 84 − 45 = 39 | Awa a 84 mangues. Elle en a 45 de plus que Moussa. Combien de mangues a Moussa ? | Awa am na ñeent fukk ak ñeent. Mu am na ñeent fukk ak juróomi lu ëpp Musaa. Ñaata fukk Moussa am na? (machine, à relire) | `wo_problem_mangues_de_plus_que_piege.m4a` |
| `mangues_difference` | 3 | − | comparer | `comparer` | 84 (Awa) | 39 (Moussa) et ? (écart) | l'écart | 84 − 39 = 45 | Awa a 84 mangues. Moussa en a 39. Quelle est la différence entre leurs mangues ? | Awa am na ñeent fukk ak juróom ñett, Musaa am na fukk ak juróom ñett. Lii mooy li ëpp ci ñoom? (machine, à relire) | `wo_problem_mangues_difference.m4a` |
| `biscuits_partages_piege` | 3 | × | groupes égaux | `groupes` | ? | 4 paquets de 12 | le total | 4 × 12 = 48 | Moussa a 4 paquets de 12 biscuits. Il veut les partager avec ses amis. Combien de biscuits a-t-il à partager ? | Moussa am na ñeenti pakk yu tollu biskuit yu mu bëgg a séddoo ak ay xaritam. Ñaata biskuit la mu am? (machine, à relire) | `wo_problem_biscuits_partages_piege.m4a` |
| `biscuits_paquets` | 3 | × | groupes égaux | `groupes` | ? | 4 paquets de 12 | le total | 4 × 12 = 48 | Au marché, Moussa achète des biscuits par paquets de 12. Il prend 4 paquets. Combien de biscuits a-t-il ? | Ci suulet bi, Moussa di jënd biskuit yi ci 12 paket. (machine, à relire) | `wo_problem_biscuits_paquets.m4a` |
| `mangues_deux_fois_plus` | 3 | × | groupes égaux | `comparer` | ? (Fatou) | 2 groupes de 25 (Aminata) | Fatou | 25 × 2 = 50 | Aminata a 25 mangues. Fatou en a 2 fois plus. Combien de mangues Fatou a-t-elle ? | Aminata am na ñaar fukk ak juróomi mango. Fatou am na ñaari yoon. Fatou am na ñaat mango? (machine, à relire) | `wo_problem_mangues_deux_fois_plus.m4a` |
| `mangues_moitie_piege` | 3 | × | groupes égaux | `comparer` | ? (Fatou) | 2 groupes de 25 (Aminata) | Fatou | 25 × 2 = 50 | Aminata a 25 mangues. Elle a la moitié des mangues de Fatou. Combien de mangues Fatou a-t-elle ? | Aminata am na ñaar fukk ak juróom mangue. Fatou am na genn-wàllu mangue yi. Fatou am na ñakk mangue. (machine, à relire) | `wo_problem_mangues_moitie_piege.m4a` |
| `achat_sachet_eau` | 3 | − | retirer | `retirer` | 100 francs | 25 francs (achat) et ? | la somme qui reste | 100 − 25 = 75 | Au départ, Ibrahima a 100 francs. Il achète un sachet d'eau à 25 francs. Combien d'argent lui reste-t-il à la fin ? | Ibraayma am na benn frank ci njàlbéen bi. Jëfandikoo ko ci njëkk ndox ci ñaar fukk ak juróom frank. (machine, à relire) | `wo_problem_achat_sachet_eau.m4a` |
| `awa_marche_francs` | 3 | + | réunir | `reunir` | ? | 50 francs et 25 francs | le total | 50 + 25 = 75 | Awa achète des mangues à 50 francs et du thé à 25 francs. Quel est le total ? | Awa di jënd mango ci 50 francs ak té ci 25 francs. (machine, à relire) | `wo_problem_awa_marche_francs.m4a` |
| `rangees_tabaski` | 3 | ÷ | partage | `partage` | 48 | 6 rangées égales | une rangée | 48 ÷ 6 = 8 | Pour la Tabaski, on met 48 chaises en 6 rangées égales dans la cour. Combien de chaises y a-t-il dans chaque rangée ? | Ci Tabaski, dañu sàkk ñeent fukk ak juróom-ñaari gànnaaw ci juróom-ñaari gànnaaw yu mel ni gànnaaw. (machine, à relire) | `wo_problem_rangees_tabaski.m4a` |
| `awa_moussa_plus` | 3 | + | comparer | `comparer` | ? (Awa) | 25 (Moussa) et 75 (écart) | Awa | 25 + 75 = 100 | Moussa a 25 francs. Awa en a 75 de plus que lui. Combien de francs Awa a-t-elle ? | Moussa am na 25 francs. Awa am na 75 francs yu ëpp. (machine, à relire) | `wo_problem_awa_moussa_plus.m4a` |

### Gabarit

| Clé | Gabarit | Rôles | Plages | Mots des maths | Vérification | Piège ou jumeau |
| --- | --- | --- | --- | --- | --- | --- |
| `mangues_de_plus_que_piege` | Awa a {a} mangues. Elle en a {b} de plus que Moussa. Combien de mangues a Moussa ? | `grand=a ; ecart=b ; petit=r` | `a ∈ [20, 100] ; b ∈ [5, a − 5] ; r = a − b` | `word:de_plus_que`, `word:combien` | Vérifie : {r} + {b} = {a}, Awa a bien {a} mangues. | Piège : « de plus que » fait penser à réunir ; ici Awa a la plus grande quantité, il faut retirer l'écart : 84 − 45. Jumeau : `mangues_difference`. |
| `mangues_difference` | Awa a {a} mangues. Moussa en a {b}. Quelle est la différence entre leurs mangues ? | `grand=a ; petit=b ; ecart=r` | `a ∈ [20, 100] ; b ∈ [5, a − 5] ; r = a − b` | `word:difference` | Vérifie : {b} + {r} = {a} mangues. | Jumeau du piège `mangues_de_plus_que_piege`. |
| `biscuits_partages_piege` | Moussa a {a} paquets de {b} biscuits. Il veut les partager avec ses amis. Combien de biscuits a-t-il à partager ? | `groupes=a ; taille=b ; tout=r` | `a ∈ [2, 9] ; b ∈ [2, 12] ; r = a × b ≤ 100` | `word:partager`, `word:combien` | Vérifie : {a} × {b} = {r} biscuits. | Piège : « partager » fait penser à diviser ; ici les paquets ne sont pas coupés, on a 4 groupes de 12, donc 4 × 12. Jumeau : `biscuits_paquets`. |
| `biscuits_paquets` | Au marché, Moussa achète des biscuits par paquets de {b}. Il prend {a} paquets. Combien de biscuits a-t-il ? | `groupes=a ; taille=b ; tout=r` | `a ∈ [2, 9] ; b ∈ [2, 12] ; r = a × b ≤ 100` | `word:par_paquets_de`, `word:acheter`, `word:combien` | Vérifie : {a} × {b} = {r} biscuits. | Jumeau du piège `biscuits_partages_piege`. |
| `mangues_deux_fois_plus` | Aminata a {a} mangues. Fatou en a {b} fois plus. Combien de mangues Fatou a-t-elle ? | `grand=r ; petit=a ; fois=b` | `b ∈ [2, 4] ; a ∈ [5, 50] ; r = a × b ≤ 100` | `word:fois`, `word:combien` | Vérifie : {a} × {b} = {r} mangues. | Jumeau du piège `mangues_moitie_piege`. |
| `mangues_moitie_piege` | Aminata a {a} mangues. Elle a la moitié des mangues de Fatou. Combien de mangues Fatou a-t-elle ? | `grand=r ; petit=a ; fois=2` | `a ∈ [5, 50] ; r = 2 × a ≤ 100` | `word:moitie`, `word:combien` | Vérifie : {r} ÷ 2 = {a}, Aminata a bien la moitié. | Piège : « la moitié » fait penser à diviser ; ici Aminata a la moitié, donc Fatou a deux fois plus : 25 × 2. Jumeau : `mangues_deux_fois_plus`. |
| `achat_sachet_eau` | Au départ, Ibrahima a {a} francs. Il achète un sachet d'eau à {b} francs. Combien d'argent lui reste-t-il à la fin ? | `tout=a ; partie=b ; reste=r` | `a ∈ {50, 75, 100} ; b ∈ {25, 50} ; b < a ; r = a − b` | `word:au_depart`, `word:acheter`, `word:il_reste`, `word:a_la_fin`, `word:combien` | Vérifie : {b} + {r} = {a} francs. | — |
| `awa_marche_francs` | Awa achète des mangues à {a} francs et du thé à {b} francs. Quel est le total ? | `tout=r ; partie1=a ; partie2=b` | `a ∈ {25, 50, 75} ; b ∈ {25, 50, 75} ; r = a + b ≤ 100` | `word:acheter`, `word:total` | Vérifie : {a} + {b} = {r} francs. | — |
| `rangees_tabaski` | Pour la Tabaski, on met {a} chaises en {b} rangées égales dans la cour. Combien de chaises y a-t-il dans chaque rangée ? | `tout=a ; parts=b ; part=r` | `b ∈ [2, 10] ; r ∈ [2, 9] ; a = b × r ≤ 100` | `word:rangee`, `word:dans_chaque`, `word:combien` | Vérifie : {b} × {r} = {a} chaises. | — |
| `awa_moussa_plus` | Moussa a {a} francs. Awa en a {b} de plus que lui. Combien de francs Awa a-t-elle ? | `grand=r ; petit=a ; ecart=b` | `a ∈ {25, 50} ; b ∈ {25, 50, 75} ; r = a + b ≤ 100` | `word:de_plus_que`, `word:combien` | Vérifie : {a} + {b} = {r} francs. | — |

## Les pièges du mot-clé (F30-06)

Huit problèmes ont un mot qui induit en erreur. Chacun a son jumeau : mêmes nombres ou même schéma, sans le mot piégeur. Le développeur s'en sert pour les tests et pour montrer le schéma à la correction. L'enfant ne voit jamais cette colonne.

| Clé du piège | Jumeau | Mot | Opération réelle | Opération que le mot suggère | Niveau |
| --- | --- | --- | --- | --- | --- |
| `mangues_donnees_piege` | `mangues_donnees` | donner | + | − | 1 |
| `biscuits_en_tout_piege` | `mangues_caisses` | en tout | × | + | 1 |
| `billes_chacun_piege` | `billes_sacs` | chacun | × | ÷ | 2 |
| `tas_fois_piege` | `billes_tas` | combien de fois | ÷ | × | 2 |
| `billes_mamadou_moins_piege` | `billes_difference` | de moins que | + | − | 2 |
| `mangues_de_plus_que_piege` | `mangues_difference` | de plus que | − | + | 3 |
| `biscuits_partages_piege` | `biscuits_paquets` | partager | × | ÷ | 3 |
| `mangues_moitie_piege` | `mangues_deux_fois_plus` | la moitié | × | ÷ | 3 |

## La paire de la version 1.0

Le critère « Terminé quand » de F30 demande qu'un enfant résolve « Awa a 12 mangues, elle en donne 5 » avec le schéma en barres, puis réussisse la version piège du même problème. La paire est :

- `mangues_donnees` (niveau 1, avec images) : Awa a 12 mangues, elle en donne 5, il reste 7. Schéma `retirer` : tout 12, partie 5, reste cherché. Calcul : 12 − 5 = 7.
- `mangues_donnees_piege` (niveau 1, même histoire) : Awa donne 5 mangues, il lui en reste 7. Combien en avait-elle au départ ? Schéma `retirer` : même barre, mêmes parties (5 et 7), le tout cherché. Calcul : 7 + 5 = 12.

Les deux problèmes ont la même histoire, les mêmes nombres (12, 5 et 7) et le même schéma. Le mot « donne » est le piège : il fait penser à retirer, alors qu'il faut retrouver le tout en ajoutant. L'élève qui a compris le schéma réussit les deux.

## Répartition

- **Niveaux** : 10 problèmes au niveau 1 (avec images), 10 au niveau 2, 10 au niveau 3.
- **Opérations** : `+` 7, `−` 8, `×` 8, `÷` 7.
- **Situations** : réunir 4, retirer 6 (dont la version piège de la paire), comparer 5, groupes égaux 8, partage 7.
- **Pièges** : 8, chacun avec son jumeau (tableau ci-dessus). Les jumeaux sont des problèmes à part entière du tableau.
- **Contextes** : marché, francs CFA, mangues, car rapide, Tabaski, thé, avec Awa, Moussa, Fatou, Mamadou, Aminata et Ibrahima.
- **Enregistrements** : 30 énoncés en wolof et 30 fichiers audio, à faire par le propriétaire.

## Pour le code (F30-02 à F30-04)

### Vocabulaire des formes de schéma

Chaque ligne a une forme (code) et des rôles. Les noms de rôles sont fixes pour chaque forme ; la colonne « Rôles » dit quel placeholder tient quel rôle.

- `reunir` : deux parties connues, le tout est cherché. Rôles : `tout`, `partie1`, `partie2`, avec `tout = partie1 + partie2`.
- `retirer` : le tout et une partie sont connus, l'autre partie est cherchée (ce qui reste, ou ce qui part). Rôles : `tout`, `partie`, `reste`, avec `tout = partie + reste`. Le tout peut être le cherché (version piège de `mangues_donnees`) ; le rôle `tout` reçoit alors `r`.
- `comparer`, variante additive (rôle `ecart`) : une barre, découpée en la petite partie et l'écart, avec `grand = petit + ecart`. Une des trois valeurs est cherchée.
- `comparer`, variante multiplicative (rôle `fois`) : deux barres, la grande vaut `fois` fois la petite, avec `grand = petit × fois`. Exemple : Fatou a deux fois plus que Aminata.
- Le jeu de rôles choisit la variante : `ecart` (additive) ou `fois` (multiplicative). Une valeur de rôle est un placeholder (`a`, `b`, `r`) ou un entier littéral (`fois=2`).
- `groupes` : `groupes` barres de même taille `taille` ; le tout cherché vaut `groupes × taille`. Rôles : `groupes`, `taille`, `tout`.
- `groupement` : la taille d'une part est connue, on cherche le nombre de groupes ; le tout est `taille × groupes`. Rôles : `tout`, `taille`, `groupes`.
- `partage` : une barre entière coupée en `parts` parts égales ; une part est cherchée. Rôles : `tout`, `parts`, `part`, avec `tout = parts × part`.

Les opérations s'écrivent `+`, `−`, `×` et `÷`, comme dans F28.

### Grammaire des plages

- `x ∈ [lo, hi]` : entier tiré uniformément, bornes comprises. `hi` peut dépendre des nombres déjà tirés (`a − 2`).
- `x ∈ {v1, v2, …}` : tirage dans la liste.
- `x = expression [≤ plafond]` : pour n'importe quel placeholder, valeur calculée à partir des nombres déjà tirés, jamais tirée (par exemple `a = b × r ≤ 20` pour une division, où `b` et `r` sont tirés). La contrainte éventuelle doit être respectée.
- Une contrainte seule, comme `b < a`, est une condition sur les tirages déjà faits.

### Ordre et plafond

- L'ordre de tirage est celui de la colonne « Plages » ; dans une division, `r` est tiré et `a` est calculé.
- Le plafond du niveau (20, 50 ou 100) s'applique à chaque nombre affiché (`a`, `b`) et à la réponse `r`, en plus des contraintes de la ligne.
- Si une contrainte échoue, on rejette le tirage et on tire de nouveau ; on ne corrige jamais un nombre.
- Les plages prévues évitent les résultats négatifs et nuls.

### Mots touchables

- Les mots touchables d'un énoncé sont les mots de F28 trouvés dans l'énoncé : on prend, pour chaque clé, la première occurrence entière (insensible à la casse) du mot ou de la forme de F28 (colonnes « Mot ou expression » et « Forme dans l'exemple »). En cas de chevauchement, l'expression la plus longue gagne et la plus courte est ignorée (par exemple « partage également » l'emporte sur « partager », « combien de fois » sur « combien » et « fois »).
- La colonne « Mots des maths » est une vérification : l'ensemble des mots trouvés dans l'énoncé doit être égal à l'ensemble listé.

### Règle pour tirer les nombres

- Niveau 1 : tous les nombres et tous les résultats sont inférieurs ou égaux à 20, sans argent.
- Niveau 2 : inférieurs ou égaux à 50, sans argent.
- Niveau 3 : inférieurs ou égaux à 100. L'argent est en francs, par multiples de 25 (25, 50, 75, 100), et n'apparaît qu'au niveau 3.
- Les variantes générées sont lues en français par la synthèse vocale (F23). Seul l'énoncé à nombres fixes de la première table a un enregistrement en wolof (`wo_problem_<clé>.m4a`).

### Clés et conventions

- Les clés sont stables. Les clés des pièges finissent par `_piege` : c'est une convention de lecture, pas une règle du code ; le code ne doit pas s'en servir pour décider.
- L'identifiant d'un problème dans l'app est `problem:<clé>`, celui d'un mot reste `word:<clé>`.

## À valider par le propriétaire

- **Plafond d'argent au niveau 3** : les sommes restent à 100 francs au plus, par multiples de 25, pour respecter les plages de nombres. F28 utilise déjà 150 et 500 francs. Décision de l'orchestrateur : on garde 100 francs ; à confirmer par le propriétaire.
- **Paire de la version 1.0** : `mangues_donnees_piege` demande le tout au lieu de la partie restante, avec la même histoire, les mêmes nombres et le même schéma.
- **Prix** : « un sachet d'eau à 25 francs » et les autres montants (50 et 75 francs) sont des exemples à confirmer.
- **Plafonds** : niveau 1 à 20, niveau 2 à 50, niveau 3 à 100 ; décision de l'orchestrateur.
- **Tabaski** : le contexte est présent aux niveaux 1 et 3 ; à confirmer pour le niveau 2.
- **Huit pièges** : les mots `donner`, `en tout`, `chacun`, `combien de fois`, `de moins que`, `de plus que`, `partager`, `la moitié` ; décision de l'orchestrateur.

## Ce qui reste à faire

- Le propriétaire écrit les énoncés en wolof (colonne « Wolof : énoncé ») et enregistre les 30 fichiers audio `wo_problem_<clé>.m4a`, avec les mots du glossaire de F28.
- Le code agent construit les gabarits (F30-02), le schéma en barres (F30-03) et les étapes guidées (F30-04) à partir de ce tableau.

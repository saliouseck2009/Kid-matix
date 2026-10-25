# Problèmes : tableau de contenu

Statut : brouillon. Ce document est le tableau de contenu du lot F30 (tâche F30-01). Il prépare les gabarits (F30-02), le schéma en barres (F30-03), la résolution guidée (F30-04), les mots touchables (F30-05), les pièges du mot-clé (F30-06) et le parcours (F30-07). Les énoncés, les nombres et les pièges sont à valider par le propriétaire ; les énoncés en wolof et leurs audios restent à enregistrer.

**Les clés ne changent jamais une fois publiées.** Une clé est l'identifiant d'un problème dans l'app (`problem:<clé>`) et donne le nom de son audio (`wo_problem_<clé>.m4a`). Une nouvelle situation reçoit une nouvelle clé ; une clé retirée reste réservée.

Trente problèmes : dix par niveau. Chaque problème a une ligne dans le tableau « Énoncé et schéma » de son niveau et une ligne dans le tableau « Gabarit » du même niveau, reliées par la clé.

## Comment lire les tableaux

- **Niveau 1** : avec images. Une phrase courte qu'un enfant qui lit mal suit avec un dessin. Tous les nombres et tous les résultats sont inférieurs ou égaux à 20. Chaque problème a une idée d'image, sans aucun texte dans le dessin.
- **Niveau 2** : une phrase courte. Nombres et résultats inférieurs ou égaux à 50.
- **Niveau 3** : énoncé complet. Nombres et résultats inférieurs ou égaux à 100. Les sommes d'argent sont en francs CFA, par multiples de 25, et restent inférieures ou égales à 100 francs (point à valider, voir plus bas).
- **Clé** : lettres minuscules, sans accent, mots reliés par `_`.
- **Opération** : `+`, `−`, `×` ou `÷`. C'est l'opération attendue, celle du calcul.
- **Situation** : une des trois situations du glossaire de F28 : réunir ou retirer, comparer, groupes égaux ou partage. Elle décrit l'histoire, jamais un mot.
- **Forme** : la forme du schéma en barres (vocabulaire en fin de document, pour le code).
- **Tout, Parties, Cherché** : les nombres connus du schéma et ce qu'il faut trouver, avec les nombres de l'enregistrement.
- **Calcul** : le calcul qui donne la réponse, avec les nombres de l'enregistrement.
- **Énoncé** : la phrase française enregistrée en wolof (F30-05). Les nombres sont fixes.
- **Wolof : énoncé** : vide. Le propriétaire le remplit ; le rédacteur n'écrit aucun wolof.
- **Audio** : le nom attendu du fichier, fixé par la clé.
- **Gabarit** : la même phrase avec des nombres tirés au sort, `{a}` et `{b}` (F30-02). `{r}` désigne la réponse. Les plages sont inclusives.
- **Mots des maths** : les clés `word:` de F28 présentes dans la phrase (`word:il_reste`). Le mot garde sa forme de la colonne « Forme dans l'exemple » de F28, pour qu'il puisse se toucher.
- **Vérification** : la phrase de la dernière étape guidée (F30-04). Elle reprend les nombres du gabarit.
- **Piège ou jumeau** : « Piège » décrit le mot qui induit en erreur et l'opération réelle ; « Jumeau » donne le problème sans piège, avec les mêmes nombres ou le même schéma. Cette colonne sert au développeur et à la relecture, jamais à l'enfant.

Aucun énoncé ne dit qu'un mot donne une opération : l'enfant lit l'histoire, il ne retient pas une règle. Un mot-clé est parfois trompeur, et le schéma aide à voir la situation.

## Niveau 1 · avec images

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees` | 1 | − | retirer | retirer | 12 | 5 (donnés) et ? | la partie qui reste | 12 − 5 = 7 | Awa a 12 mangues. Elle en donne 5 à sa petite sœur. Combien de mangues lui reste-t-il ? |  | `wo_problem_mangues_donnees.m4a` |
| `billes_recues` | 1 | + | réunir | réunir | ? | 6 et 4 | le tout | 6 + 4 = 10 | Mamadou a 6 billes. Il reçoit 4 billes de son ami. Combien de billes a-t-il maintenant ? |  | `wo_problem_billes_recues.m4a` |
| `mangues_caisses` | 1 | × | groupes égaux | groupes | ? | 3 groupes de 5 | le total | 3 × 5 = 15 | Au marché, Fatou a 3 caisses. Dans chaque caisse, il y a 5 mangues. Combien de mangues a-t-elle ? |  | `wo_problem_mangues_caisses.m4a` |
| `mangues_partagees` | 1 | ÷ | partage | partage | 12 | 3 parts égales | une part | 12 ÷ 3 = 4 | Fatou a 12 mangues. Elle les partage également entre 3 amis. Combien de mangues reçoit chacun ? |  | `wo_problem_mangues_partagees.m4a` |
| `chaises_tabaski` | 1 | ÷ | partage | partage | 10 | 2 rangées égales | une rangée | 10 ÷ 2 = 5 | Pour la Tabaski, Awa a 10 chaises. Elle les range en 2 rangées égales. Combien de chaises y a-t-il dans chaque rangée ? |  | `wo_problem_chaises_tabaski.m4a` |
| `car_personnes` | 1 | − | retirer | retirer | 9 | 4 (descendues) et ? | la partie qui reste | 9 − 4 = 5 | Dans le car rapide, il y a 9 personnes. 4 personnes descendent. Il reste combien de personnes ? |  | `wo_problem_car_personnes.m4a` |
| `billes_mamadou_moins` | 1 | − | comparer | comparer | 8 (Ibrahima) | ? (Mamadou) et 3 (écart) | Mamadou | 8 − 3 = 5 | Ibrahima a 8 billes. Mamadou en a 3 de moins que lui. Combien de billes a Mamadou ? |  | `wo_problem_billes_mamadou_moins.m4a` |
| `sucre_theieres` | 1 | ÷ | partage | partage | 8 | 2 parts égales | une part | 8 ÷ 2 = 4 | Mamadou a 8 morceaux de sucre. Il les répartit dans 2 théières, le même nombre dans chaque. Combien de morceaux y a-t-il dans chaque théière ? |  | `wo_problem_sucre_theieres.m4a` |
| `biscuits_en_tout_piege` | 1 | × | groupes égaux | groupes | ? | 5 groupes de 3 | le total | 5 × 3 = 15 | Aminata achète 5 paquets de 3 biscuits. Combien de biscuits a-t-elle en tout ? |  | `wo_problem_biscuits_en_tout_piege.m4a` |
| `billes_donnees_piege` | 1 | + | réunir | réunir | ? | 6 et 4 | le tout | 6 + 4 = 10 | Mamadou a 6 billes. Son ami lui donne 4 billes. Combien de billes a-t-il maintenant ? |  | `wo_problem_billes_donnees_piege.m4a` |

### Gabarit

| Clé | Gabarit | Plages | Mots des maths | Vérification | Piège ou jumeau | Idée d'image |
| --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees` | Awa a {a} mangues. Elle en donne {b} à sa petite sœur. Combien de mangues lui reste-t-il ? | a de 6 à 20 ; b de 2 à a − 2 ; r = a − b | `word:donner`, `word:il_reste`, `word:combien` | Vérifie : {b} + {r} = {a}, c'est bien le nombre de mangues d'Awa. | Jumeau du piège `mangues_donnees_piege` : même tout (12), mêmes parties (5 et 7). | Un panier avec 12 mangues dessinées ; une petite fille tend la main, 5 mangues sortent du panier, 7 restent dedans. |
| `billes_recues` | Mamadou a {a} billes. Il reçoit {b} billes de son ami. Combien de billes a-t-il maintenant ? | a de 2 à 10 ; b de 2 à 10 ; r = a + b | `word:recevoir`, `word:combien` | Vérifie : {a} + {b} = {r}, Mamadou a plus de billes qu'avant. | Jumeau du piège `billes_donnees_piege`. | Un garçon avec un petit tas de billes ; un autre garçon tend des billes vers lui. |
| `mangues_caisses` | Au marché, Fatou a {a} caisses. Dans chaque caisse, il y a {b} mangues. Combien de mangues a-t-elle ? | a de 2 à 5 ; b de 2 à 5 ; r = a × b (≤ 20) | `word:dans_chaque`, `word:combien` | Vérifie : {a} × {b} = {r}, c'est bien le nombre de mangues de Fatou. | Jumeau du piège `biscuits_en_tout_piege`. | Trois caisses ouvertes, chacune avec 5 mangues dessinées. |
| `mangues_partagees` | Fatou a {a} mangues. Elle les partage également entre {b} amis. Combien de mangues reçoit chacun ? | b de 2 à 5 ; r de 2 à 5 ; a = b × r (≤ 20) | `word:partager_egalement`, `word:chacun` | Vérifie : {b} × {r} = {a}, chaque ami a bien {r} mangues. | — | Un grand plat avec 12 mangues ; à côté, 3 assiettes vides de même taille. |
| `chaises_tabaski` | Pour la Tabaski, Awa a {a} chaises. Elle les range en {b} rangées égales. Combien de chaises y a-t-il dans chaque rangée ? | b de 2 à 4 ; r de 2 à 5 ; a = b × r (≤ 20) | `word:rangee`, `word:dans_chaque`, `word:combien` | Vérifie : {b} × {r} = {a}, il y a bien {a} chaises. | — | Dix chaises dessinées, en deux lignes de cinq. |
| `car_personnes` | Dans le car rapide, il y a {a} personnes. {b} personnes descendent. Il reste combien de personnes ? | a de 5 à 20 ; b de 1 à a − 1 ; r = a − b | `word:il_reste`, `word:combien` | Vérifie : {b} + {r} = {a} personnes. | — | Un car rapide vu de côté, avec des personnes dedans ; quatre personnes près de la porte, qui sortent. |
| `billes_mamadou_moins` | Ibrahima a {a} billes. Mamadou en a {b} de moins que lui. Combien de billes a Mamadou ? | a de 4 à 20 ; b de 1 à a − 1 ; r = a − b | `word:de_moins_que`, `word:combien` | Vérifie : {r} + {b} = {a}, c'est bien le nombre de billes d'Ibrahima. | — | Une barre pleine pour Ibrahima ; une barre plus courte, en pointillés, pour Mamadou ; l'écart est en couleur. |
| `sucre_theieres` | Mamadou a {a} morceaux de sucre. Il les répartit dans {b} théières, le même nombre dans chaque. Combien de morceaux y a-t-il dans chaque théière ? | b de 2 à 4 ; r de 2 à 5 ; a = b × r (≤ 20) | `word:repartir`, `word:dans_chaque` | Vérifie : {b} × {r} = {a} morceaux. | — | Huit morceaux de sucre dessinés ; deux théières vides, côte à côte. |
| `biscuits_en_tout_piege` | Aminata achète {a} paquets de {b} biscuits. Combien de biscuits a-t-elle en tout ? | a de 2 à 5 ; b de 2 à 5 ; r = a × b (≤ 20) | `word:en_tout`, `word:acheter` | Vérifie : {a} × {b} = {r} biscuits. | Piège : « en tout » fait penser à réunir ; ici les paquets ont la même taille, donc 5 × 3. Jumeau : `mangues_caisses`. | Cinq petits paquets, chacun avec 3 biscuits dessinés. |
| `billes_donnees_piege` | Mamadou a {a} billes. Son ami lui donne {b} billes. Combien de billes a-t-il maintenant ? | a de 2 à 10 ; b de 2 à 10 ; r = a + b | `word:donner`, `word:combien` | Vérifie : {a} + {b} = {r} : Mamadou a plus de billes qu'avant. | Piège : « donne » fait penser à retirer ; ici c'est Mamadou qui reçoit, il a donc plus de billes. Jumeau : `billes_recues`. | Un garçon avec 6 billes ; un ami tend 4 billes vers lui, la main tournée vers le garçon. |

## Niveau 2 · phrase courte

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_donnees_piege` | 2 | + | comparer | comparer | ? (Awa) | 7 (Moussa) et 5 (écart) | Awa | 7 + 5 = 12 | Moussa a 7 mangues. Il en a 5 de moins que Awa. Combien de mangues a Awa ? |  | `wo_problem_mangues_donnees_piege.m4a` |
| `billes_chacun_piege` | 2 | × | groupes égaux | groupes | ? | 4 groupes de 6 | le total | 4 × 6 = 24 | Chacun des 4 enfants reçoit 6 billes. Combien de billes faut-il ? |  | `wo_problem_billes_chacun_piege.m4a` |
| `billes_sacs` | 2 | × | groupes égaux | groupes | ? | 4 groupes de 6 | le total | 4 × 6 = 24 | Il y a 4 sacs. Dans chaque sac, il y a 6 billes. Combien de billes y a-t-il ? |  | `wo_problem_billes_sacs.m4a` |
| `tas_fois_piege` | 2 | ÷ | partage | partage | 24 | tas de 3 | le nombre de tas | 24 ÷ 3 = 8 | Awa a 24 billes. Combien de fois peut-elle faire un tas de 3 billes ? |  | `wo_problem_tas_fois_piege.m4a` |
| `billes_tas` | 2 | ÷ | partage | partage | 24 | tas de 3 | le nombre de tas | 24 ÷ 3 = 8 | Awa a 24 billes. Elle fait des tas de 3 billes. Combien de tas peut-elle faire ? |  | `wo_problem_billes_tas.m4a` |
| `moussa_paniers` | 2 | + | réunir | réunir | ? | 18 et 15 | le total | 18 + 15 = 33 | Moussa a 18 mangues dans un panier et 15 mangues dans un autre. Combien de mangues a-t-il ensemble ? |  | `wo_problem_moussa_paniers.m4a` |
| `fatou_sachets` | 2 | − | retirer | retirer | 36 | 14 (vendus) et ? | la partie qui reste | 36 − 14 = 22 | Fatou a 36 sachets d'eau. Elle en vend 14 au marché. Combien lui en reste-t-il ? |  | `wo_problem_fatou_sachets.m4a` |
| `ibrahima_difference` | 2 | − | comparer | comparer | 36 (Fatou) | 19 (Ibrahima) et ? (écart) | l'écart | 36 − 19 = 17 | Fatou a 36 billes. Ibrahima en a 19. Quelle est la différence entre leurs billes ? |  | `wo_problem_ibrahima_difference.m4a` |
| `biscuits_range` | 2 | ÷ | partage | partage | 48 | 6 parts égales | une part | 48 ÷ 6 = 8 | Aminata a 48 biscuits. Elle les range en 6 paquets égaux. Combien de biscuits y a-t-il dans chaque paquet ? |  | `wo_problem_biscuits_range.m4a` |
| `mamadou_gagne` | 2 | + | réunir | réunir | ? | 30 (au départ) et 12 (gagnées) | le total à la fin | 30 + 12 = 42 | Au départ, Mamadou a 30 billes. Après le jeu, il en gagne 12. Combien en a-t-il à la fin ? |  | `wo_problem_mamadou_gagne.m4a` |

### Gabarit

| Clé | Gabarit | Plages | Mots des maths | Vérification | Piège ou jumeau |
| --- | --- | --- | --- | --- | --- |
| `mangues_donnees_piege` | Moussa a {a} mangues. Il en a {b} de moins que Awa. Combien de mangues a Awa ? | a de 2 à 40 ; b de 1 à 10 ; r = a + b (≤ 50) | `word:de_moins_que`, `word:combien` | Vérifie : {a} + {b} = {r}, Awa a bien {r} mangues. | Piège : « de moins que » fait penser à retirer ; ici Awa a la plus grande quantité, il faut ajouter : 7 + 5. Jumeau : `mangues_donnees` (mêmes nombres, 12, 5 et 7). |
| `billes_chacun_piege` | Chacun des {a} enfants reçoit {b} billes. Combien de billes faut-il ? | a de 2 à 9 ; b de 2 à 9 ; r = a × b (≤ 50) | `word:chacun`, `word:recevoir` | Vérifie : {a} × {b} = {r} billes. | Piège : « chacun » fait penser à partager ; ici chaque enfant reçoit la même quantité, donc 4 × 6. Jumeau : `billes_sacs`. |
| `billes_sacs` | Il y a {a} sacs. Dans chaque sac, il y a {b} billes. Combien de billes y a-t-il ? | a de 2 à 9 ; b de 2 à 9 ; r = a × b (≤ 50) | `word:dans_chaque`, `word:combien` | Vérifie : {a} × {b} = {r} billes. | Jumeau du piège `billes_chacun_piege`. |
| `tas_fois_piege` | Awa a {a} billes. Combien de fois peut-elle faire un tas de {b} billes ? | b de 2 à 5 ; r de 2 à 9 ; a = b × r (≤ 45) | `word:combien_de_fois` | Vérifie : {b} × {r} = {a} billes. | Piège : « combien de fois » fait penser à multiplier ; ici on cherche combien de tas de 3 on peut faire avec 24 billes, donc 24 ÷ 3. Jumeau : `billes_tas`. |
| `billes_tas` | Awa a {a} billes. Elle fait des tas de {b} billes. Combien de tas peut-elle faire ? | b de 2 à 5 ; r de 2 à 9 ; a = b × r (≤ 45) | `word:combien` | Vérifie : {b} × {r} = {a} billes. | Jumeau du piège `tas_fois_piege`. |
| `moussa_paniers` | Moussa a {a} mangues dans un panier et {b} mangues dans un autre. Combien de mangues a-t-il ensemble ? | a de 5 à 30 ; b de 5 à 30 ; r = a + b (≤ 50) | `word:ensemble`, `word:combien` | Vérifie : {a} + {b} = {r} mangues. | — |
| `fatou_sachets` | Fatou a {a} sachets d'eau. Elle en vend {b} au marché. Combien lui en reste-t-il ? | a de 10 à 50 ; b de 1 à a − 2 ; r = a − b | `word:vendre`, `word:il_reste` | Vérifie : {b} + {r} = {a} sachets. | — |
| `ibrahima_difference` | Fatou a {a} billes. Ibrahima en a {b}. Quelle est la différence entre leurs billes ? | a de 10 à 50 ; b de 1 à a − 1 ; r = a − b | `word:difference` | Vérifie : {b} + {r} = {a} billes. | — |
| `biscuits_range` | Aminata a {a} biscuits. Elle les range en {b} paquets égaux. Combien de biscuits y a-t-il dans chaque paquet ? | b de 2 à 6 ; r de 2 à 9 ; a = b × r (≤ 50) | `word:egal`, `word:dans_chaque` | Vérifie : {b} × {r} = {a} biscuits. | — |
| `mamadou_gagne` | Au départ, Mamadou a {a} billes. Après le jeu, il en gagne {b}. Combien en a-t-il à la fin ? | a de 5 à 30 ; b de 2 à 20 ; r = a + b (≤ 50) | `word:au_depart`, `word:apres`, `word:gagner`, `word:a_la_fin` | Vérifie : {a} + {b} = {r} billes. | — |

## Niveau 3 · énoncé complet

### Énoncé et schéma

| Clé | Niveau | Opération | Situation | Forme | Tout | Parties | Cherché | Calcul | Énoncé | Wolof : énoncé | Audio |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `mangues_de_plus_que_piege` | 3 | − | comparer | comparer | 84 (Awa) | ? (Moussa) et 45 (écart) | Moussa | 84 − 45 = 39 | Awa a 84 mangues. Elle en a 45 de plus que Moussa. Combien de mangues a Moussa ? |  | `wo_problem_mangues_de_plus_que_piege.m4a` |
| `mangues_difference` | 3 | − | comparer | comparer | 84 (Awa) | 39 (Moussa) et ? (écart) | l'écart | 84 − 39 = 45 | Awa a 84 mangues. Moussa en a 39. Quelle est la différence entre leurs mangues ? |  | `wo_problem_mangues_difference.m4a` |
| `biscuits_partages_piege` | 3 | × | groupes égaux | groupes | ? | 4 paquets de 12 | le total | 4 × 12 = 48 | Moussa a 4 paquets de 12 biscuits. Il partage ses paquets avec ses amis. Quel est le total de ses biscuits ? |  | `wo_problem_biscuits_partages_piege.m4a` |
| `biscuits_paquets` | 3 | × | groupes égaux | groupes | ? | 4 paquets de 12 | le total | 4 × 12 = 48 | Au marché, Moussa achète des biscuits par paquets de 12. Il en prend 4 paquets. Combien de biscuits a-t-il ? |  | `wo_problem_biscuits_paquets.m4a` |
| `mangues_deux_fois_plus` | 3 | × | groupes égaux | groupes | 25 (Aminata) | 2 groupes de 25 | Fatou | 25 × 2 = 50 | Aminata a 25 mangues. Fatou en a 2 fois plus. Combien de mangues Fatou a-t-elle ? |  | `wo_problem_mangues_deux_fois_plus.m4a` |
| `mangues_moitie_piege` | 3 | × | groupes égaux | groupes | 50 (Fatou) | 2 groupes de 25 | Fatou | 25 × 2 = 50 | Aminata a 25 mangues. Elle a la moitié des mangues de Fatou. Combien de mangues Fatou a-t-elle ? |  | `wo_problem_mangues_moitie_piege.m4a` |
| `achat_pain` | 3 | − | retirer | retirer | 100 francs | 25 francs (achat) et ? | la somme qui reste | 100 − 25 = 75 | Au départ, Ibrahima a 100 francs. Il achète un sachet d'eau à 25 francs. Combien d'argent lui reste-t-il à la fin ? |  | `wo_problem_achat_pain.m4a` |
| `awa_marche_francs` | 3 | + | réunir | réunir | ? | 50 francs et 25 francs | le total | 50 + 25 = 75 | Awa achète des mangues à 50 francs et du thé à 25 francs. Quel est le total ? |  | `wo_problem_awa_marche_francs.m4a` |
| `rangees_tabaski` | 3 | ÷ | partage | partage | 48 | 6 rangées égales | une rangée | 48 ÷ 6 = 8 | Pour la Tabaski, 48 chaises sont rangées en 6 rangées égales dans la cour. Combien de chaises y a-t-il dans chaque rangée ? |  | `wo_problem_rangees_tabaski.m4a` |
| `awa_moussa_plus` | 3 | + | comparer | comparer | ? (Awa) | 25 (Moussa) et 75 (écart) | Awa | 25 + 75 = 100 | Moussa a 25 francs. Awa en a 75 de plus que lui. Combien de francs Awa a-t-elle ? |  | `wo_problem_awa_moussa_plus.m4a` |

### Gabarit

| Clé | Gabarit | Plages | Mots des maths | Vérification | Piège ou jumeau |
| --- | --- | --- | --- | --- | --- |
| `mangues_de_plus_que_piege` | Awa a {a} mangues. Elle en a {b} de plus que Moussa. Combien de mangues a Moussa ? | a de 20 à 100 ; b de 5 à a − 5 ; r = a − b | `word:de_plus_que`, `word:combien` | Vérifie : {r} + {b} = {a}, Awa a bien {a} mangues. | Piège : « de plus que » fait penser à réunir ; ici Awa a la plus grande quantité, il faut retirer l'écart : 84 − 45. Jumeau : `mangues_difference`. |
| `mangues_difference` | Awa a {a} mangues. Moussa en a {b}. Quelle est la différence entre leurs mangues ? | a de 20 à 100 ; b de 5 à a − 5 ; r = a − b | `word:difference` | Vérifie : {b} + {r} = {a} mangues. | Jumeau du piège `mangues_de_plus_que_piege`. |
| `biscuits_partages_piege` | Moussa a {a} paquets de {b} biscuits. Il partage ses paquets avec ses amis. Quel est le total de ses biscuits ? | a de 2 à 9 ; b de 2 à 12 ; r = a × b (≤ 100) | `word:partager`, `word:total` | Vérifie : {a} × {b} = {r} biscuits. | Piège : « partage » fait penser à diviser ; ici les paquets ne sont pas coupés, on a 4 groupes de 12, donc 4 × 12. Jumeau : `biscuits_paquets`. |
| `biscuits_paquets` | Au marché, Moussa achète des biscuits par paquets de {b}. Il en prend {a} paquets. Combien de biscuits a-t-il ? | a de 2 à 9 ; b de 2 à 12 ; r = a × b (≤ 100) | `word:par_paquets_de`, `word:acheter`, `word:combien` | Vérifie : {a} × {b} = {r} biscuits. | Jumeau du piège `biscuits_partages_piege`. |
| `mangues_deux_fois_plus` | Aminata a {a} mangues. Fatou en a {b} fois plus. Combien de mangues Fatou a-t-elle ? | b de 2 à 4 ; a de 5 à 100 ÷ b ; r = a × b (≤ 100) | `word:fois`, `word:combien` | Vérifie : {a} × {b} = {r} mangues. | Jumeau du piège `mangues_moitie_piege`. |
| `mangues_moitie_piege` | Aminata a {a} mangues. Elle a la moitié des mangues de Fatou. Combien de mangues Fatou a-t-elle ? | a de 5 à 50 ; r = 2 × a (≤ 100) | `word:moitie`, `word:combien` | Vérifie : {r} ÷ 2 = {a}, Aminata a bien la moitié. | Piège : « la moitié » fait penser à diviser ; ici Aminata a la moitié, donc Fatou a deux fois plus : 25 × 2. Jumeau : `mangues_deux_fois_plus`. |
| `achat_pain` | Au départ, Ibrahima a {a} francs. Il achète un sachet d'eau à {b} francs. Combien d'argent lui reste-t-il à la fin ? | a parmi 50, 75 ou 100 ; b parmi 25 ou 50, avec b < a ; r = a − b | `word:au_depart`, `word:acheter`, `word:il_reste`, `word:a_la_fin` | Vérifie : {b} + {r} = {a} francs. | — |
| `awa_marche_francs` | Awa achète des mangues à {a} francs et du thé à {b} francs. Quel est le total ? | a et b parmi 25, 50 ou 75 ; r = a + b (≤ 100) | `word:acheter`, `word:total` | Vérifie : {a} + {b} = {r} francs. | — |
| `rangees_tabaski` | Pour la Tabaski, {a} chaises sont rangées en {b} rangées égales dans la cour. Combien de chaises y a-t-il dans chaque rangée ? | b de 2 à 10 ; r de 2 à 9 ; a = b × r (≤ 100) | `word:rangee`, `word:dans_chaque` | Vérifie : {b} × {r} = {a} chaises. | — |
| `awa_moussa_plus` | Moussa a {a} francs. Awa en a {b} de plus que lui. Combien de francs Awa a-t-elle ? | a parmi 25 ou 50 ; b parmi 25, 50 ou 75 ; r = a + b (≤ 100) | `word:de_plus_que`, `word:combien` | Vérifie : {a} + {b} = {r} francs. | — |

## Les pièges du mot-clé (F30-06)

Huit problèmes ont un mot qui induit en erreur. Chacun a son jumeau : même situation, mêmes nombres ou même schéma, sans le mot piégeur. Le développeur s'en sert pour les tests et pour montrer le schéma à la correction. L'enfant ne voit jamais cette colonne.

| Clé du piège | Jumeau | Mot | Opération réelle | Opération que le mot suggère | Niveau |
| --- | --- | --- | --- | --- | --- |
| `mangues_donnees_piege` | `mangues_donnees` | de moins que | + | − | 2 |
| `billes_donnees_piege` | `billes_recues` | donner | + | − | 1 |
| `biscuits_en_tout_piege` | `mangues_caisses` | en tout | × | + | 1 |
| `billes_chacun_piege` | `billes_sacs` | chacun | × | ÷ | 2 |
| `tas_fois_piege` | `billes_tas` | combien de fois | ÷ | × | 2 |
| `mangues_de_plus_que_piege` | `mangues_difference` | de plus que | − | + | 3 |
| `biscuits_partages_piege` | `biscuits_paquets` | partager | × | ÷ | 3 |
| `mangues_moitie_piege` | `mangues_deux_fois_plus` | la moitié | × | ÷ | 3 |

## La paire de la version 1.0

Le critère « Terminé quand » de F30 demande qu'un enfant résolve « Awa a 12 mangues, elle en donne 5 » avec le schéma en barres, puis réussisse la version piège du même problème. La paire est :

- `mangues_donnees` (niveau 1, avec images) : Awa a 12 mangues, elle en donne 5, il reste 7. Schéma : un tout de 12, parties 5 et ?. Calcul : 12 − 5 = 7.
- `mangues_donnees_piege` (niveau 2, phrase courte) : Moussa a 7 mangues, il en a 5 de moins qu'Awa. Combien Awa en a-t-elle ? Schéma : un tout de ?, parties 7 et 5. Calcul : 7 + 5 = 12.

Les deux problèmes ont les mêmes nombres (12, 5 et 7) et le même schéma en barres. Le mot « de moins que » est le piège : un enfant qui retire se trompe (7 − 5 = 2) ; il faut ajouter l'écart à la petite quantité pour retrouver le tout. L'élève qui a compris le schéma réussit les deux.

## Répartition

- **Niveaux** : 10 problèmes au niveau 1 (avec images), 10 au niveau 2, 10 au niveau 3.
- **Opérations** : `+` 7, `−` 8, `×` 8, `÷` 7.
- **Situations** : réunir ou retirer 9 (dont réunir 5, retirer 4), comparer 6, groupes égaux 8, partage 7.
- **Pièges** : 8, chacun avec son jumeau (tableau ci-dessus). Les jumeaux sont des problèmes à part entière du tableau, pas des doublons.
- **Contextes** : marché, francs CFA, mangues, car rapide, Tabaski, thé, avec Awa, Moussa, Fatou, Mamadou, Aminata et Ibrahima.
- **Enregistrements** : 30 énoncés en wolof et 30 fichiers audio, à faire par le propriétaire.

## Pour le code (F30-02 à F30-04)

### Lire les gabarits

- `{a}` et `{b}` sont les nombres tirés au sort. `{r}` est la réponse, calculée avec l'opération du problème (colonne « Calcul » pour l'enregistrement).
- Une plage « de x à y » est un entier tiré dans l'intervalle, bornes comprises. « parmi x, y ou z » est un tirage dans cette liste.
- « r = a × b », « r = a + b », « r = a − b » : la réponse est calculée à partir des nombres tirés.
- « a = b × r » : pour une division, on tire le diviseur `b` et la réponse `r`, puis on calcule le dividende `a`. La division tombe toujours juste.
- « (≤ 20) », « (≤ 50) », « (≤ 100) » : le plafond du niveau. Il s'applique à `a`, `b` et au résultat `r` ; si la contrainte n'est pas respectée, on tire à nouveau.
- Les plages prévues évitent les résultats négatifs et nuls. Si un tirage casse une contrainte, on tire de nouveau au lieu de corriger le nombre.
- La colonne « Vérification » est la phrase de la dernière étape guidée. Elle reprend les mêmes placeholders.
- La colonne « Mots des maths » liste les clés `word:` à toucher. Un gabarit garde la forme du mot de F28 dans sa phrase.

### Règle pour tirer les nombres

- Niveau 1 : tous les nombres et tous les résultats sont inférieurs ou égaux à 20, sans argent.
- Niveau 2 : inférieurs ou égaux à 50, sans argent.
- Niveau 3 : inférieurs ou égaux à 100. L'argent est en francs, par multiples de 25 (25, 50, 75, 100), et n'apparaît qu'au niveau 3.
- Les variantes générées sont lues en français par la synthèse vocale (F23). Seul l'énoncé à nombres fixes de la première table a un enregistrement en wolof (`wo_problem_<clé>.m4a`).

### Vocabulaire des formes de schéma

Chaque problème a une forme, qui décrit le schéma en barres de F30-03 :

- `reunir` : deux parties connues ; le tout est cherché. Une barre entière coupée en deux parties.
- `retirer` : le tout et une partie sont connus ; l'autre partie est cherchée (ce qui reste, ou ce qui part). Une barre entière avec une partie marquée comme retirée.
- `comparer` : deux barres partent du même bord. La plus longue est le tout ; la plus courte et l'écart sont les parties. Une des trois valeurs est cherchée : la petite (soustraction), la grande (addition) ou l'écart (soustraction).
- `groupes` : `n` barres de même taille `k` ; le tout est `n × k`. Le tout est cherché (multiplication) ou une des valeurs connues.
- `partage` : une barre entière coupée en `n` parts égales ; une part est cherchée (division).

La colonne « Forme » suffit à choisir le dessin. Les opérations s'écrivent `+`, `−`, `×` et `÷`, comme dans F28.

### Clés et conventions

- Les clés sont stables. Les clés des pièges finissent par `_piege` : c'est une convention de lecture, pas une règle du code ; le code ne doit pas s'en servir pour décider.
- L'identifiant d'un problème dans l'app est `problem:<clé>`, celui d'un mot reste `word:<clé>`.

## À valider par le propriétaire

- **Plafond d'argent au niveau 3** : les sommes restent à 100 francs au plus, par multiples de 25, pour respecter les plages de nombres. F28 utilise déjà 150 et 500 francs. Faut-il monter le plafond à 500 francs pour les problèmes d'argent du niveau 3 ?
- **Paire de la version 1.0** : le piège `mangues_donnees_piege` demande le tout (12) au lieu de la partie restante, avec les mêmes nombres et le même schéma. Préférez-vous une autre formulation de la version piège ?
- **Prix** : « un sachet d'eau à 25 francs » et les autres montants (50 et 75 francs) sont des exemples à confirmer.
- **Plafonds** : niveau 1 à 20, niveau 2 à 50, niveau 3 à 100, comme demandé ; à confirmer.
- **Tabaski** : le contexte est présent aux niveaux 1 et 3 ; à confirmer pour le niveau 2.
- **Huit pièges** : confirmer le nombre et le choix des mots (`en tout`, `chacun`, `combien de fois`, `donner`, `la moitié`, `partager`, `de plus que`, `de moins que`).

## Ce qui reste à faire

- Le propriétaire écrit les énoncés en wolof (colonne « Wolof : énoncé ») et enregistre les 30 fichiers audio `wo_problem_<clé>.m4a`, avec les mots du glossaire de F28.
- Le code agent construit les gabarits (F30-02), le schéma en barres (F30-03) et les étapes guidées (F30-04) à partir de ce tableau.

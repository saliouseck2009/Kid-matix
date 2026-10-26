# Les mots des maths : tableau de contenu

Statut : brouillon. Le propriétaire a validé le 2026-10-18 les montants en francs, les deux fichiers audio par mot et « acheter » à la place de « manger » ; les textes et les clés restent à valider. Ce document est le tableau de contenu du lot F28 (tâche F28-01). Sa section 3 prépare aussi l'activité « Quelle opération ? » (F28-09), qui n'est pas encore codée.

Wolof provisoire : les colonnes en wolof sont un texte provisoire, traduit par une machine (Meta NLLB-200 ou Google Translate) et non relu ; chaque cellule porte la mention « (machine, à relire) » ou « (Google, à relire) ». Les voix sont une synthèse automatique (Meta MMS) à remplacer par de vrais enregistrements (voir `tool/placeholder_audio/README.md` et `docs/product/audio-recording.md`).

**Les clés ne changent jamais une fois publiées.** Une clé est le nom stable d'un mot : elle donne le nom des deux fichiers audio (`wo_<clé>.m4a` pour l'explication, `wo_<clé>_exemple.m4a` pour l'exemple) et l'identifiant du mot dans l'app (`word:<clé>`). Renommer une clé après publication ferait perdre les progrès déjà enregistrés sur les téléphones, et obligerait à renommer les fichiers audio déjà enregistrés. Une nouvelle notion reçoit une nouvelle clé ; une clé retirée reste réservée.

## Comment lire les tableaux

- **Clé** : lettres minuscules, sans accent, mots reliés par `_`. Unique dans tout le document.
- **Sens simple** : ce que l'enfant entend et lit, en français, au tutoiement. Il ne nomme jamais l'opération : l'enfant apprend un mot, pas une règle.
- **Idée d'image** : un dessin vectoriel simple, sans aucun texte dedans, car beaucoup d'enfants ne lisent pas encore bien le français.
- **Exemple** : une situation du quotidien au Sénégal (marché, francs, mangues, car rapide, Tabaski, thé), avec Awa, Moussa, Fatou, Mamadou, Aminata ou Ibrahima. Les objets se comptent en petits nombres ; les sommes sont des montants ronds en francs CFA (multiples de 25, 50 ou 100).
- **Explication en wolof** et **Exemple en wolof** : vides. Le propriétaire les remplit ; le rédacteur n'écrit aucun wolof.
- **Forme dans l'exemple** : le mot tel qu'il est écrit dans la phrase d'exemple (« reste » dans « Il lui reste 6 mangues »). L'app s'en sert pour rendre le mot touchable dans la phrase ; il doit apparaître dans l'exemple. Pas de wolof ici. **Après toute modification de ce tableau, lancer `python3 tool/build_math_words.py`** : la vérification de `tool/check.sh` échoue tant que le fichier de données de l'app n'est pas refait.
- **Audio : explication** et **Audio : exemple** : les noms attendus des deux fichiers, fixés par la clé. Ne pas les changer.

## 1. Les mots et expressions

Quarante mots et expressions, en six familles.

### Ajouter

| Clé | Mot ou expression | Sens simple | Idée d'image | Exemple | Forme dans l'exemple | Explication en wolof | Exemple en wolof | Audio : explication | Audio : exemple |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `ajouter` | ajouter | Mettre quelque chose en plus de ce que tu as déjà. | Un panier avec 4 mangues ; 3 autres mangues tombent dedans. | Au marché, Awa a 4 mangues. Elle en ajoute 3 à son panier. | ajoute | Dafa teg lu gën ci lu nga am. (machine, à relire) | Awa am na ñeenti mango ci suufe bi. (machine, à relire) | `wo_ajouter.m4a` | `wo_ajouter_exemple.m4a` |
| `en_plus` | en plus | Tu as déjà des choses, et on t'en donne encore. | Un panier avec 6 mangues ; 4 autres mangues arrivent à côté, en plus. | Fatou a 6 mangues. Sa tante lui en donne 4 en plus. | en plus | Dafa nga am ay yëf, te dinañuy wax tamit ay yëf. (machine, à relire) | Fatou am na juróom benni mangoo, ak sa xarit di ko jox ñeent yu ëpp. (machine, à relire) | `wo_en_plus.m4a` | `wo_en_plus_exemple.m4a` |
| `en_tout` | en tout | Le nombre que tu obtiens en comptant toutes les parties. | Des petits tas de mangues qui se rejoignent dans un seul grand tas ; on regarde le tas final, sans rien d'écrit. | Le matin, Ibrahima achète 3 mangues ; le soir, il en achète 4. Il en a 7 en tout. | en tout | Xale bi nga jële bu nga xeex mboolem cér yi. (machine, à relire) | Ibraayma jënd na ñetti njaam ci suba bi, ñeenti njaam ci guddi bi, ba juróom-ñaari. (machine, à relire) | `wo_en_tout.m4a` | `wo_en_tout_exemple.m4a` |
| `ensemble` | ensemble | Réunir des choses au même endroit. | Deux groupes de billes, rouges et bleues, qui entrent dans la même boîte. | Aminata met ensemble 8 billes rouges et 6 billes bleues dans une boîte. | ensemble | Jëfandikoo yëf yi ci benn bérab. (machine, à relire) | Aminata daal na juróom-ñeen ball yu xumb ak juróom-ñeen ball yu xumb ci benn bokk. (machine, à relire) | `wo_ensemble.m4a` | `wo_ensemble_exemple.m4a` |
| `gagner` | gagner | Tu reçois de l'argent ou des points en plus de ce que tu avais. | Une pièce qui tombe dans une tirelire déjà pleine de pièces. | Moussa lave une voiture et gagne 500 francs. | gagne | Dinaa jot ay xaalis walla ay xët yu gën a bare ci li nga am. (machine, à relire) | Moussa dafa sàkk oto te am juróomi téeméeri frank. (machine, à relire) | `wo_gagner.m4a` | `wo_gagner_exemple.m4a` |
| `recevoir` | recevoir | Quelqu'un te donne quelque chose : tu en as plus qu'avant. | Une seule personne au centre ; son panier se remplit de mangues venues de l'extérieur du dessin. | Mamadou reçoit 100 francs de son oncle pour acheter du thé. | reçoit | Am na ku la jox dara: nga am na lu gën a réy. (machine, à relire) | Mamadou di jël ay téeméeri francs ci baayam ngir jënd té. (machine, à relire) | `wo_recevoir.m4a` | `wo_recevoir_exemple.m4a` |
| `augmenter` | augmenter | Devenir plus grand ou plus cher : le nombre monte. | Une étiquette de prix vide, avec une flèche qui monte vers le haut. | Le pain coûte 150 francs. Son prix augmente de 50 francs. | augmente | Bëj-gànnaay bu mag mbaa bu màgg: ñu gën a màgg. (machine, à relire) | Jëf bu ñu sàkk di téeméer ak juróom-ñaari frank, te lu ñu sàkk di téeméer ak juróom-ñaari frank. (machine, à relire) | `wo_augmenter.m4a` | `wo_augmenter_exemple.m4a` |

### Enlever

| Clé | Mot ou expression | Sens simple | Idée d'image | Exemple | Forme dans l'exemple | Explication en wolof | Exemple en wolof | Audio : explication | Audio : exemple |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `enlever` | enlever | Prendre des choses et les sortir du groupe : il en reste moins. | Un tas de billes ; 3 billes sortent du tas et tombent à côté. | Au marché, la vendeuse enlève 2 mangues abîmées du panier. | enlève | Jëfandikoo ay jëfandikoo ngir génne ko ci jëfandikukat bi: amoon na lu néew. (machine, à relire) | Ci suucu bi, jaaykat bi jël ñaari mango yu yàq yu bari ci kas. (machine, à relire) | `wo_enlever.m4a` | `wo_enlever_exemple.m4a` |
| `il_reste` | il reste | Ce qui n'est pas parti : ce qui est encore là après avoir enlevé. | Un panier de 10 mangues ; 4 mangues sortent, 6 restent dans le panier. | Aminata a 10 mangues. Elle en vend 4 au marché. Il lui reste 6 mangues. | reste | Li mu dul dem, mooy li mu jële. (machine, à relire) | Aminata am na fukki mangoo. Mu tàkk na ñeenti mangoo ca bérab bi, ba noppi am na juróom-ñetti mangoo. (machine, à relire) | `wo_il_reste.m4a` | `wo_il_reste_exemple.m4a` |
| `retirer` | retirer | Prendre une partie et la mettre à part. | Une main qui prend 2 billes dans un tas et les pose à côté. | Ibrahima retire 150 francs de sa tirelire pour acheter un pain. | retire | Jël-leen benn wàllu, di ko wàcc. (machine, à relire) | Ibraayma génne na ci ay téeméer ak juróom-ñaari frank ci ay xaalisam, ngir jënd mburu. (machine, à relire) | `wo_retirer.m4a` | `wo_retirer_exemple.m4a` |
| `vendre` | vendre | Donner quelque chose à quelqu'un qui te paie : ce n'est plus à toi, mais tu reçois de l'argent. | Une vendeuse tend 4 mangues à une cliente, qui lui tend une pièce en échange. | Aminata vend 5 sachets d'eau au marché. | vend | Xam nga lu nga jële ci lu nga jële, te du sa bopp, waaye nga jot xaalis. (machine, à relire) | Aminata di jaay juróomi jaatu ndox ci suulet bi. (machine, à relire) | `wo_vendre.m4a` | `wo_vendre_exemple.m4a` |
| `donner` | donner | Passer quelque chose à quelqu'un : celui qui donne en a moins, celui qui reçoit en a plus. | Deux personnes : celle de gauche tend 2 mangues, son panier se vide ; celle de droite les prend. | Fatou donne 2 mangues à sa petite sœur. | donne | Kon nag, ku jox, am na lu néew, te ku jot, am na lu bare. (machine, à relire) | Fatou jox na sa jigéen ju ndaw ñaari mangue. (machine, à relire) | `wo_donner.m4a` | `wo_donner_exemple.m4a` |
| `perdre` | perdre | Ne plus avoir quelque chose que tu avais. | Un sac ouvert, une bille qui tombe par terre. | Mamadou perd 3 billes pendant le jeu. | perd | Duñu am lu nga amoon. (machine, à relire) | Mamadou ñàkk na ñetti ball ci biir xëtu. (machine, à relire) | `wo_perdre.m4a` | `wo_perdre_exemple.m4a` |
| `acheter` | acheter | Donner de l'argent pour avoir quelque chose : tu as une chose de plus, mais moins d'argent. | Une cliente tend des pièces à la vendeuse et reçoit 3 mangues : son porte-monnaie se vide, son panier se remplit. | Au marché, Moussa achète 3 mangues avec ses 500 francs. Il a 3 mangues de plus, mais moins d'argent. | achète | Jëfandikoo xaalis ngir am lu nga am; nga am lu ëpp, waaye xaalis gu néew. (machine, à relire) | Moussa jënd na ñetti mango ak juróomi téeméeri frank, te am na ñetti mangoo yu ëpp, waaye ñàkk xaalis. (machine, à relire) | `wo_acheter.m4a` | `wo_acheter_exemple.m4a` |

### Comparer

| Clé | Mot ou expression | Sens simple | Idée d'image | Exemple | Forme dans l'exemple | Explication en wolof | Exemple en wolof | Audio : explication | Audio : exemple |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `de_plus_que` | de plus que | Une des deux quantités est plus grande que l'autre. Pour savoir quoi faire, lis bien la question. | Deux barres de hauteurs différentes ; la plus haute dépasse l'autre de 3 cases. | Awa a 12 mangues. Moussa en a 9. Awa en a 3 de plus que lui. | de plus que | Kenn ci ñaari taxawaay yi moo gën a màgg. (machine, à relire) | Awa am na fukk ak ñaar, Musaa am na juróom-ñeen, Awa am na ñetti. (machine, à relire) | `wo_de_plus_que.m4a` | `wo_de_plus_que_exemple.m4a` |
| `de_moins_que` | de moins que | Une des deux quantités est plus petite que l'autre. Pour savoir quoi faire, lis bien la question. | Deux barres ; la barre du bas est plus courte de 4 cases. | Fatou a 500 francs. Aminata en a 100 de moins que Fatou. | de moins que | Kenn ci ñaari taxawaay yi gën a ndaw, ngir xam lu nga def, jàngal ci laaj bi. (machine, à relire) | Fatou am na juróomi téeméeri frank. Aminata am na ci téeméeri frank ci Fatou. (machine, à relire) | `wo_de_moins_que.m4a` | `wo_de_moins_que_exemple.m4a` |
| `autant_que` | autant que | Il y a la même quantité des deux côtés. | Deux tas de billes de même hauteur, côte à côte. | Ibrahima a autant de billes que Mamadou : ils en ont 7 chacun. | autant | Am na noonu ci ñaari wàllu yi. (machine, à relire) | Ibraahiima am na juróom ñaari ball yu mel ni Mamadu. (machine, à relire) | `wo_autant_que.m4a` | `wo_autant_que_exemple.m4a` |
| `le_plus_grand` | le plus grand | Celui qui a la plus grande quantité, parmi tous. | Trois tas de tailles différentes ; le plus haut est entouré d'un cercle. | Au jeu de billes, Mamadou a le plus grand tas : 9 billes. | le plus grand | Ku am lu bare ci ñoom ñépp. (machine, à relire) | Ci jokkoo ball yi, Mamadou am na lu gën a màgg: juróom-ñaari ball. (machine, à relire) | `wo_le_plus_grand.m4a` | `wo_le_plus_grand_exemple.m4a` |
| `le_plus_petit` | le plus petit | Celui qui a la plus petite quantité, parmi tous. | Trois tas de tailles différentes ; le plus bas est entouré d'un cercle. | Parmi trois sacs de mangues, Aminata prend le plus petit : elle contient 3 mangues. | le plus petit | Ku am gën a ndaw ci ñoom ñépp. (machine, à relire) | Aminata jël ca ñetti sàkku mango yi gën a ndaw: dafa am ñetti mango. (machine, à relire) | `wo_le_plus_petit.m4a` | `wo_le_plus_petit_exemple.m4a` |
| `difference` | la différence | Ce qui sépare deux quantités : la partie en plus de la plus grande. | Deux paniers côte à côte ; dans le plus rempli, la partie en trop est en couleur. | Mamadou a 9 mangues dans son panier, et Moussa en a 4. Quelle est la différence entre leurs paniers ? | différence | Li di séddoo ñaari jëfandikukat yi: ci lu gën a màgg. (machine, à relire) | Mamadou am na juróom-ñeen mbëj ci sàrtam, Moussa am na ñeenti mbëj. (machine, à relire) | `wo_difference.m4a` | `wo_difference_exemple.m4a` |
| `egal` | égal | Les deux quantités sont les mêmes : rien ne dépasse. | Deux tas de même taille, côte à côte, avec le même nombre de cases remplies. | Fatou a 5 mangues et Ibrahima en a 5 aussi : leurs tas sont égaux. | égaux | Ñaareel xaalis yi amoon nañu noonu: kenn du gën. (machine, à relire) | Fatou am na juróomi mangoo, Ibraahiima am na juróomi mangoo itam. (machine, à relire) | `wo_egal.m4a` | `wo_egal_exemple.m4a` |

### Grouper

| Clé | Mot ou expression | Sens simple | Idée d'image | Exemple | Forme dans l'exemple | Explication en wolof | Exemple en wolof | Audio : explication | Audio : exemple |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `par_paquets_de` | par paquets de | Des objets rangés en paquets, avec le même nombre dans chaque paquet. | Trois paquets ouverts, avec 4 biscuits dessinés dans chacun. | Au marché, Aminata achète des biscuits par paquets de 3. Elle prend 5 paquets. | par paquets de | Jëfandikukat yu ñu sàkk, ak lim yu njëkk ci benn sàkk. (machine, à relire) | Aminata di jënd biscoot yi ci ñetti xëtu. (machine, à relire) | `wo_par_paquets_de.m4a` | `wo_par_paquets_de_exemple.m4a` |
| `chacun` | chacun | Pour chaque personne ou chaque chose, la même quantité. | Quatre enfants, et devant chacun le même petit tas de 3 billes. | Pour la fête, les 4 enfants reçoivent chacun 3 billes. | chacun | Ku nekk mbaa lu nekk, lu mel noonu. (machine, à relire) | Ci njariñ bi, ñeenti doom yi, kenn ci ñoom, jot na ñetti ball. (machine, à relire) | `wo_chacun.m4a` | `wo_chacun_exemple.m4a` |
| `fois` | fois | Répéter le même nombre plusieurs fois : 4 fois 6, ce sont 4 groupes de 6. | Quatre petits tas de 6 billes, alignés. | Pour l'attaya, Mamadou prépare 4 théières et met 2 morceaux de sucre dans chaque théière : 4 fois 2 morceaux. | fois | Jëfalu ko lu mel noonu lu ëpp yoon: ñeenti yoon ci juróom-ñeent, ñeent ci juróom-ñeent. (machine, à relire) | Mamadou def na ñeenti téer, teg ca nekk ñaari coppite sukk, ñeenti coppite ñaari coppite. (machine, à relire) | `wo_fois.m4a` | `wo_fois_exemple.m4a` |
| `dans_chaque` | dans chaque | Le même nombre se répète dans chacun des groupes. | Trois boîtes ouvertes, chacune avec 6 mangues dessinées. | Dans chaque panier, Fatou range 6 mangues. Elle a 3 paniers. | Dans chaque | Amoon na ci ñeneen ci ñeneen. (machine, à relire) | Fatou dafa sàkk juróom benni mandor ci benn sàq, am na ñetti sàq. (machine, à relire) | `wo_dans_chaque.m4a` | `wo_dans_chaque_exemple.m4a` |
| `rangee` | une rangée de | Des objets alignés en ligne, avec le même nombre dans chaque ligne. | Une cour avec 4 rangées de 6 chaises, dessinées en lignes droites. | Pour la Tabaski, il y a 4 rangées de 6 chaises dans la cour. | rangées | Jëfandikukat yi ñu wàcce ci wàll, ak lim gu mel ci wàll gu nekk. (machine, à relire) | Ci Tabaski, am na ñeent taxawaay yu tollook juróom-ñeent ci kër gi. (machine, à relire) | `wo_rangee.m4a` | `wo_rangee_exemple.m4a` |
| `double` | le double | Deux fois la même quantité. | Un tas de 6 billes, et un autre tas identique à côté. | Mamadou a 6 mangues. Moussa en a le double : 12 mangues. | le double | Ñaari yoon. (machine, à relire) | Mamadu am na juróom-ñeen mango, Musaa am na ñaar: fukki mango. (machine, à relire) | `wo_double.m4a` | `wo_double_exemple.m4a` |

### Partager

| Clé | Mot ou expression | Sens simple | Idée d'image | Exemple | Forme dans l'exemple | Explication en wolof | Exemple en wolof | Audio : explication | Audio : exemple |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `partager` | partager | Couper une quantité en parts pour que chacun ait sa part. | Un grand plat de 12 mangues ; à côté, 3 assiettes vides. | Mamadou partage ses 12 mangues entre 3 amis. | partage | Jëf-jëf bu ñu séddoo, ngir ku nekk am seen cér. (machine, à relire) | Mamadu di séddoo ay fukki mangoom ci ñetti xaritam. (machine, à relire) | `wo_partager.m4a` | `wo_partager_exemple.m4a` |
| `partager_egalement` | partager également | Donner à chacun la même part, sans en garder plus pour soi. | Trois assiettes de même taille, avec le même nombre de mangues dans chacune. | Mamadou partage également ses 12 mangues entre 3 amis : chacun en reçoit 4. | partage également | Jëfleen ñépp ci lu mat sëriñ, te bañ a sàkk lu mat sëriñ. (machine, à relire) | Mamadou di séddoo ay fukki mangoom itam ci ñetti xarit: ku nekk di jot ñeent. (machine, à relire) | `wo_partager_egalement.m4a` | `wo_partager_egalement_exemple.m4a` |
| `repartir` | répartir | Mettre une quantité dans plusieurs endroits, en parts égales. | Des billes qui tombent dans 4 sacs, un sac après l'autre. | Ibrahima répartit 20 billes dans 4 sacs, le même nombre dans chaque sac. | répartit | Sëriñ bi dafa wax ne: (machine, à relire) | Ibraayma daldi séddoo téeméeri xànk ci ñeenti xànk, ci benn xànk. (machine, à relire) | `wo_repartir.m4a` | `wo_repartir_exemple.m4a` |
| `par_personne` | par personne | Ce que reçoit chaque personne d'une même quantité. | Un plat de 12 mangues, 4 personnes autour ; une part pour chacun. | Pour le goûter, il y a 12 mangues pour 4 enfants. Combien de mangues par personne ? | par personne | Li nit ku nekk jot ci noonu. (machine, à relire) | Ndax am na fukki mango ci ñeent doomam. Ñaata mango ci nit? (machine, à relire) | `wo_par_personne.m4a` | `wo_par_personne_exemple.m4a` |
| `diviser` | diviser | Partager en parts égales. | Une barre coupée en 3 morceaux égaux. | Aminata veut diviser ses 15 billes en 3 tas égaux. | diviser | Jëf-jëf-jëf. (machine, à relire) | Aminata bëggoon a séddale ay 15 ballam ci ñetti benn. (machine, à relire) | `wo_diviser.m4a` | `wo_diviser_exemple.m4a` |
| `moitie` | la moitié | Une des deux parts égales d'un tout, si tu le coupes en deux. | Une mangue coupée en deux morceaux identiques. | Fatou a 14 mangues et en donne la moitié à Aminata. | la moitié | Kenn ci ñaari wàll yu mel ni benn, su nga jël ci ñaari wàll. (machine, à relire) | Fatou am na fukk ak ñeenti mangoo, jox Aminata genn-wàll. (machine, à relire) | `wo_moitie.m4a` | `wo_moitie_exemple.m4a` |
| `quart` | un quart | Une des quatre parts égales d'un tout, si tu le coupes en quatre. | Un gâteau rond coupé en 4 parts égales, une part à côté. | Moussa a 8 billes. Il en donne un quart à Ibrahima : 2 billes. | un quart | Kenn ci ñeenti cér yu mel ni benn, su nga jële ko ci ñeent. (machine, à relire) | Moussa am na juróom ñetti xànk, jox Ibraayma ñeent fukk, ñaari xànk. (machine, à relire) | `wo_quart.m4a` | `wo_quart_exemple.m4a` |

### Questions

Ces mots disent ce qu'on cherche, ou quand ça se passe.

| Clé | Mot ou expression | Sens simple | Idée d'image | Exemple | Forme dans l'exemple | Explication en wolof | Exemple en wolof | Audio : explication | Audio : exemple |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `combien` | combien | Tu demandes une quantité : tu cherches un nombre. | Un point d'interrogation à côté d'un tas de mangues. | Au marché, une cliente demande : combien coûtent les mangues ? | combien | Dinaa laaj lu bare: nga ngi wut lu bare. (machine, à relire) | Ci suulet bi, ku nekk laaj na ne: luy jële mango yi? (machine, à relire) | `wo_combien.m4a` | `wo_combien_exemple.m4a` |
| `combien_de_fois` | combien de fois | Chercher combien de paquets de même taille on peut faire avec un nombre donné. | Une barre de 12 cases, coupée en morceaux de 3 cases. | Aminata a 12 billes. Combien de fois peut-elle faire un tas de 3 billes ? | Combien de fois | Jëfandikoo ci lu ëpp ci ay xët yu mel ni ñoom, ngir mën a jëfandikoo lu ëpp ci lu ëpp. (machine, à relire) | Aminata am na fukk ak ñaar. (machine, à relire) | `wo_combien_de_fois.m4a` | `wo_combien_de_fois_exemple.m4a` |
| `total` | le total | Le résultat de tout ce qu'on a réuni ou compté. | Un reçu de marché : quelques lignes d'achats, puis une ligne tout en bas, soulignée. | Ibrahima a acheté 3 mangues le matin et 4 le soir. Quel est le total ? | le total | Li mu am ci lépp lu nu boole, mbaa lu nu teg. (machine, à relire) | Ibrahima jënd na ñetti mango ci suba ak ñeenti mango ci guddi. (machine, à relire) | `wo_total.m4a` | `wo_total_exemple.m4a` |
| `au_depart` | au départ | Au tout début, avant ce qui change. | Première image de l'histoire, tout à gauche : le panier au tout début, avant tout changement. | Au départ, Mamadou a 500 francs. | Au départ | Ci njàlbéen bu jëkk, ba noppi lu dul tollu. (machine, à relire) | Ci njàlbéen bi, Mamadou am na juróomi téeméeri frank. (machine, à relire) | `wo_au_depart.m4a` | `wo_au_depart_exemple.m4a` |
| `a_la_fin` | à la fin | Après tout ce qui s'est passé, à la dernière étape. | Dernière image de l'histoire, tout à droite : le même panier quand tout est fini. | À la fin de la journée, Fatou a 9 mangues. | À la fin | Bi loolu wéyee, ci wàllu mujj. (machine, à relire) | Ba bés ba wéyee, Fatou am na ci juróom-ñaari mango. (machine, à relire) | `wo_a_la_fin.m4a` | `wo_a_la_fin_exemple.m4a` |
| `apres` | après | Ce qui arrive plus tard, une fois qu'une chose est passée. | Une image du milieu de l'histoire, qui vient après une autre (une flèche relie les deux) : ni la première, ni la dernière. | Après le marché, Awa rentre à la maison avec 3 mangues. | Après | Li ci ëllëg, ci lu jëm ci lu jëm ci lu yàgg. (machine, à relire) | Bi ñu sàkk, Awa dugal këram ak ñetti mango. (machine, à relire) | `wo_apres.m4a` | `wo_apres_exemple.m4a` |

## 2. Glossaire de cohérence

Une notion, un mot wolof : le propriétaire note ici le mot wolof retenu pour chaque notion, avant d'enregistrer. Ainsi, les explications qui parlent de la même chose utilisent le même mot. Une notion peut regrouper plusieurs clés. La colonne « Situation » sert au développeur et à la relecture ; elle n'est jamais dite à l'enfant.

| Notion | Situation | Clés | Mot wolof retenu |
| --- | --- | --- | --- |
| Ajouter, réunir | réunir | `ajouter`, `en_plus`, `ensemble`, `gagner`, `recevoir`, `augmenter` | |
| Total | réunir | `en_tout`, `total` | |
| Enlever, retirer, perdre | retirer | `enlever`, `retirer`, `vendre`, `donner`, `perdre`, `acheter` | |
| Ce qui reste | retirer | `il_reste` | |
| Différence | comparer | `difference` | |
| Plus que, moins que | comparer | `de_plus_que`, `de_moins_que` | |
| Même quantité | comparer | `autant_que`, `egal` | |
| Le plus grand, le plus petit | comparer | `le_plus_grand`, `le_plus_petit` | |
| Groupes égaux | groupes égaux | `par_paquets_de`, `dans_chaque`, `rangee`, `fois`, `double` | |
| Chacun | groupes égaux ou partage | `chacun` | |
| Partage égal | partage | `partager`, `partager_egalement`, `repartir`, `diviser`, `par_personne` | |
| Moitié, quart | partage | `moitie`, `quart` | |
| Demander combien | question | `combien`, `combien_de_fois` | |
| Début, fin, après | suivre l'histoire | `au_depart`, `a_la_fin`, `apres` | |

## 3. Énoncés « Quelle opération ? » (F28-09)

Vingt énoncés courts, lus à voix haute (F23). L'enfant choisit +, −, × ou ÷ sans calculer. Beaucoup contiennent un mot qui fait penser à une autre situation : « de plus » fait penser à réunir, alors qu'il peut s'agir de comparer. Ces pièges ne sont pas des règles à apprendre ; ils montrent qu'il faut lire l'histoire. Les sommes sont des montants ronds en francs CFA, comme au marché (multiples de 25, 50 ou 100 francs), validés par le propriétaire.

La colonne « Clés » renvoie à la section 1. La colonne « Piège » sert au développeur et à la relecture, pas à l'enfant.

| Id | Énoncé | Opération | Clés | Piège |
| --- | --- | --- | --- | --- |
| OP-01 | Awa a 4 mangues. Elle en achète 3 au marché. Combien de mangues a-t-elle en tout ? | + | `en_tout`, `combien` | Aucun piège : Awa reçoit encore des mangues, la quantité grandit. |
| OP-02 | Aminata achète 5 paquets. Dans chaque paquet, il y a 3 biscuits. Combien de biscuits a-t-elle en tout ? | × | `dans_chaque`, `en_tout`, `combien` | « en tout » fait penser à réunir, mais ici il y a 5 paquets de même taille : des groupes égaux. |
| OP-03 | Ibrahima a 10 mangues. Il en vend 4 au marché. Combien de mangues lui reste-t-il ? | − | `vendre`, `il_reste`, `combien` | Aucun piège : des mangues sortent du panier, la quantité diminue. |
| OP-04 | Il y a 12 mangues pour 4 enfants. Combien de mangues par personne ? | ÷ | `par_personne`, `combien` | « par » fait penser à des groupes égaux (comme « par paquets de »), mais ici 12 mangues sont partagées entre 4 enfants : c'est un partage. |
| OP-05 | Mamadou a 6 billes. On lui en donne 4 en plus. Combien de billes a-t-il maintenant ? | + | `en_plus`, `donner`, `combien` | « donner » fait penser à retirer, mais Mamadou reçoit : on réunit ce qu'il avait et ce qu'il reçoit. |
| OP-06 | Awa a 12 mangues. Elle en a 3 de plus que Moussa. Combien Moussa en a-t-il ? | − | `de_plus_que`, `combien` | « de plus » fait penser à réunir, mais on compare deux quantités : il faut retirer l'écart de ce qu'Awa a. |
| OP-07 | Au marché, Fatou a 4 tas de 6 mangues. Combien de mangues a-t-elle ? | × | `combien` | « tas de 6 » ne dit pas la situation : 4 tas de même taille, ce sont des groupes égaux. |
| OP-08 | Ibrahima a 15 billes. Il les range en 3 tas égaux. Combien de billes y a-t-il dans chaque tas ? | ÷ | `dans_chaque`, `combien` | « dans chaque » fait penser à des groupes égaux (voir OP-02), mais ici 15 billes sont réparties en 3 tas égaux : c'est un partage. |
| OP-09 | Mamadou a 9 billes. Il en perd 2 au jeu. Combien en a-t-il après ? | − | `perdre`, `apres`, `combien` | Aucun piège : des billes partent au jeu, la quantité diminue. |
| OP-10 | Aminata a 300 francs. Elle en a 100 de moins que Fatou. Combien Fatou en a-t-elle ? | + | `de_moins_que`, `combien` | « de moins » fait penser à retirer, mais Fatou a la plus grande somme : il faut réunir l'écart avec ce qu'Aminata a. |
| OP-11 | Pour la Tabaski, il y a 3 rangées de 5 chaises dans la cour. Combien de chaises y a-t-il ? | × | `rangee`, `combien` | Aucun piège : des rangées de même taille, ce sont des groupes égaux. |
| OP-12 | Moussa a 14 mangues et en donne la moitié à Ibrahima. Combien Ibrahima en reçoit-il ? | ÷ | `moitie`, `donner`, `combien` | « donne » fait penser à retirer, mais on cherche la part qu'Ibrahima reçoit : c'est un partage. |
| OP-13 | Dans le panier d'Aminata, il y a 9 mangues. Dans celui de Fatou, il y en a 4. Quelle est la différence entre les deux paniers ? | − | `difference` | Aucun piège : on compare deux paniers ; le mot « différence » doit être connu de l'enfant. |
| OP-14 | Ibrahima a 200 francs. Il gagne 500 francs en lavant une voiture. Combien a-t-il maintenant ? | + | `gagner`, `combien` | Aucun piège : une somme s'ajoute à une autre, on réunit. |
| OP-15 | Au départ, le pain coûte 150 francs. Son prix augmente de 50 francs. Combien coûte-t-il à la fin ? | + | `au_depart`, `augmenter`, `a_la_fin`, `combien` | « au départ » et « à la fin » ne disent pas la situation : le prix monte, on réunit la hausse au prix de départ. |
| OP-16 | Dans le car rapide, il y a 14 personnes. 6 personnes descendent. Il reste combien de personnes dans le car ? | − | `il_reste`, `combien` | Aucun piège : des personnes sortent du car, la quantité diminue. |
| OP-17 | Awa a 6 mangues. Moussa en a 4 fois plus. Combien Moussa en a-t-il ? | × | `fois`, `combien` | « plus » fait penser à comparer, mais Moussa a 4 fois la quantité d'Awa : ce sont des groupes égaux. |
| OP-18 | Awa a 12 mangues. Elle les met en parts égales pour ses 3 amis. Combien chacun reçoit-il de mangues ? | ÷ | `chacun`, `combien` | « chacun » fait penser à des groupes égaux, mais ici 12 mangues sont réparties entre 3 amis : c'est un partage. |
| OP-19 | Chacun des 4 enfants reçoit 3 billes. Combien de billes faut-il en tout ? | × | `chacun`, `en_tout` | « chacun » fait penser au partage, et « en tout » à réunir ; ici chaque enfant reçoit la même quantité : des groupes égaux. |
| OP-20 | Awa a 12 billes. Combien de fois peut-elle faire un tas de 3 billes ? | ÷ | `combien_de_fois` | « combien de fois » fait penser à des groupes égaux, mais ici on cherche combien de tas on peut faire avec les billes : c'est un partage. |

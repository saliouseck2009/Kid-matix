# App Store — catégorie Enfants, classification et confidentialité

> **Brouillon à valider par le propriétaire (tâche F11-09).** Réponses
> proposées pour App Store Connect, d'après ce que fait réellement la
> version 1.0. Les intitulés des questions sont résumés ; vérifier leur
> formulation exacte au moment de remplir. Faits techniques :
> `docs/release/audit-1.0.md`.

## Informations de l'app

| Champ | Réponse proposée |
| --- | --- |
| Nom | Kid Matix |
| Langue principale | Français |
| Catégorie principale | Éducation |
| Catégorie secondaire | Jeux (sous-catégories : Éducatif, Famille) |
| Prix | Gratuit |
| Achats intégrés | Aucun |
| URL de la politique de confidentialité | [adresse publique de `docs/store/privacy-policy.md`, à héberger] |

## Catégorie Enfants

| Question | Réponse proposée |
| --- | --- |
| Faire figurer l'app dans la catégorie Enfants | Oui |
| Tranche d'âge (une seule) | **6 à 8 ans** — voir la question ouverte plus bas |

**Choix de la tranche.** Apple propose trois tranches : 5 ans et moins, 6 à
8 ans, 9 à 11 ans, et n'en retient qu'une. Les spécifications visent les 6 à
11 ans, « à partir de 6 ans », avec peu de texte à lire : la tranche 6 à
8 ans correspond à l'âge où l'on commence les tables (CE1, CE2). La tranche
9 à 11 ans (CM1, CM2) serait aussi défendable. À trancher par le
propriétaire. Attention : la catégorie Enfants, une fois choisie, ne peut
plus être retirée de l'app.

### Règles de la catégorie Enfants et état de la version 1.0

| Règle (Guidelines 1.3 et 5.1.4) | Kid Matix 1.0 |
| --- | --- |
| Pas de liens vers l'extérieur, d'achats ni de sollicitations sans contrôle parental | Aucun lien, aucun achat, aucune sollicitation : pas de contrôle parental nécessaire |
| Pas d'outils d'analyse ni de publicité de tiers | Aucun |
| Pas d'envoi de données personnelles ou d'informations sur l'appareil à des tiers | Rien n'est envoyé : aucune connexion réseau |
| Politique de confidentialité publiée | Brouillon prêt, à héberger |
| Respect des lois sur les données des enfants (COPPA, RGPD) | Aucune collecte ; le pseudo reste sur l'appareil |
| Pas de demande d'autorisation sans nécessité | Aucune autorisation demandée (pas de photo, micro, localisation, suivi) |

## Confidentialité de l'app (« étiquette de confidentialité »)

| Question | Réponse proposée |
| --- | --- |
| Collectez-vous des données à partir de cette app ? | **Non, nous ne collectons pas de données** |
| Résultat affiché sur la fiche | « Aucune donnée collectée » |
| Suivi (App Tracking Transparency) | Aucun suivi ; pas de demande d'autorisation de suivi |

Pour Apple, une donnée est « collectée » quand elle est transmise hors de
l'appareil. Le pseudo et la progression restent sur l'appareil.

**Point lié à l'audit** : la base de données du jeu est aujourd'hui incluse
dans la sauvegarde iCloud de l'appareil. Cette sauvegarde appartient à
l'utilisateur et n'est pas une collecte au sens d'Apple, mais la politique de
confidentialité doit rester cohérente avec le choix fait (voir
`docs/release/audit-1.0.md`, point 3).

## Classification par âge (questionnaire)

| Thème | Réponse proposée |
| --- | --- |
| Violence de dessin animé ou fantastique | **À trancher** : « Aucune » ou « Rare/légère » (voir plus bas) |
| Violence réaliste | Aucune |
| Violence réaliste prolongée, sang | Aucune |
| Contenu effrayant ou d'horreur | Aucun |
| Contenu sexuel, nudité | Aucun |
| Grossièretés, humour cru | Aucun |
| Alcool, tabac, drogue | Aucun |
| Thèmes médicaux | Aucun |
| Jeux d'argent simulés, concours | Aucun |
| Accès libre au Web | Non |
| Contenu généré par les utilisateurs, messagerie | Non |
| Contrôles parentaux, vérification de l'âge | Non (pas nécessaires) |
| Classification attendue | 4+ |

**Violence de dessin animé, à trancher.** À la dernière étape de chaque
table, l'enfant « combat » le monstre de la table en répondant juste : chaque
bonne réponse lui retire des points de vie, une erreur le fait « riposter » à
l'écran sans rien coûter à l'enfant. Ni sang, ni arme, ni personnage humain
blessé. Garder la même réponse que sur Google Play
(`docs/store/play-families.md`). Vérifier dans App Store Connect la
classification qu'entraîne « Rare/légère » : elle doit rester compatible avec
la catégorie Enfants.

## Autres réponses à l'envoi

| Question | Réponse proposée |
| --- | --- |
| Chiffrement (export compliance) | L'app n'utilise pas de chiffrement soumis à déclaration ; ajouter `ITSAppUsesNonExemptEncryption = NO` dans `Info.plist` (audit, point 6) |
| Connexion requise pour la revue | Non : aucun compte ; préciser dans les notes de revue « Hors ligne, aucun compte. Au premier lancement, créer un joueur avec un pseudo. » |
| Identifiant publicitaire (IDFA) | Non utilisé |
| Contenu de tiers | Polices Fredoka et Nunito (licence SIL Open Font License, à confirmer sur fonts.google.com), incluses dans l'app |

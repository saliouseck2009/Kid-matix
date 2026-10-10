# Google Play — public cible, contenu et sécurité des données

> **Brouillon à valider par le propriétaire (tâche F11-09).** Réponses
> proposées pour les formulaires de la Play Console (rubrique « Contenu de
> l'application »), d'après ce que fait réellement la version 1.0. Les
> intitulés des questions sont résumés ; vérifier leur formulation exacte
> dans la console au moment de remplir. Faits techniques :
> `docs/release/audit-1.0.md`.

## Fiche de l'application

| Champ | Réponse proposée |
| --- | --- |
| Nom de l'application | Kid Matix |
| Application ou jeu | Jeu |
| Catégorie | Éducatif (jeux) — à défaut, Enseignement (applications) |
| Gratuite ou payante | Gratuite |
| Langue par défaut | Français (France) – fr-FR |

## Règles de confidentialité

- URL de la politique de confidentialité : [adresse publique de
  `docs/store/privacy-policy.md`, à héberger].

## Accès à l'application

- Toutes les fonctionnalités sont disponibles sans identifiant ni accès
  particulier : **oui**. Aucun compte, aucune connexion.

## Annonces

- L'application contient-elle des annonces ? **Non.**

## Classification du contenu (questionnaire IARC)

| Question | Réponse proposée | Justification |
| --- | --- | --- |
| Catégorie | Jeu | |
| Violence | **À trancher** (voir plus bas) | Combat de boss contre un monstre dessiné |
| Peur, contenu effrayant | Non | Monstres dessinés dans un style enfantin, pas de scène effrayante |
| Sexualité, nudité | Non | |
| Langage grossier | Non | |
| Substances (drogue, alcool, tabac) | Non | |
| Jeux d'argent, simulés ou réels | Non | |
| Interaction entre utilisateurs (chat, échanges) | Non | Plusieurs profils sur un même appareil, sans aucun échange |
| Partage de la position | Non | |
| Achats numériques | Non | |
| Contenu généré par les utilisateurs et partagé | Non | Le pseudo reste sur l'appareil |
| Navigateur web ou accès libre à Internet | Non | Aucune connexion réseau |

**Violence, à trancher.** À la dernière étape de chaque table, l'enfant
« combat » le monstre de la table : chaque bonne réponse lui retire des
points de vie (« Touché ! −1 »), une erreur le fait « riposter » à l'écran,
sans rien coûter à l'enfant ; vaincu, le monstre rejoint la collection, sinon
il s'enfuit. Ni sang, ni arme réaliste, ni personnage humain blessé.

- Réponse prudente : « violence fantastique ou de dessin animé, légère ».
  Elle peut faire passer la classification de PEGI 3 à PEGI 7.
- Réponse minimale : « non », en considérant qu'il s'agit d'un jeu de
  questions sans représentation de violence. Classification attendue :
  PEGI 3 / Tout public.

À décider par le propriétaire ; la réponse doit rester la même sur l'App
Store (`docs/store/app-store-kids.md`).

## Public cible et contenu

| Question | Réponse proposée |
| --- | --- |
| Tranches d'âge du public cible | **6 à 8 ans** et **9 à 12 ans** |
| L'application pourrait-elle attirer involontairement des enfants ? | Sans objet : elle s'adresse aux enfants |
| Fiche Play Store : attire-t-elle les enfants ? | Oui |

Conséquence : l'application relève du **programme Familles** de Google Play
et doit respecter ses règles. État pour la version 1.0 :

| Exigence du programme Familles | Kid Matix 1.0 |
| --- | --- |
| Contenu adapté aux enfants | Oui : questions de multiplication, mascotte, monstres dessinés |
| Pas de publicité, ou SDK publicitaires certifiés Familles | Aucune publicité, aucun SDK publicitaire |
| SDK tiers conformes aux règles Familles | Aucun SDK tiers qui communique (liste des paquets dans l'audit) |
| Pas de collecte d'identifiants de l'appareil (identifiant publicitaire, Android ID...) | Aucune collecte ; aucune autorisation demandée |
| Pas de localisation précise | Aucune |
| Achats protégés par un contrôle parental | Aucun achat |
| Liens sortants protégés | Aucun lien vers l'extérieur |
| Politique de confidentialité publiée | Brouillon prêt, à héberger |
| Niveau d'API cible à jour | API 36 |

Le badge « Approuvé par les enseignants » n'est pas demandé : Google
l'attribue lui-même après examen, il n'y a rien à remplir.

## Sécurité des données

| Question | Réponse proposée |
| --- | --- |
| L'application collecte-t-elle ou partage-t-elle des types de données utilisateur obligatoires ? | **Non** |
| Les données sont-elles chiffrées en transit ? | Sans objet : aucune donnée n'est transmise |
| Les utilisateurs peuvent-ils demander la suppression de leurs données ? | Les données ne quittent pas l'appareil ; elles s'effacent dans l'application (« Supprimer ce joueur ») ou en la désinstallant |

Pourquoi « Non » : selon les définitions de Google, une donnée traitée
uniquement sur l'appareil et jamais envoyée hors de celui-ci n'est ni
« collectée » ni « partagée ». C'est le cas du pseudo et de la progression.

**Point lié à l'audit** : la sauvegarde automatique d'Android est active par
défaut (`android:allowBackup` non défini). Elle copie les données du jeu
dans le compte Google de l'utilisateur. Désactiver la sauvegarde avant la
publication rend la réponse « Non » indiscutable et rejoint la section 16
des spécifications ; la garder demande de vérifier comment Google la traite
dans ce formulaire. Voir `docs/release/audit-1.0.md`, point 3.

## Autres déclarations

| Déclaration | Réponse proposée |
| --- | --- |
| Application gouvernementale | Non |
| Fonctionnalités financières | Aucune |
| Application de santé | Non |
| Application d'actualités | Non |
| Identifiant publicitaire utilisé | Non |
| Autorisations sensibles (SMS, journal d'appels, localisation en arrière-plan, accès à tous les fichiers...) | Aucune |

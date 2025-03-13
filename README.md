# Salut et bienvenue au projet: MCTruckCheck (le nom peut changer)
![Mobility-Corner logo](/assets/images/mobility_corner_logo.png)

---
## Table of Contents

- [Introduction](#1.-introduction)
- [Technologies utilisées](#2.-technologies-utilisées)
- [Architecture de l’application](#3.-architecture-de-lapplication)
- [Installation et configuration](#4.-installation-et-configuration)
- [Structure du projet](#5.-structure-du-projet)
- [Gestion des bases de données](#6.-gestion-des-bases-de-données)
- [Gestion de la synchronisation Firebase ↔ SQLite](#7.-gestion-de-la-synchronisation-firebase-↔-sqlite)
- [Sécurité et permissions](#8.-sécurité-et-permissions)
- [API et intégrations](#9.-api-et-intégrations)
- [Tester l’application en local](#10.-Tester-lapplication-en-local)
- [Déploiement et mise en production](#11.-déploiement-et-mise-en-production)

---
## 1. Introduction

Cette application mobile, développée avec Flutter et Dart, permet aux utilisateurs de remplir et valider des check-lists avant l’utilisation d’un camion. Elle fonctionne en mode en ligne et hors ligne grâce à une base de données hybride : Firebase (Cloud) et SQLite (local).

L’application assure également la gestion des camions, des entreprises et des utilisateurs avec un système de rôles et permissions (Super Admin, Admin, Utilisateur).

## 2. Technologies utilisées

| Catégorie |Technologie|
| -------  | ------- |
| Framework  | Flutter|
| Langage  | Dart|
| Base de données (Cloud)  | Firebase Firestore|
| Base de données (Locale)  | SQLite (via Sqflite)|
| Stockage de fichiers (PDF et photos) | Firebase Storage|
| Authentification  | Firebase Authentication|
| Environnement de dev  | Android Studio, Xcode, VS Code|
| Gestion du code  | GitHub|
| APIs externes  | VRM (Camions energie)|

## 3. Architecture de l’application

L’application repose sur une architecture modulaire, divisée en plusieurs couches:

#### 1. Interface Utilisateur (UI)

    Développée avec Flutter, elle gère la navigation, l'affichage des écrans et l’interaction avec l’utilisateur.
    Mode clair/sombre et gestion multilingue (FR, ENG...).
    Widgets personnalisés pour l’affichage des check-lists et des camions.

#### 2. Logique métier et services

    Gestion des check-lists : validation des tâches, génération de PDF.
    Gestion des utilisateurs : rôles, permissions et profils.
    Synchronisation Firebase ↔ SQLite : mode hors ligne et mise à jour automatique.

#### 3. Base de données et stockage

    Firebase Firestore : stockage des utilisateurs, check-lists, camions et PDF.
    SQLite : sauvegarde locale pour le mode hors ligne.

#### 4. API et connectivité

    INPI : récupération des informations des entreprises via leur numéro SIREN.
    VRM : récupération des données sur les camions (actuellement désactivé).
    Firebase Authentication : gestion des connexions et des rôles utilisateurs.


## 4. Installation et configuration

#### Pré-requis

Avant d’installer le projet, assurez-vous d’avoir les éléments suivants:
- Flutter installé : [Guide d’installation](https://docs.flutter.dev/get-started/install)
- Android Studio / Visual Studio Code / Xcode installé

#### Installation du projet

Clonez le projet et installez les dépendances Flutter:
```bash
git clone https://github.com/GroupeSedimat/Flutter_camion_controle_application.git  
cd app  
flutter pub get  
flutter run
```

#### Installation du database

L’application utilise Firebase Firestore. Voici les étapes pour l’installer et la configurer:

- [instaliuj CLI Firebase](https://firebase.google.com/docs/cli?hl=fr#setup_update_cli)
- [instaluj Firebase](https://firebase.google.com/docs/flutter/setup?hl=fr&platform=ios)
- Configurer Firebase pour le projet:
```bash
flutterfire configure
```
>[!IMPORTANT]
>
> Cette commande permet d’associer l’application à une base de données Firebase. Elle est utile pour changer de base (par exemple, en fonction de la branche utilisée pour les tests). Avant de l’exécuter, assurez-vous d’avoir créé la base de données Firebase.

>[!IMPORTANT]
>
>Après flutterfire configure, assurez-vous que les fichiers suivants sont bien configurés :
>
>- android/app/google-services.json → pour Firebase sur Android
>- ios/Runner/GoogleService-Info.plist → pour Firebase sur iOS
>- .firebaserc et firebase_options.dart → pour la connexion du projet

#### Installation pluginow

- [strona  pluginami fo fluttera](https://pub.dev/)
- Installer un plugin dans le projet:
```bash
flutter pub add PLUGIN_NAME
```


## 5. Structure du projet

/lib  
├── /models
├── /services
├── /pages
├── /widgets
├── /utils
├── main.dart


1. models -> Définitions des entités (Camion, Checklist, Utilisateur...)
2. services -> Gestion de la logique métier (SyncService, AuthService...)
3. pages -> Écrans de l’application
4. widgets -> Composants UI réutilisables
5. utils -> Fonctions utilitaires
6. main.dart -> Point d’entrée de l’application


## 6. Gestion des bases de données
#### Firebase (NoSQL - Cloud)

> [!NOTE]
>
> Chaque document dans Firestore ne contient pas d’ID interne dans ses champs, mais son identifiant unique est généré et stocké à l’extérieur du document, ce qui signifie que:

1. L'ID Firebase sert de clé primaire mais n’est pas stocké directement dans les champs du document.
2. Les entités ne possèdent pas de champ id, contrairement à SQLite.
3. L’accès aux documents se fait via leur identifiant externe Firebase.

Collections principales dans Firestore
|Collection	| Description|
| :---:  | ------- |
|Users|	Données des utilisateurs (nom, rôle, entreprise, camions assignés, etc.).|
|Camions|	Liste des camions et leur état (nom, type, entreprise, statut, etc.).|
|Companies|	Données des entreprises (nom, SIREN, adresse, contacts, etc.).|
|Blueprints|	Définit les tâches à remplir dans les check-lists (intitulé, instructions, pièces jointes).|
|Tasks|	Réponses des utilisateurs aux check-lists (validation, photos, commentaires, timestamps).|
|Equipments|	Liste du matériel stocké dans chaque camion (nom, quantité, type de véhicule concerné).|
|ListOfLists|	Liste des check-lists existantes (chaque camion peut avoir plusieurs check-lists assignées).|
|PDFs|	Fichiers générés après validation d’une check-list (`stockés dans Firebase Storage`).|

#### SQLite (Stockage local)
> [!NOTE]
>
>Contrairement à Firestore, SQLite stocke l’ID Firebase en tant que clé primaire pour assurer la correspondance entre les bases.

- Synchronisation automatique avec Firebase.
- Permet l’utilisation en mode hors ligne.
- Structure similaire à Firebase pour faciliter les mises à jour.

## 7. Gestion de la synchronisation Firebase ↔ SQLite

L’application utilise un service de synchronisation dédié, SyncService, qui assure la mise à jour des données entre Firebase Firestore (Cloud) et SQLite (local).

`fullSyncTable` → Fonction principale qui effectue une synchronisation complète d’une table en exécutant les étapes suivantes :
1. `syncFromFirebase` → Récupère les dernières données de Firebase et les applique localement dans SQLite.
2. `syncToFirebase` → Envoie les modifications locales vers Firebase.
3. Gestion des conflits → Si une donnée a été modifiée à la fois en local et en ligne, l’utilisateur choisit quelle version conserver.

> [!TIP] Avantage de fullSyncTable
>
> Plutôt que d’appeler séparément syncFromFirebase et syncToFirebase, il suffit d’appeler une seule fonction (fullSyncTable) pour assurer la mise à jour complète d’une table.

## 8. Sécurité et permissions 

#### 🔒 Authentification et rôles

Authentification sécurisée via Firebase Authentication avec gestion des rôles:

* `superadmin` → contrôle total sur toutes les entreprises, camions et utilisateurs.
* `admin` → gère sa propre entreprise, ses camions et ses employés.
* `user` → accède uniquement aux check-lists et camions qui lui sont assignés.

#### 🔒 Connexion HTTPS

    Toutes les communications entre l’application et Firebase sont chiffrées en HTTPS.

## 9. API et intégrations

#### INPI (Données des entreprises)

    Permet de récupérer automatiquement les informations d’une entreprise à partir de son numéro SIREN.

#### VRM (Données des camions)

    Prévu pour récupérer des informations sur les véhicules.
    Actuellement désactivé en raison de priorités sur d’autres fonctionnalités.

## 10. Tester l’application en local

Pour Android : Lancer l’émulateur ou brancher un téléphone en mode développeur et exécuter :
```bash
flutter run --release
```

Pour iOS : Ouvrir ios/Runner.xcworkspace dans Xcode et exécuter sur un simulateur ou un iPhone réel.

## 11. Déploiement et mise en production

#### Publication sur Google Play et Apple Store

    Fichier android/app/build.gradle → Configurer l’identifiant de l’application.
    Fichier ios/Runner/Info.plist → Ajouter les autorisations nécessaires.
    Génération des fichiers .apk et .ipa pour le déploiement.

#### Maintenance et mises à jour

    Suivi des erreurs via Firebase Crashlytics.
    Mises à jour continues via le système de versioning GitHub.

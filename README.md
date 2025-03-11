# Salut et bienvenue au projet: MCTruckCheck (le nom peut changer)
![Mobility-Corner logo](/assets/images/mobility_corner_logo.png)

---
## Table of Contents

- [Introduction](#1️⃣-introduction)
- [Technologies utilisées](#2️⃣-technologies-utilisées)
- [Architecture de l’application](#3️⃣-architecture-de-lapplication)
- [Installation et configuration](#4️⃣-installation-et-configuration)
- [Structure du projet](#5️⃣-structure-du-projet)
- [Gestion des bases de données](#6️⃣-gestion-des-bases-de-données)
- [Gestion de la synchronisation Firebase ↔ SQLite](#7️⃣-gestion-de-la-synchronisation-firebase-↔-sqlite)
- [Sécurité et permissions](#8️⃣-sécurité-et-permissions)
- [API et intégrations](#8️⃣-api-et-intégrations)
- [Déploiement et mise en production](#🔟-déploiement-et-mise-en-production)

---
## 1️⃣ Introduction

Cette application mobile, développée avec Flutter et Dart, permet aux utilisateurs de remplir et valider des check-lists avant l’utilisation d’un camion. Elle fonctionne en mode en ligne et hors ligne grâce à une base de données hybride : Firebase (Cloud) et SQLite (local).

L’application assure également la gestion des camions, des entreprises et des utilisateurs avec un système de rôles et permissions (Super Admin, Admin, Utilisateur).

## 2️⃣ Technologies utilisées

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
| APIs externes  | INPI (Données entreprises), VRM (Camions energie)|

## 3️⃣ Architecture de l’application

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


## 4️⃣ Installation et configuration

#### Pré-requis

- Flutter installé : [Guide d’installation](https://docs.flutter.dev/get-started/install)
- Android Studio / Visual Studio Code / Xcode installé
<!-- - Clé API Firebase (fichier google-services.json pour Android, GoogleService-Info.plist pour iOS) -->

#### Installation du projet

```bash
git clone https://github.com/GroupeSedimat/Flutter_camion_controle_application.git  
cd app  
flutter pub get  
flutter run
```

## 5️⃣ Structure du projet

/lib  
├── /models       # Définitions des entités (Camion, Checklist, Utilisateur...)  
├── /services     # Gestion de la logique métier (SyncService, AuthService...)  
├── /pages        # Écrans de l’application
<!-- ├── /widgets      # Composants UI réutilisables   -->
<!-- ├── /utils        # Fonctions utilitaires  -->
├── main.dart     # Point d’entrée de l’application

## 6️⃣ Gestion des bases de données
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

## 7️⃣ Gestion de la synchronisation Firebase ↔ SQLite

L’application utilise un service de synchronisation dédié, SyncService, qui assure la mise à jour des données entre Firebase Firestore (Cloud) et SQLite (local).

`fullSyncTable` → Fonction principale qui effectue une synchronisation complète d’une table en exécutant les étapes suivantes :
1. `syncFromFirebase` → Récupère les dernières données de Firebase et les applique localement dans SQLite.
2. `syncToFirebase` → Envoie les modifications locales vers Firebase.
3. Gestion des conflits → Si une donnée a été modifiée à la fois en local et en ligne, l’utilisateur choisit quelle version conserver.

> [!TIP] Avantage de fullSyncTable
>
> Plutôt que d’appeler séparément syncFromFirebase et syncToFirebase, il suffit d’appeler une seule fonction (fullSyncTable) pour assurer la mise à jour complète d’une table.

## 8️⃣ Sécurité et permissions 

#### 🔒 Authentification et rôles

Authentification sécurisée via Firebase Authentication avec gestion des rôles:

* `superadmin` → Accès à toutes les entreprises et camions.
* `admin` → Gestion de sa propre entreprise et de ses utilisateurs.
* `user` → Accès restreint aux check-lists et camions assignés.

#### 🔒 Connexion HTTPS

    Toutes les communications entre l’application et Firebase sont chiffrées en HTTPS.

## 9️⃣ API et intégrations

#### INPI (Données des entreprises)

    Permet de récupérer automatiquement les informations d’une entreprise à partir de son numéro SIREN.

#### VRM (Données des camions)

    Prévu pour récupérer des informations sur les véhicules.
    Actuellement désactivé en raison de priorités sur d’autres fonctionnalités.

## 🔟 Déploiement et mise en production

#### Publication sur Google Play et Apple Store

    Fichier android/app/build.gradle → Configurer l’identifiant de l’application.
    Fichier ios/Runner/Info.plist → Ajouter les autorisations nécessaires.
    Génération des fichiers .apk et .ipa pour le déploiement.

#### Maintenance et mises à jour

    Suivi des erreurs via Firebase Crashlytics.
    Mises à jour continues via le système de versioning GitHub.

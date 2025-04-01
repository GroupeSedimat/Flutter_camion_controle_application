# Salut et bienvenue au projet: MCTruckCheck (le nom peut changer)
![Mobility-Corner logo](/assets/images/mobility_corner_logo.png)

---
## Table of Contents

- [Introduction](#1-introduction)
- [Technologies utilisées](#2-technologies-utilisées)
- [Architecture de l’application](#3-architecture-de-lapplication)
- [Installation et configuration](#4-installation-et-configuration)
- [Structure du projet](#5-structure-du-projet)
- [Gestion des bases de données](#6-gestion-des-bases-de-données)
- [Passage à un autre serveur](#7-passage-à-un-autre-serveur)
- [Gestion de la synchronisation Firebase ↔ SQLite](#8-gestion-de-la-synchronisation-firebase--sqlite)
- [Sécurité et permissions](#9-sécurité-et-permissions)
- [API et intégrations](#10-api-et-intégrations)
- [Tester l’application en local](#11-tester-lapplication-en-local)
- [Déploiement et mise en production](#12-déploiement-et-mise-en-production)

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

    INPI : récupération des informations des entreprises via leur numéro SIREN (n'existe pas encore).
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

- [installer CLI Firebase](https://firebase.google.com/docs/cli?hl=fr#setup_update_cli)
- [installer Firebase](https://firebase.google.com/docs/flutter/setup?hl=fr&platform=ios)
- Configurer Firebase pour le projet:
```bash
flutterfire configure
```
>[!TIP]
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

- [Page des plugins Flutter](https://pub.dev/)
- Installer un plugin dans le projet:
```bash
flutter pub add PLUGIN_NAME
```


## 5. Structure du projet

/lib <br/>
├── /models <br/>
├── /services <br/>
├── /pages <br/>
├── /widgets <br/>
├── /utils <br/>
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

## 7. Passage à un autre serveur
#### Modifications nécessaires:
1. Créer un nouveau système d’authentification (Firestore gérait l’authentification, donc en changeant de serveur, il faut tout recréer de zéro):
   * services/auth_controller.dart → gère la création de compte, la modification de mot de passe et la connexion.
   * services/database_firestore/user_service.dart → gère les données utilisateur contenues dans models.
    > [!NOTE]
    >
    > Il est possible de fusionner auth_controller et user_service. Dans ce cas, il faut également modifier models/my_user.dart et sécuriser l’accès aux données
   * Dans tous les services utilisant _loadUserToConnection(), remplacer user_service.dart par le nouveau service afin de récupérer les informations de l’utilisateur actuel (ID et objet).
2. Remplacer les services Firestore (services/database_firestore/...) par des services dédiés à la gestion des données de chaque entité.
    * Ces services sont appelés dans services/sync_service.dart, il faut donc modifier son appel à cet endroit.
    > [!WARNING]
    >
    > database_image_service.dart est aussi utilisé dans services/pdf/pdf_service.dart. Il faut donc également y modifier l’appel au service.
3. Remplacer services/pdf/database_pdf_service.dart par un service de gestion des fichiers PDF
4. Remplacer services/database_validation_files_service.dart par un service de gestion des fichiers de certification/autorisations pour l’utilisation des camions.
    * Ce service est utilisé dans pages/admin/UserEditPage.dart, il faut donc modifier son appel à cet endroit.



## 8. Gestion de la synchronisation Firebase ↔ SQLite

L’application utilise un service de synchronisation dédié, SyncService, qui assure la mise à jour des données entre Firebase Firestore (Cloud) et SQLite (local).

`fullSyncTable` → Fonction principale qui effectue une synchronisation complète d’une table en exécutant les étapes suivantes :
1. `syncFromFirebase` → Récupère les dernières données de Firebase et les applique localement dans SQLite.
2. `syncToFirebase` → Envoie les modifications locales vers Firebase.
3. Gestion des conflits → Si une donnée a été modifiée à la fois en local et en ligne, l’utilisateur choisit quelle version conserver.

> [!TIP] Avantage de fullSyncTable
>
> Plutôt que d’appeler séparément syncFromFirebase et syncToFirebase, il suffit d’appeler une seule fonction (fullSyncTable) pour assurer la mise à jour complète d’une table.

## 9. Sécurité et permissions 

#### 🔒 Authentification et rôles

Authentification sécurisée via Firebase Authentication avec gestion des rôles:

* `superadmin` → contrôle total sur toutes les entreprises, camions et utilisateurs.
* `admin` → gère sa propre entreprise, ses camions et ses employés.
* `user` → accède uniquement aux check-lists et camions qui lui sont assignés.

#### 🔒 Connexion HTTPS

    Toutes les communications entre l’application et Firebase sont chiffrées en HTTPS.

#### 🔒 Storage Access Framework (SAF) — Enregistrement de fichier dans Documents sur Android 10+
> [!WARNING]
>
> Cette approche est 100% conforme aux règles de Google Play (au cas où function "savePdfFile" dans pdf_service.dart serait rejeté par Google Play).

Étape 1: Ajouter la dépendance

  Dans pubspec.yaml:
```bash
dependencies:
  storage_access_framework: ^1.1.1
```
Étape 2: Enregistrement d’un fichier PDF avec SAF (services/pdf/pdf_service.dart) 
```dart
Future<String?> savePdfFileWithSAF(
    String companyID,
    Uint8List data,
    MyUser user,
    String userId,
    Future<void> Function() deleteOneTaskListOfUser,
    String? folderUri, // SAF nécessite un URI de dossier enregistré
    ) async {
  int time = DateTime.now().millisecondsSinceEpoch;
  String fileName = "${user.username}.${time.toString()}.pdf";
  String filePathDatabase = "${user.company}/$userId/${time.toString()}";

  // 1: Vérifier si un dossier SAF est défini
  if (folderUri == null) {
    print("Aucun dossier SAF défini – tentative de récupération depuis SharedPreferences.");

    // Essayer de récupérer l'URI enregistré
    final prefs = await SharedPreferences.getInstance();
    folderUri = prefs.getString('saf_folder_uri');
    if (folderUri != null) {
      print("Dossier SAF récupéré depuis SharedPreferences : $folderUri");
    }
    
    // Si toujours null, demander à l’utilisateur de choisir un dossier
    if (folderUri == null) {
      print("Aucun dossier SAF enregistré – demander à l’utilisateur de choisir un dossier.");
      folderUri = await StorageAccessFramework.openDocumentTree();

      if (folderUri != null) {
        // Enregistrer le dossier sélectionné
        await prefs.setString('saf_folder_uri', folderUri);
        print("Nouveau dossier SAF enregistré: $folderUri");
      } else {
        print("L'utilisateur a annulé la sélection du dossier.");
        return null; // Arrêter l'exécution si aucun dossier n'est sélectionné
      }
    }
  }
  
  try {
    // 2. Créer un fichier dans le dossier SAF sélectionné
    final fileUri = await StorageAccessFramework.createFile(
      folderUri,
      "application/pdf",
      fileName,
    );

    if (fileUri == null) {
      print("Échec de la création du fichier dans SAF.");
      return null;
    }

    // 3. Écrire les données PDF dans le fichier SAF
    await StorageAccessFramework.writeFile(fileUri, data);
    print("Fichier PDF enregistré: $fileUri");

    // 4. Si connecté à Internet → envoyer le fichier à Firebase
    if (networkService.isOnline) {
      // D'abord, enregistrer temporairement le fichier sur l’appareil (Firebase nécessite un chemin de fichier)
      Directory tempDir = await getApplicationSupportDirectory();
      File tempFile = File("${tempDir.path}/$fileName");
      await tempFile.writeAsBytes(data);

      await databasePDFService.addPdfToFirebase(tempFile.path, filePathDatabase);
    } else {
      // 5. Si hors ligne → enregistrer temporairement pour synchronisation ultérieure
      Directory tempDir = await getApplicationSupportDirectory();
      File tempFile = File("${tempDir.path}/$userId.${time.toString()}.pdf");
      await tempFile.writeAsBytes(data);
      print("Fichier enregistré temporairement pour synchronisation: ${tempFile.path}");
    }

    await deleteOneTaskListOfUser();
    return fileUri; // SAF retourne un URI, pas un chemin classique
  } catch (e) {
    print("Erreur SAF: $e");
    return null;
  }
}
```

## 10. API et intégrations

#### INPI (Données des entreprises)

    Permet de récupérer automatiquement les informations d’une entreprise à partir de son numéro SIREN.

#### VRM (Données des camions)

    Prévu pour récupérer des informations sur les véhicules.
    Actuellement désactivé en raison de priorités sur d’autres fonctionnalités.

## 11. Tester l’application en local

Pour Android : Lancer l’émulateur ou brancher un téléphone en mode développeur et exécuter :
```bash
flutter run --release
```

Pour iOS : Ouvrir ios/Runner.xcworkspace dans Xcode et exécuter sur un simulateur ou un iPhone réel.

## 12. Déploiement et mise en production

#### Publication sur Google Play et Apple Store

    Fichier android/app/build.gradle → Configurer l’identifiant de l’application.
    Fichier ios/Runner/Info.plist → Ajouter les autorisations nécessaires.
    Génération des fichiers .apk et .ipa pour le déploiement.

#### Maintenance et mises à jour

    Suivi des erreurs via Firebase Crashlytics.
    Mises à jour continues via le système de versioning GitHub.

## Salut!
  Travailler sur ce projet a été une expérience très intéressante. Je souhaite beaucoup de succès et le moins de bugs possible à toutes les personnes travaillant sur ce projet!

  Le premier impliqué dans la création de cette application - [`Ireneusz PISKORSKI`](https://www.linkedin.com/in/ireneusz-piskorski/)

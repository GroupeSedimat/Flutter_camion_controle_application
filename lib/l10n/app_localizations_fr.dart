// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get required => 'Ce champ est obligatoire!';

  @override
  String get homePage => 'Page d\'accueil';

  @override
  String get welcomeToMC => 'Bienvenue sur MCTruckCheck';

  @override
  String get logIn => 'Connectez-vous';

  @override
  String get logInText => 'Connectez-vous à votre compte';

  @override
  String get signIn => 'Inscrivez-vous';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get logOutText => 'Vous avez été déconnecté';

  @override
  String get loading => 'Chargement...';

  @override
  String get status => 'Status';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get add => 'Ajouter';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String get open => 'Ouvrir';

  @override
  String get download => 'Télécharger';

  @override
  String get details => 'Afficher les détails';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get restore => 'Restore';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get confirmDeleteText => 'Êtes-vous sûr de vouloir supprimer?';

  @override
  String get confirmApprove => 'Approuver cet utilisateur?';

  @override
  String get confirmApproveText =>
      'Êtes-vous sûr de vouloir approuver cet utilisateur?';

  @override
  String get confirmDisapprove => 'Confirmer la désapprobation';

  @override
  String get confirmDisapproveText =>
      'Etes-vous sûr de vouloir désapprouver cet utilisateur?';

  @override
  String get errorSavingData => 'Error Saving Data';

  @override
  String get userProfileEdit => 'Modifier le profil';

  @override
  String get userLoading => 'Chargement des données utilisateur(s)';

  @override
  String userHello(String userName) {
    return 'Bienvenue $userName';
  }

  @override
  String userWithName(String userName) {
    return 'Utilisateur: $userName';
  }

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get userNewName => 'Nouveau nom d\'utilisateur';

  @override
  String get userFirstName => 'Nom';

  @override
  String get userLastName => 'Prénom';

  @override
  String get usernameTaken => 'Le nom d\'utilisateur est déjà pris';

  @override
  String adminHello(String userName) {
    return 'Bienvenue sur la page admin, $userName';
  }

  @override
  String get userApprove => 'Approuver un utilisateur';

  @override
  String get userDataNotFound => 'Aucune donnée utilisateur disponible';

  @override
  String role(String userRole) {
    return 'Rôle $userRole';
  }

  @override
  String get searchLocationPlaceholder => 'Rechercher un lieu';

  @override
  String get mapTitle => ' Map';

  @override
  String get viewOnGoogleMaps => 'Voir sur google maps';

  @override
  String get viewMaps => 'Voir maps';

  @override
  String get quickStatistics => 'Statistiques rapides';

  @override
  String get activeTrucks => 'Camions actifs';

  @override
  String get numberOfInterventions => 'Nombre d\'interventions';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get newIntervention => 'Nouvelle intervention';

  @override
  String get dailyReport => 'Rapport journalier';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get passForgot => 'Mot de passe oublié?';

  @override
  String get passNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passReset => 'Réinitialiser le mot de passe';

  @override
  String get passChange => 'Modifier mot de passe';

  @override
  String get passEnter => 'Entrez votre mot de passe';

  @override
  String get passRepeat => 'Répétez votre mot de passe';

  @override
  String get eMail => 'Adresse e-mail';

  @override
  String get eMailEnter => 'Entrez votre e-mail';

  @override
  String get eMailOrUsernameEnter =>
      'Entrez votre e-mail ou nom d\'utilisateur';

  @override
  String get eMailSend => 'Envoyer l\'e-mail de réinitialisation';

  @override
  String get company => 'Entreprise';

  @override
  String get companyList => 'Liste des entreprises';

  @override
  String get companyAdd => 'Ajouter une nouvelle entreprise';

  @override
  String get companyEdit => 'Modifier les informations de l\'entreprise';

  @override
  String get companySelect => 'Choisir une entreprise';

  @override
  String get companyNotFound => 'L\'entreprise n\'a pas pu être trouvée';

  @override
  String companyWithName(String companyName) {
    return 'Entreprise: $companyName';
  }

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get companySiret => 'Siret';

  @override
  String get companySirene => 'Sirene';

  @override
  String get companyDescription => 'Description de l\'entreprise';

  @override
  String get companyPhone => 'Numéro de contact';

  @override
  String get companyEMail => 'E-mail du contact';

  @override
  String get companyAddress => 'Adresse de correspondance';

  @override
  String get companyResponsible => 'Personne responsable du contact';

  @override
  String get companyAdmin => 'L\'administrateur principal de l\'entreprise';

  @override
  String get companyLogo => 'Logo de l\'entreprise';

  @override
  String get companyErrorLoading => 'Error loading Companies';

  @override
  String get camionType => 'Type de camion';

  @override
  String get camionsList => 'Liste des camions';

  @override
  String get camionName => 'Nom du camion';

  @override
  String get camionResponsible => 'Responsable du véhicule';

  @override
  String get camionChecks => 'Contrôles du véhicule';

  @override
  String get camionLastIntervention => 'Date de la dernière intervention';

  @override
  String get camionTypesList => 'Liste des types de camions';

  @override
  String get camionTypeName => 'Nom du type';

  @override
  String get camionTypeEquipment => 'Équipement du véhicule';

  @override
  String get camionTypeErrorLoading => 'Error loading CamionTypes';

  @override
  String get noCamionsAvailable => 'Aucun camion disponible';

  @override
  String get camionMenuTrucks => 'Camions';

  @override
  String get camionMenuEquipment => 'Équipement';

  @override
  String get camionMenuTypes => 'Types';

  @override
  String get camionAddedSuccessfully => 'Truck added successfully';

  @override
  String get historyCheck => 'historique des checks';

  @override
  String get checkPerformedOn => 'a effectué un check sur';

  @override
  String get timeAgo => 'Il y a';

  @override
  String get noChecksFound => 'Aucun check trouvé pour votre entreprise.';

  @override
  String get camionUpdatedSuccessfully => 'Truck updated successfully';

  @override
  String get sort => 'Trier';

  @override
  String get sortName => 'Trier par nom';

  @override
  String get sortType => 'Trier par type';

  @override
  String get sortEntreprise => 'Trier par entreprise';

  @override
  String get sortDescending => 'Trier A-Z/Z-A';

  @override
  String get filterType => 'Filtrer par type';

  @override
  String get filterEntreprise => 'Filtrer par entreprise';

  @override
  String get equipmentIdShop => 'Equipment id in stock';

  @override
  String get equipmentName => 'Nom de l\'équipement';

  @override
  String get equipmentList => 'Liste des équipements';

  @override
  String get equipmentDescription => 'Description de l\'équipement';

  @override
  String get equipmentQuantity => 'Quantity of this equipment';

  @override
  String get equipmentEnterQuantity => 'Please enter a valid quantity';

  @override
  String get equipmentErrorLoading => 'Error loading equipment';

  @override
  String get checkList => 'Checklist';

  @override
  String get checkListDescribe => 'Décrire le problème';

  @override
  String get checkListValidation => 'Processus de validation';

  @override
  String get blueprintAdd => 'Ajouter Blueprint';

  @override
  String get blueprintAddName => 'Ajouter le nom du Blueprint';

  @override
  String get blueprintAddDescription => 'Ajouter une description du Blueprint';

  @override
  String get photoNotYet => 'Pas encore de photo';

  @override
  String get photoMake => 'Créer une photo';

  @override
  String get photoGallery => 'Choisissez dans la galerie';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get pdfCreate => 'Créer un PDF';

  @override
  String get pdfList => 'Liste des fichiers PDF';

  @override
  String get pdfMyFiles => 'Mes fichiers PDF';

  @override
  String get pdfListAdmin => 'Liste admin des fichiers PDF';

  @override
  String pdfDownloaded(String fileName1, String fileName2) {
    return 'Votre fichier PDF a été enregistré sous le nom : $fileName1.$fileName2.pdf';
  }

  @override
  String get listOfLists => 'La liste des listes';

  @override
  String get lOLAdd => 'Ajouter une liste';

  @override
  String get lOLEdit => 'Modifier la liste';

  @override
  String get lOLNumber => 'Numéro de liste';

  @override
  String get lOLNumberText => 'Veuillez saisir le numéro de liste';

  @override
  String get lOLName => 'Nom de la liste';

  @override
  String get lOLNameText => 'Veuillez saisir le nom de la liste';

  @override
  String lOLAuthorization(int person) {
    return 'Autorisation: $person';
  }

  @override
  String get lOLAddAuthoried => 'Ajouter une personne autorisée';

  @override
  String listNumber(int number) {
    return 'Numéro de liste: $number';
  }

  @override
  String listPosition(int position) {
    return 'Position de la liste: $position';
  }

  @override
  String get manageUsers => 'Gérer les utilisateurs';

  @override
  String get superAdminPage => 'Page du super admin';

  @override
  String get adminPage => 'Page d\'administration';

  @override
  String get accountNotYet => 'Vous n\'avez pas encore de compte?';

  @override
  String get settings => 'Paramètres';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get editInformation => 'Modifier vos informations';

  @override
  String get messenger => 'Messagerie';

  @override
  String get enterMessage => 'Tapez votre message';

  @override
  String dateCreation(String formattedDate) {
    return 'Date de création: $formattedDate';
  }

  @override
  String get dataFetching => 'Récupération de données';

  @override
  String get dataReceived => 'J\'ai des données';

  @override
  String get dataNoData => 'Aucune donnée, désolé :(';

  @override
  String get dataNoDataOffLine => 'No data in offline mode, sorry :(';

  @override
  String get colorLight => 'Clair';

  @override
  String get colorDark => 'Sombre';

  @override
  String get colorAutomatic => 'Automatique';

  @override
  String get color => 'Couleur';
}

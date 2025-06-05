// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get required => 'Dit veld is verplicht!';

  @override
  String get homePage => 'Startpagina';

  @override
  String get welcomeToMC => 'Welkom bij MCTruckCheck';

  @override
  String get logIn => 'Inloggen';

  @override
  String get logInText => 'Log in op je account';

  @override
  String get signIn => 'Aanmelden';

  @override
  String get logOut => 'Uitloggen';

  @override
  String get logOutText => 'Je bent uitgelogd';

  @override
  String get loading => 'Laden...';

  @override
  String get status => 'Status';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get add => 'Toevoegen';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get open => 'Openen';

  @override
  String get download => 'Downloaden';

  @override
  String get details => 'Bekijk de details';

  @override
  String get edit => 'Bewerken';

  @override
  String get delete => 'Verwijderen';

  @override
  String get restore => 'Restore';

  @override
  String get confirmDelete => 'Bevestig verwijderen';

  @override
  String get confirmDeleteText => 'Weet je zeker dat je dit wilt verwijderen?';

  @override
  String get confirmApprove => 'Wil je deze goedkeuren?';

  @override
  String get confirmApproveText => 'Weet je zeker dat je deze goedkeurt?';

  @override
  String get confirmDisapprove => 'Wil je deze afkeuren?';

  @override
  String get confirmDisapproveText => 'Weet je zeker dat je deze afkeurt?';

  @override
  String get errorSavingData => 'Error Saving Data';

  @override
  String get userProfileEdit => 'Bewerk profiel';

  @override
  String get userLoading => 'Bezig met laden...';

  @override
  String userHello(String userName) {
    return 'Welkom, $userName';
  }

  @override
  String userWithName(String userName) {
    return 'Gebruiker: $userName';
  }

  @override
  String get userName => 'Gebruikersnaam';

  @override
  String get userNewName => 'Nieuwe gebruikersnaam';

  @override
  String get userFirstName => 'Voornaam';

  @override
  String get userLastName => 'Achternaam';

  @override
  String get usernameTaken => 'Deze gebruikersnaam is al in gebruik';

  @override
  String adminHello(String userName) {
    return 'Welkom bij de adminpagina, $userName';
  }

  @override
  String get userApprove => 'Gebruiker goedkeuren';

  @override
  String get userDataNotFound => 'Gebruikersgegevens niet gevonden';

  @override
  String role(String userRole) {
    return 'Rol: $userRole';
  }

  @override
  String get searchLocationPlaceholder => 'Zoek locatie';

  @override
  String get mapTitle => 'Kaart';

  @override
  String get viewOnGoogleMaps => 'Bekijk op Google Maps';

  @override
  String get viewMaps => 'Bekijk kaarten';

  @override
  String get quickStatistics => 'Snelle statistieken';

  @override
  String get activeTrucks => 'Actieve vrachtwagens';

  @override
  String get numberOfInterventions => 'Aantal interventies';

  @override
  String get quickActions => 'Snelle acties';

  @override
  String get newIntervention => 'Nieuwe interventie';

  @override
  String get dailyReport => 'Dagrapport';

  @override
  String get maintenance => 'Onderhoud';

  @override
  String get passForgot => 'Wachtwoord vergeten?';

  @override
  String get passNotMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get passReset => 'Wachtwoord resetten';

  @override
  String get passChange => 'Wachtwoord wijzigen';

  @override
  String get passEnter => 'Voer je wachtwoord in';

  @override
  String get passRepeat => 'Herhaal je wachtwoord';

  @override
  String get eMail => 'E-mail adres';

  @override
  String get eMailEnter => 'Voer je e-mail in';

  @override
  String get eMailOrUsernameEnter => 'Voer je e-mail of gebruikersnaam in';

  @override
  String get eMailSend => 'Verstuur e-mail reset';

  @override
  String get company => 'Bedrijf';

  @override
  String get companyList => 'Bedrijvenlijst';

  @override
  String get companyAdd => 'Nieuw bedrijf toevoegen';

  @override
  String get companyEdit => 'Bewerk bedrijfsinformatie';

  @override
  String get companySelect => 'Selecteer een bedrijf';

  @override
  String get companyNotFound => 'Bedrijf niet gevonden';

  @override
  String companyWithName(String companyName) {
    return 'Bedrijf: $companyName';
  }

  @override
  String get companyName => 'Bedrijfsnaam';

  @override
  String get companySiret => 'Siret';

  @override
  String get companySirene => 'Sirene';

  @override
  String get companyDescription => 'Bedrijfsomschrijving';

  @override
  String get companyPhone => 'Bedrijfstelefoonnummer';

  @override
  String get companyEMail => 'Bedrijfse-mail';

  @override
  String get companyAddress => 'Bedrijfsadres';

  @override
  String get companyResponsible => 'Verantwoordelijke persoon';

  @override
  String get companyAdmin => 'Hoofdadmin van het bedrijf';

  @override
  String get companyLogo => 'Bedrijfslogo';

  @override
  String get companyErrorLoading => 'Error loading Companies';

  @override
  String get camionType => 'Vrachtwagentype';

  @override
  String get camionsList => 'Lijst van vrachtwagens';

  @override
  String get camionName => 'Vrachtwagennaam';

  @override
  String get camionResponsible =>
      'Verantwoordelijke persoon voor de vrachtwagen';

  @override
  String get camionChecks => 'Vrachtwageninspecties';

  @override
  String get camionLastIntervention => 'Laatste interventie';

  @override
  String get camionTypesList => 'Lijst van vrachtwagentypes';

  @override
  String get camionTypeName => 'Naam van het type vrachtwagen';

  @override
  String get camionTypeEquipment => 'Apparatuur in de vrachtwagen';

  @override
  String get camionTypeErrorLoading => 'Error loading CamionTypes';

  @override
  String get noCamionsAvailable => 'Geen vrachtwagens beschikbaar';

  @override
  String get camionMenuTrucks => 'Vrachtwagens';

  @override
  String get camionMenuEquipment => 'Apparatuur';

  @override
  String get camionMenuTypes => 'Types';

  @override
  String get camionAddedSuccessfully => 'Truck added successfully';

  @override
  String get historyCheck => 'Controlegeschiedenis';

  @override
  String get checkPerformedOn => 'heeft een check uitgevoerd op';

  @override
  String get timeAgo => 'sinds';

  @override
  String get noChecksFound => 'Geen controles gevonden voor uw bedrijf.';

  @override
  String get camionUpdatedSuccessfully => 'Truck updated successfully';

  @override
  String get sort => 'Sorteren';

  @override
  String get sortName => 'Sorteer op naam';

  @override
  String get sortType => 'Sorteer op type';

  @override
  String get sortEntreprise => 'Sorteer op bedrijf';

  @override
  String get sortDescending => 'Sorteer aflopend A-Z/Z-A';

  @override
  String get filterType => 'Filter op type';

  @override
  String get filterEntreprise => 'Filter op bedrijf';

  @override
  String get equipmentIdShop => 'Equipment id in stock';

  @override
  String get equipmentName => 'Apparatuur naam';

  @override
  String get equipmentList => 'Lijst van apparatuur';

  @override
  String get equipmentDescription => 'Beschrijving van de apparatuur';

  @override
  String get equipmentQuantity => 'Quantity of this equipment';

  @override
  String get equipmentEnterQuantity => 'Please enter a valid quantity';

  @override
  String get equipmentErrorLoading => 'Error loading equipment';

  @override
  String get checkList => 'Inspectielijst';

  @override
  String get checkListDescribe => 'Omschrijf de problemen';

  @override
  String get checkListValidation => 'Inspectieprocedure';

  @override
  String get blueprintAdd => 'Voeg een plattegrond toe';

  @override
  String get blueprintAddName => 'Voeg naam plattegrond toe';

  @override
  String get blueprintAddDescription =>
      'Voeg een beschrijving toe voor de plattegrond';

  @override
  String get photoNotYet => 'Geen foto';

  @override
  String get photoMake => 'Maak foto';

  @override
  String get photoGallery => 'Bekijk foto\'s in galerij';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get pdfCreate => 'Maak PDF';

  @override
  String get pdfList => 'PDF lijst';

  @override
  String get pdfMyFiles => 'Mijn PDF bestanden';

  @override
  String get pdfListAdmin => 'Lijst van admin PDF bestanden';

  @override
  String pdfDownloaded(String fileName1, String fileName2) {
    return 'Je PDF bestand is gedownload als $fileName1.$fileName2.pdf';
  }

  @override
  String get listOfLists => 'Lijst van lijsten';

  @override
  String get lOLAdd => 'Voeg een lijst toe';

  @override
  String get lOLEdit => 'Bewerk lijst';

  @override
  String get lOLNumber => 'Lijst nummer';

  @override
  String get lOLNumberText => 'Voer het lijstnummer in';

  @override
  String get lOLName => 'Lijstnaam';

  @override
  String get lOLNameText => 'Voer de lijstnaam in';

  @override
  String lOLAuthorization(int person) {
    return 'Geautoriseerd door: $person';
  }

  @override
  String get lOLAddAuthoried => 'Voeg een geautoriseerde persoon toe';

  @override
  String listNumber(int number) {
    return 'Lijst nummer: $number';
  }

  @override
  String listPosition(int position) {
    return 'Lijstpositie: $position';
  }

  @override
  String get manageUsers => 'Beheer gebruikers';

  @override
  String get superAdminPage => 'Superadmin pagina';

  @override
  String get adminPage => 'Admin pagina';

  @override
  String get accountNotYet => 'Nog geen account?';

  @override
  String get settings => 'Instellingen';

  @override
  String get darkMode => 'Donkere modus';

  @override
  String get language => 'Taal';

  @override
  String get editInformation => 'Bewerk informatie';

  @override
  String get messenger => 'Berichten';

  @override
  String get enterMessage => 'Voer je bericht in';

  @override
  String dateCreation(String formattedDate) {
    return 'Gemaakt op: $formattedDate';
  }

  @override
  String get dataFetching => 'Gegevens ophalen';

  @override
  String get dataReceived => 'Gegevens ontvangen';

  @override
  String get dataNoData => 'Geen gegevens beschikbaar, probeer het opnieuw :(';

  @override
  String get dataNoDataOffLine => 'No data in offline mode, sorry :(';

  @override
  String get colorLight => 'Licht';

  @override
  String get colorDark => 'Donker';

  @override
  String get colorAutomatic => 'Automatisch';

  @override
  String get color => 'Kleur';
}

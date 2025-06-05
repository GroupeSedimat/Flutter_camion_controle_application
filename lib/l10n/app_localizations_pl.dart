// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get required => 'To pole jest wymagane!';

  @override
  String get homePage => 'Strona główna';

  @override
  String get welcomeToMC => 'Witaj w MCTruckCheck';

  @override
  String get logIn => 'Zaloguj się';

  @override
  String get logInText => 'Zaloguj się na istniejące konto';

  @override
  String get signIn => 'Zarejestruj się';

  @override
  String get logOut => 'Wyloguj się';

  @override
  String get logOutText => 'Zostałeś wylogowany';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get status => 'Status';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get add => 'Dodaj';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get cancel => 'Anuluj';

  @override
  String get open => 'Otwórz';

  @override
  String get download => 'Pobierz';

  @override
  String get details => 'Wyświetl szczegóły';

  @override
  String get edit => 'Edytuj';

  @override
  String get delete => 'Usuń';

  @override
  String get restore => 'Restore';

  @override
  String get confirmDelete => 'Potwierdź usunięcie';

  @override
  String get confirmDeleteText => 'Czy na pewno chcesz to usunąć?';

  @override
  String get confirmApprove => 'Zatwierdźić tego użytkownika?';

  @override
  String get confirmApproveText =>
      'Czy na pewno chcesz zatwierdzić tego użytkownika?';

  @override
  String get confirmDisapprove => 'Potwierdź odrzucenie';

  @override
  String get confirmDisapproveText =>
      'Czy na pewno chcesz odrzucić tego użytkownika?';

  @override
  String get errorSavingData => 'Error Saving Data';

  @override
  String get userProfileEdit => 'Edytuj profil';

  @override
  String get userLoading => 'Ładowanie danych użytkownika/ów';

  @override
  String userHello(String userName) {
    return 'Witaj $userName';
  }

  @override
  String userWithName(String userName) {
    return 'Użytkownik: $userName';
  }

  @override
  String get userName => 'Nazwa użytkownika';

  @override
  String get userNewName => 'Nowa nazwa użytkownika';

  @override
  String get userFirstName => 'Imię';

  @override
  String get userLastName => 'Nazwisko';

  @override
  String get usernameTaken => 'Nazwa użytkownika jest już zajęta';

  @override
  String adminHello(String userName) {
    return 'Witaj na profilu admina $userName!';
  }

  @override
  String get userApprove => 'Zatwierdź użytkownika';

  @override
  String get userDataNotFound => 'Nie znaleziono danych użytkownika';

  @override
  String role(String userRole) {
    return 'Rola $userRole';
  }

  @override
  String get searchLocationPlaceholder => 'نSzukaj miejsca';

  @override
  String get mapTitle => ' Mapa';

  @override
  String get viewOnGoogleMaps => 'Zobacz na Google Maps';

  @override
  String get viewMaps => 'Zobacz maps';

  @override
  String get quickStatistics => 'Szybkie statystyki';

  @override
  String get activeTrucks => 'Aktywne ciężarówki';

  @override
  String get numberOfInterventions => 'Liczba interwencji';

  @override
  String get quickActions => 'Szybkie akcje';

  @override
  String get newIntervention => 'Nowa interwencja';

  @override
  String get dailyReport => 'Raport dzienny';

  @override
  String get maintenance => 'Utrzymanie';

  @override
  String get passForgot => 'Zapomniałeś hasła?';

  @override
  String get passNotMatch => 'Wpisane hasła się róźnią';

  @override
  String get passReset => 'Zresetuj hasło';

  @override
  String get passChange => 'Zmień hasło';

  @override
  String get passEnter => 'Podaj hasło';

  @override
  String get passRepeat => 'Powtórz hasło';

  @override
  String get eMail => 'Adres e-mail';

  @override
  String get eMailEnter => 'Wpisz e-mail';

  @override
  String get eMailOrUsernameEnter => 'Wpisz e-mail lub nazwę użytkownika';

  @override
  String get eMailSend => 'Wyślij e-mail resetujący hasło';

  @override
  String get company => 'Firma';

  @override
  String get companyList => 'Lista firm';

  @override
  String get companyAdd => 'Dodaj nową firmę';

  @override
  String get companyEdit => 'Edytuj dane firmy';

  @override
  String get companySelect => 'Wybierz firme';

  @override
  String get companyNotFound => 'Firmy nie odnaleziono';

  @override
  String companyWithName(String companyName) {
    return 'Firma: $companyName';
  }

  @override
  String get companyName => 'Nazwa firmy';

  @override
  String get companySiret => 'Siret';

  @override
  String get companySirene => 'Sirene';

  @override
  String get companyDescription => 'Opis firmy';

  @override
  String get companyPhone => 'Numer kontaktowy';

  @override
  String get companyEMail => 'E-mail kontaktowy';

  @override
  String get companyAddress => 'Adres korespondencyjny';

  @override
  String get companyResponsible => 'Osoba odpowiedzialna za kontakt';

  @override
  String get companyAdmin => 'Glowny admin firmy';

  @override
  String get companyLogo => 'Logo firmy';

  @override
  String get companyErrorLoading => 'Error loading Companies';

  @override
  String get camionType => 'Typ pojazdu';

  @override
  String get camionsList => 'Lista ciężarówek';

  @override
  String get camionName => 'Nazwa ciężarówki';

  @override
  String get camionResponsible => 'Osoba odpowiedzialna za pojazd';

  @override
  String get camionChecks => 'Kontrole samochodu';

  @override
  String get camionLastIntervention => 'Data ostatniej interwencji';

  @override
  String get camionTypesList => 'Lista typów ciężarówek';

  @override
  String get camionTypeName => 'Nazwa typu';

  @override
  String get camionTypeEquipment => 'Wyposażenie w pojeździe';

  @override
  String get camionTypeErrorLoading => 'Error loading CamionTypes';

  @override
  String get noCamionsAvailable => 'Brak dostępnych ciężarówek';

  @override
  String get camionMenuTrucks => 'Ciężarówki';

  @override
  String get camionMenuEquipment => 'Wyposażenie';

  @override
  String get camionMenuTypes => 'Typy';

  @override
  String get camionAddedSuccessfully => 'Truck added successfully';

  @override
  String get historyCheck => 'Historia sprawdzeń';

  @override
  String get checkPerformedOn => 'wykonał kontrolę na';

  @override
  String get timeAgo => 'temu';

  @override
  String get noChecksFound =>
      'Nie znaleziono żadnych kontroli dla Twojej firmy.';

  @override
  String get camionUpdatedSuccessfully => 'Truck updated successfully';

  @override
  String get sort => 'Sortuj';

  @override
  String get sortName => 'Sortuj według nazwy';

  @override
  String get sortType => 'Sortuj według typu';

  @override
  String get sortEntreprise => 'Sortuj według firmy';

  @override
  String get sortDescending => 'Sortuj A-Z/Z-A';

  @override
  String get filterType => 'Filtruj według typu';

  @override
  String get filterEntreprise => 'Filtruj według firmy';

  @override
  String get equipmentIdShop => 'Equipment id in stock';

  @override
  String get equipmentName => 'Nazwa sprzętu';

  @override
  String get equipmentList => 'Lista sprzętu';

  @override
  String get equipmentDescription => 'Opis sprzętu';

  @override
  String get equipmentQuantity => 'Quantity of this equipment';

  @override
  String get equipmentEnterQuantity => 'Please enter a valid quantity';

  @override
  String get equipmentErrorLoading => 'Error loading equipment';

  @override
  String get checkList => 'Checklista';

  @override
  String get checkListDescribe => 'Opisz problem';

  @override
  String get checkListValidation => 'Proces walidacji';

  @override
  String get blueprintAdd => 'Dodaj Blueprint';

  @override
  String get blueprintAddName => 'Dodaj nazwe Blueprinu';

  @override
  String get blueprintAddDescription => 'Dodaj opis Blueprinu';

  @override
  String get photoNotYet => 'Jeszcze nie ma zdjęcia';

  @override
  String get photoMake => 'Zrób zdjęcie';

  @override
  String get photoGallery => 'Wybierz z galerii';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get pdfCreate => 'Stwórz plik PDF';

  @override
  String get pdfList => 'Lista plików PDF';

  @override
  String get pdfMyFiles => 'Moje pliki PDF';

  @override
  String get pdfListAdmin => 'Lista plików PDF dla Admina';

  @override
  String pdfDownloaded(String fileName1, String fileName2) {
    return 'Twój plik PDF został zapisany pod nazwą: $fileName1.$fileName2.pdf';
  }

  @override
  String get listOfLists => 'Lista wszystkich list';

  @override
  String get lOLAdd => 'Dodaj listę';

  @override
  String get lOLEdit => 'Edytuj listę';

  @override
  String get lOLNumber => 'Numer listy';

  @override
  String get lOLNumberText => 'Proszę podaj numer listy';

  @override
  String get lOLName => 'Nazwa listy';

  @override
  String get lOLNameText => 'Proszę podaj nazwę listy';

  @override
  String lOLAuthorization(int person) {
    return 'Autoryzacja: $person';
  }

  @override
  String get lOLAddAuthoried => 'Dodaj autoryzowaną osobę';

  @override
  String listNumber(int number) {
    return 'Numer listy: $number';
  }

  @override
  String listPosition(int position) {
    return 'Pozycja na liście: $position';
  }

  @override
  String get manageUsers => 'Zarządzaj użytkownikami';

  @override
  String get superAdminPage => 'Strona SuperAdmina';

  @override
  String get adminPage => 'Strona Admina';

  @override
  String get accountNotYet => 'Nie masz jeszcze konta?';

  @override
  String get settings => 'Opcje';

  @override
  String get darkMode => 'Tryb nocny';

  @override
  String get language => 'Język';

  @override
  String get editInformation => 'Edytuj swój profil';

  @override
  String get messenger => 'Kominikator';

  @override
  String get enterMessage => 'Wpisz wiadomość';

  @override
  String dateCreation(String formattedDate) {
    return 'Data utworzenia: $formattedDate';
  }

  @override
  String get dataFetching => 'Pobieranie danych';

  @override
  String get dataReceived => 'Got data';

  @override
  String get dataNoData => 'Nie ma danych, przykro mi :(';

  @override
  String get dataNoDataOffLine => 'No data in offline mode, sorry :(';

  @override
  String get colorLight => 'Jasny';

  @override
  String get colorDark => 'Ciemny';

  @override
  String get colorAutomatic => 'Automatycznie';

  @override
  String get color => 'Kolor';
}

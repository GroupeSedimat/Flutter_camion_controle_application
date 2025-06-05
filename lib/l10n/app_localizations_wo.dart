// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Wolof (`wo`).
class AppLocalizationsWo extends AppLocalizations {
  AppLocalizationsWo([String locale = 'wo']) : super(locale);

  @override
  String get required => 'This field is required!';

  @override
  String get homePage => 'Xëtu dalal';

  @override
  String get welcomeToMC => 'Dalal jàmm ci MCTruckCheck';

  @override
  String get logIn => 'Duggal';

  @override
  String get logInText => 'Duggal ci sa kontu';

  @override
  String get signIn => 'Aboneel';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutText => 'Genn nañu la';

  @override
  String get loading => 'Loading...';

  @override
  String get status => 'Status';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Waaw';

  @override
  String get no => 'Déedéet';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Dëggal';

  @override
  String get cancel => 'Cancel';

  @override
  String get open => 'Open';

  @override
  String get download => 'Download';

  @override
  String get details => 'Xoolal leeraay yi';

  @override
  String get edit => 'Soppi';

  @override
  String get delete => 'Dindi';

  @override
  String get restore => 'Restore';

  @override
  String get confirmDelete => 'Firndeel efaase bi';

  @override
  String get confirmDeleteText => 'Ndax gëm nga ni bëgg nga efaase?';

  @override
  String get confirmApprove => 'Nangu jëfandikukat bii?';

  @override
  String get confirmApproveText =>
      'Ndax wóor nga ni bëgg nga nangu jëfandikukat bii?';

  @override
  String get confirmDisapprove => 'Firndelal ni nanguwoo';

  @override
  String get confirmDisapproveText =>
      'Ndax wóor nga ni bëggoo dàq jëfandikukat bii?';

  @override
  String get errorSavingData => 'Error Saving Data';

  @override
  String get userProfileEdit => 'Soppi profil';

  @override
  String get userLoading => 'Jëfandikukat(yi) di yobbu...';

  @override
  String userHello(String userName) {
    return 'Dalal ak jàmm $userName';
  }

  @override
  String userWithName(String userName) {
    return 'User: $userName';
  }

  @override
  String get userName => 'Tur jëfandikukat';

  @override
  String get userNewName => 'Turu jëfandikukat bu bees';

  @override
  String get userFirstName => 'Tur';

  @override
  String get userLastName => 'Sant';

  @override
  String get usernameTaken => 'Tur bi mujj na ci génne';

  @override
  String adminHello(String userName) {
    return 'Dalal jàmm ci xëtu admin bi, $userName';
  }

  @override
  String get userApprove => 'Nangu ab jëfandikukat';

  @override
  String get userDataNotFound => 'Amul benn done jëfandikukat';

  @override
  String role(String userRole) {
    return 'Cër $userRole';
  }

  @override
  String get searchLocationPlaceholder => 'Ndeyji ci jëm kanam';

  @override
  String get mapTitle => ' Màpp';

  @override
  String get viewOnGoogleMaps => 'nuyoo ci Google Maps';

  @override
  String get viewMaps => 'guiss maps';

  @override
  String get quickStatistics => 'Statistik yu am solo';

  @override
  String get activeTrucks => 'Kamiyon yu ngi ci wéet';

  @override
  String get numberOfInterventions => 'Ñaari am sañ-sañ';

  @override
  String get quickActions => 'Feykat yu am solo';

  @override
  String get newIntervention => 'Tëggin bu bees';

  @override
  String get dailyReport => 'Rapóor bu ndeyjoor';

  @override
  String get maintenance => 'Sàmm';

  @override
  String get passForgot => 'Fatte nga sa baatu-jàll?';

  @override
  String get passNotMatch => 'Baatu-jàll yi méngoo wuñu';

  @override
  String get passReset => 'Reset baatu-jàll';

  @override
  String get passChange => 'soppi baatu-jàll';

  @override
  String get passEnter => 'Bindal sa baatu-jàll';

  @override
  String get passRepeat => 'Baamtu sa baatu-jàll';

  @override
  String get eMail => 'Adres e-mail';

  @override
  String get eMailEnter => 'Dugalal sa e-mail';

  @override
  String get eMailOrUsernameEnter =>
      'Dugalal sa email wala turu jëfandikukat bi';

  @override
  String get eMailSend => 'Yonnee imeel reset';

  @override
  String get company => 'Këriñ';

  @override
  String get companyList => 'Limu liggéeyukaay yi';

  @override
  String get companyAdd => 'Yokk sosiete bu bees';

  @override
  String get companyEdit => 'Soppi leerali liggéeyukaay bi';

  @override
  String get companySelect => 'Tannal benn kompiñi';

  @override
  String get companyNotFound => 'Mënu ñu gis liggéeyukaay bi';

  @override
  String companyWithName(String companyName) {
    return 'Sosiete: $companyName';
  }

  @override
  String get companyName => 'Tur sosiete';

  @override
  String get companySiret => 'Siret';

  @override
  String get companySirene => 'Siren';

  @override
  String get companyDescription => 'Tegtal liggéeyukaay bi';

  @override
  String get companyPhone => 'Nimero jokkoo';

  @override
  String get companyEMail => 'Jokkoo ci e-mail';

  @override
  String get companyAddress => 'Adres bataaxal';

  @override
  String get companyResponsible => 'Nit ku yor jokkoo bi';

  @override
  String get companyAdmin => 'Admin bu mag bi ci liggéeyukaay bi';

  @override
  String get companyLogo => 'Logo liggéeyukaay bi';

  @override
  String get companyErrorLoading => 'Error loading Companies';

  @override
  String get camionType => 'Camion type';

  @override
  String get camionsList => 'Limu kamioŋ yi';

  @override
  String get camionName => 'Turu kamioŋ bi';

  @override
  String get camionResponsible => 'Ki yor oto bi';

  @override
  String get camionChecks => 'Saytu oto';

  @override
  String get camionLastIntervention => 'Bisu intervention bi mujjee';

  @override
  String get camionTypesList => 'Limu xeeti kamioŋ yi';

  @override
  String get camionTypeName => 'Tur xeetu';

  @override
  String get camionTypeEquipment => 'jumtukaay yi ci biir oto bi';

  @override
  String get camionTypeErrorLoading => 'Error loading CamionTypes';

  @override
  String get noCamionsAvailable => 'Amul camion';

  @override
  String get camionMenuTrucks => 'Camion';

  @override
  String get camionMenuEquipment => 'Jumtoo kay';

  @override
  String get camionMenuTypes => 'Xeet yi';

  @override
  String get camionAddedSuccessfully => 'Truck added successfully';

  @override
  String get historyCheck => 'Jéego yeneen seetukaay';

  @override
  String get checkPerformedOn => 'def na benn xeetu jëfandikukat ci';

  @override
  String get timeAgo => 'ba pare';

  @override
  String get noChecksFound =>
      'Amul benn jëfandikukat bu sosoon check ci sa kër gi.';

  @override
  String get camionUpdatedSuccessfully => 'Truck updated successfully';

  @override
  String get sort => 'Gënale';

  @override
  String get sortName => 'Tàngale ci Tur';

  @override
  String get sortType => 'tànnal ci xeetu';

  @override
  String get sortEntreprise => 'Tànnal ci Entreprise';

  @override
  String get sortDescending => 'Raññe A-Z/Z-A';

  @override
  String get filterType => 'Segg ci xeetu';

  @override
  String get filterEntreprise => 'Segg ci liggéeyukaay';

  @override
  String get equipmentIdShop => 'Equipment id in stock';

  @override
  String get equipmentName => 'Turu jumtukaay yi';

  @override
  String get equipmentList => 'Limu jumtukaay yi';

  @override
  String get equipmentDescription => 'Tegtal jumtukaay yi';

  @override
  String get equipmentQuantity => 'Quantity of this equipment';

  @override
  String get equipmentEnterQuantity => 'Please enter a valid quantity';

  @override
  String get equipmentErrorLoading => 'Error loading equipment';

  @override
  String get checkList => 'Limu saytu';

  @override
  String get checkListDescribe => 'Waxñu jafe-jafe bi';

  @override
  String get checkListValidation => 'Prosedur biy saytu';

  @override
  String get blueprintAdd => 'Yokk benn plan';

  @override
  String get blueprintAddName => 'Yokk turu plan';

  @override
  String get blueprintAddDescription => 'Yokk ay leeral ci plan bi';

  @override
  String get photoNotYet => 'Amagul nataal';

  @override
  String get photoMake => 'Defar nataal';

  @override
  String get photoGallery => 'Tannal benn nataal ci galëri bi';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get pdfCreate => 'Sosal PDF';

  @override
  String get pdfList => 'Limu PDF yi';

  @override
  String get pdfMyFiles => 'Samay fichier PDF';

  @override
  String get pdfListAdmin => 'Limu admin bu fichier pdf yi';

  @override
  String pdfDownloaded(String fileName1, String fileName2) {
    return 'Sa fichier PDF dañu ko denc ci tur wii: $fileName1.$fileName2.pdf';
  }

  @override
  String get listOfLists => 'Limu lim yi';

  @override
  String get lOLAdd => 'Yokk lim';

  @override
  String get lOLEdit => 'Soppi lim bi';

  @override
  String get lOLNumber => 'Nimero lim bi';

  @override
  String get lOLNumberText => 'Baalnu nga dugal nimero limu';

  @override
  String get lOLName => 'Tur lim bi';

  @override
  String get lOLNameText => 'Bindal tur limu';

  @override
  String lOLAuthorization(int person) {
    return 'May: $person';
  }

  @override
  String get lOLAddAuthoried => 'Yokk nit ku am sañ-sañ';

  @override
  String listNumber(int number) {
    return 'Nimero lim bi: $number';
  }

  @override
  String listPosition(int position) {
    return 'Limu barab yi: $position';
  }

  @override
  String get manageUsers => 'Doxal Jëfandikukat yi';

  @override
  String get superAdminPage => 'Xëtu admin bu baax';

  @override
  String get adminPage => 'Xëtu admin';

  @override
  String get accountNotYet => 'Amoo benn kontu??';

  @override
  String get settings => 'Jekkal';

  @override
  String get darkMode => 'Mode lëndëm';

  @override
  String get language => 'Kalamaa';

  @override
  String get editInformation => 'Soppi say leeral';

  @override
  String get messenger => 'Mesaas';

  @override
  String get enterMessage => 'Dugal sa mesaas';

  @override
  String dateCreation(String formattedDate) {
    return 'Bisu sos: $formattedDate';
  }

  @override
  String get dataFetching => 'Jël ay done';

  @override
  String get dataReceived => 'Am ay done';

  @override
  String get dataNoData => 'Amul ay done, mangi jeggalu :(';

  @override
  String get dataNoDataOffLine => 'No data in offline mode, sorry :(';

  @override
  String get colorLight => 'Leer';

  @override
  String get colorDark => 'Lëmësu';

  @override
  String get colorAutomatic => 'Otomatik';

  @override
  String get color => 'Melni';
}

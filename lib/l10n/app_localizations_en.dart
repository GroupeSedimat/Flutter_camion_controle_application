// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get required => 'This field is required!';

  @override
  String get homePage => 'Home page';

  @override
  String get welcomeToMC => 'Welcome to MCTruckCheck';

  @override
  String get logIn => 'Log in';

  @override
  String get logInText => 'Log in to your account';

  @override
  String get signIn => 'Sign in';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutText => 'You have been logged out';

  @override
  String get loading => 'Loading...';

  @override
  String get status => 'Status';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get open => 'Open';

  @override
  String get download => 'Download';

  @override
  String get details => 'See details';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get restore => 'Restore';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get confirmDeleteText => 'Are you sure you want to delete?';

  @override
  String get confirmApprove => 'Approve this user?';

  @override
  String get confirmApproveText =>
      'Are you sure you want to approve this user?';

  @override
  String get confirmDisapprove => 'Confirm disapproval';

  @override
  String get confirmDisapproveText =>
      'Are you sure you want to disapprove this user?';

  @override
  String get errorSavingData => 'Error Saving Data';

  @override
  String get userProfileEdit => 'Edit profile';

  @override
  String get userLoading => 'Loading user(s) data';

  @override
  String userHello(String userName) {
    return 'Welcome $userName';
  }

  @override
  String userWithName(String userName) {
    return 'User: $userName';
  }

  @override
  String get userName => 'User name';

  @override
  String get userNewName => 'New user name';

  @override
  String get userFirstName => 'First name';

  @override
  String get userLastName => 'Last name';

  @override
  String get usernameTaken => 'Username is already taken';

  @override
  String adminHello(String userName) {
    return 'Welcome to the admin page, $userName';
  }

  @override
  String get userApprove => 'Approve a user';

  @override
  String get userDataNotFound => 'No user data available';

  @override
  String role(String userRole) {
    return 'Role $userRole';
  }

  @override
  String get searchLocationPlaceholder => 'Search for a location';

  @override
  String get mapTitle => 'Map';

  @override
  String get viewOnGoogleMaps => 'View on Google Maps ';

  @override
  String get viewMaps => 'View maps ';

  @override
  String get quickStatistics => 'Quick Statistics';

  @override
  String get activeTrucks => 'Active Trucks';

  @override
  String get numberOfInterventions => 'Number of Interventions';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get newIntervention => 'New Intervention';

  @override
  String get dailyReport => 'Daily Report';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get passForgot => 'Forgot your password?';

  @override
  String get passNotMatch => 'Passwords do not match';

  @override
  String get passReset => 'Reset Password';

  @override
  String get passChange => 'Change password';

  @override
  String get passEnter => 'Enter your password';

  @override
  String get passRepeat => 'Repeat password';

  @override
  String get eMail => 'E-mail address';

  @override
  String get eMailEnter => 'Enter your e-mail';

  @override
  String get eMailOrUsernameEnter => 'Enter your email or username';

  @override
  String get eMailSend => 'Send reset e-mail';

  @override
  String get company => 'Company';

  @override
  String get companyList => 'Company list';

  @override
  String get companyAdd => 'Add new company';

  @override
  String get companyEdit => 'Edit company details';

  @override
  String get companySelect => 'Choose a company';

  @override
  String get companyNotFound => 'The company could not be found';

  @override
  String companyWithName(String companyName) {
    return 'Company: $companyName';
  }

  @override
  String get companyName => 'Company name';

  @override
  String get companySiret => 'Siret';

  @override
  String get companySirene => 'Sirene';

  @override
  String get companyDescription => 'Company description';

  @override
  String get companyPhone => 'Contact number';

  @override
  String get companyEMail => 'Contact e-mail';

  @override
  String get companyAddress => 'Correspondence address';

  @override
  String get companyResponsible => 'Person responsible for the contact';

  @override
  String get companyAdmin => 'The company\'s main admin';

  @override
  String get companyLogo => 'Company logo';

  @override
  String get companyErrorLoading => 'Error loading Companies';

  @override
  String get camionType => 'Camion type';

  @override
  String get camionsList => 'List of trucks';

  @override
  String get camionName => 'Truck\'s name';

  @override
  String get camionResponsible => 'Person responsible for the vehicle';

  @override
  String get camionChecks => 'Car checks';

  @override
  String get camionLastIntervention => 'Date of last intervention';

  @override
  String get camionTypesList => 'List of truck types';

  @override
  String get camionTypeName => 'Name of type';

  @override
  String get camionTypeEquipment => 'Equipment in the vehicle';

  @override
  String get camionTypeErrorLoading => 'Error loading CamionTypes';

  @override
  String get noCamionsAvailable => 'No trucks available';

  @override
  String get camionMenuTrucks => 'Trucks';

  @override
  String get camionMenuEquipment => 'Equipment';

  @override
  String get camionMenuTypes => 'Types';

  @override
  String get camionAddedSuccessfully => 'Truck added successfully';

  @override
  String get historyCheck => 'Check history';

  @override
  String get checkPerformedOn => 'performed a check on';

  @override
  String get timeAgo => 'ago';

  @override
  String get noChecksFound => 'No checks found for your company.';

  @override
  String get camionUpdatedSuccessfully => 'Truck updated successfully';

  @override
  String get sort => 'Sort';

  @override
  String get sortName => 'Sort by Name';

  @override
  String get sortType => 'Sort by Type';

  @override
  String get sortEntreprise => 'Sort by company';

  @override
  String get sortDescending => 'Sort A-Z/Z-A';

  @override
  String get filterType => 'Filter by Type';

  @override
  String get filterEntreprise => 'Filter by company';

  @override
  String get equipmentIdShop => 'Equipment id in stock';

  @override
  String get equipmentName => 'Name of equipment';

  @override
  String get equipmentList => 'List of equipments';

  @override
  String get equipmentDescription => 'Equipment\'s description';

  @override
  String get equipmentQuantity => 'Quantity of this equipment';

  @override
  String get equipmentEnterQuantity => 'Please enter a valid quantity';

  @override
  String get equipmentErrorLoading => 'Error loading equipment';

  @override
  String get checkList => 'Checklist';

  @override
  String get checkListDescribe => 'Describe the problem';

  @override
  String get checkListValidation => 'Validation process';

  @override
  String get blueprintAdd => 'Add a Blueprint';

  @override
  String get blueprintAddName => 'Add Blueprint name';

  @override
  String get blueprintAddDescription => 'Add Blueprint description';

  @override
  String get photoNotYet => 'No photo yet';

  @override
  String get photoMake => 'Make photo';

  @override
  String get photoGallery => 'Choose from gallery';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get pdfCreate => 'Create PDF';

  @override
  String get pdfList => 'PDF file list';

  @override
  String get pdfMyFiles => 'My PDF files';

  @override
  String get pdfListAdmin => 'Admin PDF file list';

  @override
  String pdfDownloaded(String fileName1, String fileName2) {
    return 'Your PDF file has been saved as: $fileName1.$fileName2.pdf';
  }

  @override
  String get listOfLists => 'The list of lists';

  @override
  String get lOLAdd => 'Add List';

  @override
  String get lOLEdit => 'Edit List';

  @override
  String get lOLNumber => 'List number';

  @override
  String get lOLNumberText => 'Please enter list number';

  @override
  String get lOLName => 'List name';

  @override
  String get lOLNameText => 'Please enter list name';

  @override
  String lOLAuthorization(int person) {
    return 'Authorization: $person';
  }

  @override
  String get lOLAddAuthoried => 'Add authorized person';

  @override
  String listNumber(int number) {
    return 'List number: $number';
  }

  @override
  String listPosition(int position) {
    return 'List position: $position';
  }

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get superAdminPage => 'Super Admin Page';

  @override
  String get adminPage => 'Admin Page';

  @override
  String get accountNotYet => 'Don\'t have an account yet?';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get editInformation => 'Edit your information';

  @override
  String get messenger => 'Instant messenger';

  @override
  String get enterMessage => 'Enter your message';

  @override
  String dateCreation(String formattedDate) {
    return 'Creation date: $formattedDate';
  }

  @override
  String get dataFetching => 'Fetching data';

  @override
  String get dataReceived => 'Got data';

  @override
  String get dataNoData => 'No data, sorry :(';

  @override
  String get dataNoDataOffLine => 'No data in offline mode, sorry :(';

  @override
  String get colorLight => 'Light';

  @override
  String get colorDark => 'Dark';

  @override
  String get colorAutomatic => 'Automatic';

  @override
  String get color => 'Color';
}

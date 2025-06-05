import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_wo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('pl'),
    Locale('wo'),
    Locale('nl'),
    Locale('ar')
  ];

  /// This field is required!
  ///
  /// In en, this message translates to:
  /// **'This field is required!'**
  String get required;

  /// Home page
  ///
  /// In en, this message translates to:
  /// **'Home page'**
  String get homePage;

  /// Welcome to MCTruckCheck
  ///
  /// In en, this message translates to:
  /// **'Welcome to MCTruckCheck'**
  String get welcomeToMC;

  /// Log in
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// Log in to your account
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get logInText;

  /// Sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Log out
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// You have been logged out
  ///
  /// In en, this message translates to:
  /// **'You have been logged out'**
  String get logOutText;

  /// Loading...
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Download
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// See details
  ///
  /// In en, this message translates to:
  /// **'See details'**
  String get details;

  /// Edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Confirm deletion
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// Are you sure you want to delete?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDeleteText;

  /// Approve this user?
  ///
  /// In en, this message translates to:
  /// **'Approve this user?'**
  String get confirmApprove;

  /// Are you sure you want to approve this user?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this user?'**
  String get confirmApproveText;

  /// Confirm disapproval
  ///
  /// In en, this message translates to:
  /// **'Confirm disapproval'**
  String get confirmDisapprove;

  /// Are you sure you want to disapprove this user?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disapprove this user?'**
  String get confirmDisapproveText;

  /// No description provided for @errorSavingData.
  ///
  /// In en, this message translates to:
  /// **'Error Saving Data'**
  String get errorSavingData;

  /// Edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get userProfileEdit;

  /// Loading user(s) data
  ///
  /// In en, this message translates to:
  /// **'Loading user(s) data'**
  String get userLoading;

  /// Greeting user with username
  ///
  /// In en, this message translates to:
  /// **'Welcome {userName}'**
  String userHello(String userName);

  /// A string specifying which user the variable name refers to
  ///
  /// In en, this message translates to:
  /// **'User: {userName}'**
  String userWithName(String userName);

  /// User name
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get userName;

  /// New user name
  ///
  /// In en, this message translates to:
  /// **'New user name'**
  String get userNewName;

  /// First name
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get userFirstName;

  /// Last name
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get userLastName;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameTaken;

  /// Greeting admin by username
  ///
  /// In en, this message translates to:
  /// **'Welcome to the admin page, {userName}'**
  String adminHello(String userName);

  /// Approve a user
  ///
  /// In en, this message translates to:
  /// **'Approve a user'**
  String get userApprove;

  /// No user data available
  ///
  /// In en, this message translates to:
  /// **'No user data available'**
  String get userDataNotFound;

  /// Role of the user
  ///
  /// In en, this message translates to:
  /// **'Role {userRole}'**
  String role(String userRole);

  /// No description provided for @searchLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a location'**
  String get searchLocationPlaceholder;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @viewOnGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'View on Google Maps '**
  String get viewOnGoogleMaps;

  /// No description provided for @viewMaps.
  ///
  /// In en, this message translates to:
  /// **'View maps '**
  String get viewMaps;

  /// No description provided for @quickStatistics.
  ///
  /// In en, this message translates to:
  /// **'Quick Statistics'**
  String get quickStatistics;

  /// No description provided for @activeTrucks.
  ///
  /// In en, this message translates to:
  /// **'Active Trucks'**
  String get activeTrucks;

  /// No description provided for @numberOfInterventions.
  ///
  /// In en, this message translates to:
  /// **'Number of Interventions'**
  String get numberOfInterventions;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newIntervention.
  ///
  /// In en, this message translates to:
  /// **'New Intervention'**
  String get newIntervention;

  /// No description provided for @dailyReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Report'**
  String get dailyReport;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// Forgot your password?
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get passForgot;

  /// Passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passNotMatch;

  /// Reset Password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get passReset;

  /// Change password
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passChange;

  /// Enter your password
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passEnter;

  /// Repeat password
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get passRepeat;

  /// E-mail address
  ///
  /// In en, this message translates to:
  /// **'E-mail address'**
  String get eMail;

  /// Enter your e-mail
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail'**
  String get eMailEnter;

  /// No description provided for @eMailOrUsernameEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get eMailOrUsernameEnter;

  /// Send reset e-mail
  ///
  /// In en, this message translates to:
  /// **'Send reset e-mail'**
  String get eMailSend;

  /// Company
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// Company list
  ///
  /// In en, this message translates to:
  /// **'Company list'**
  String get companyList;

  /// Add new company
  ///
  /// In en, this message translates to:
  /// **'Add new company'**
  String get companyAdd;

  /// Edit company details
  ///
  /// In en, this message translates to:
  /// **'Edit company details'**
  String get companyEdit;

  /// Choose a company
  ///
  /// In en, this message translates to:
  /// **'Choose a company'**
  String get companySelect;

  /// The company could not be found
  ///
  /// In en, this message translates to:
  /// **'The company could not be found'**
  String get companyNotFound;

  /// A string specifying which company the variable name refers to
  ///
  /// In en, this message translates to:
  /// **'Company: {companyName}'**
  String companyWithName(String companyName);

  /// Company name
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// Siret
  ///
  /// In en, this message translates to:
  /// **'Siret'**
  String get companySiret;

  /// Sirene
  ///
  /// In en, this message translates to:
  /// **'Sirene'**
  String get companySirene;

  /// Company description
  ///
  /// In en, this message translates to:
  /// **'Company description'**
  String get companyDescription;

  /// Contact number
  ///
  /// In en, this message translates to:
  /// **'Contact number'**
  String get companyPhone;

  /// Contact e-mail
  ///
  /// In en, this message translates to:
  /// **'Contact e-mail'**
  String get companyEMail;

  /// Correspondence address
  ///
  /// In en, this message translates to:
  /// **'Correspondence address'**
  String get companyAddress;

  /// Person responsible for the contact
  ///
  /// In en, this message translates to:
  /// **'Person responsible for the contact'**
  String get companyResponsible;

  /// The company's main admin
  ///
  /// In en, this message translates to:
  /// **'The company\'s main admin'**
  String get companyAdmin;

  /// Company logo
  ///
  /// In en, this message translates to:
  /// **'Company logo'**
  String get companyLogo;

  /// No description provided for @companyErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading Companies'**
  String get companyErrorLoading;

  /// No description provided for @camionType.
  ///
  /// In en, this message translates to:
  /// **'Camion type'**
  String get camionType;

  /// No description provided for @camionsList.
  ///
  /// In en, this message translates to:
  /// **'List of trucks'**
  String get camionsList;

  /// No description provided for @camionName.
  ///
  /// In en, this message translates to:
  /// **'Truck\'s name'**
  String get camionName;

  /// No description provided for @camionResponsible.
  ///
  /// In en, this message translates to:
  /// **'Person responsible for the vehicle'**
  String get camionResponsible;

  /// No description provided for @camionChecks.
  ///
  /// In en, this message translates to:
  /// **'Car checks'**
  String get camionChecks;

  /// No description provided for @camionLastIntervention.
  ///
  /// In en, this message translates to:
  /// **'Date of last intervention'**
  String get camionLastIntervention;

  /// No description provided for @camionTypesList.
  ///
  /// In en, this message translates to:
  /// **'List of truck types'**
  String get camionTypesList;

  /// No description provided for @camionTypeName.
  ///
  /// In en, this message translates to:
  /// **'Name of type'**
  String get camionTypeName;

  /// No description provided for @camionTypeEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment in the vehicle'**
  String get camionTypeEquipment;

  /// No description provided for @camionTypeErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading CamionTypes'**
  String get camionTypeErrorLoading;

  /// No description provided for @noCamionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No trucks available'**
  String get noCamionsAvailable;

  /// No description provided for @camionMenuTrucks.
  ///
  /// In en, this message translates to:
  /// **'Trucks'**
  String get camionMenuTrucks;

  /// No description provided for @camionMenuEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get camionMenuEquipment;

  /// No description provided for @camionMenuTypes.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get camionMenuTypes;

  /// No description provided for @camionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Truck added successfully'**
  String get camionAddedSuccessfully;

  /// No description provided for @historyCheck.
  ///
  /// In en, this message translates to:
  /// **'Check history'**
  String get historyCheck;

  /// No description provided for @checkPerformedOn.
  ///
  /// In en, this message translates to:
  /// **'performed a check on'**
  String get checkPerformedOn;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'ago'**
  String get timeAgo;

  /// No description provided for @noChecksFound.
  ///
  /// In en, this message translates to:
  /// **'No checks found for your company.'**
  String get noChecksFound;

  /// No description provided for @camionUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Truck updated successfully'**
  String get camionUpdatedSuccessfully;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Sort by Name'**
  String get sortName;

  /// No description provided for @sortType.
  ///
  /// In en, this message translates to:
  /// **'Sort by Type'**
  String get sortType;

  /// No description provided for @sortEntreprise.
  ///
  /// In en, this message translates to:
  /// **'Sort by company'**
  String get sortEntreprise;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Sort A-Z/Z-A'**
  String get sortDescending;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get filterType;

  /// No description provided for @filterEntreprise.
  ///
  /// In en, this message translates to:
  /// **'Filter by company'**
  String get filterEntreprise;

  /// No description provided for @equipmentIdShop.
  ///
  /// In en, this message translates to:
  /// **'Equipment id in stock'**
  String get equipmentIdShop;

  /// No description provided for @equipmentName.
  ///
  /// In en, this message translates to:
  /// **'Name of equipment'**
  String get equipmentName;

  /// No description provided for @equipmentList.
  ///
  /// In en, this message translates to:
  /// **'List of equipments'**
  String get equipmentList;

  /// No description provided for @equipmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Equipment\'s description'**
  String get equipmentDescription;

  /// No description provided for @equipmentQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity of this equipment'**
  String get equipmentQuantity;

  /// No description provided for @equipmentEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get equipmentEnterQuantity;

  /// No description provided for @equipmentErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading equipment'**
  String get equipmentErrorLoading;

  /// Checklist
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checkList;

  /// Describe the problem
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get checkListDescribe;

  /// Validation process
  ///
  /// In en, this message translates to:
  /// **'Validation process'**
  String get checkListValidation;

  /// Add a Blueprint
  ///
  /// In en, this message translates to:
  /// **'Add a Blueprint'**
  String get blueprintAdd;

  /// Add Blueprint name
  ///
  /// In en, this message translates to:
  /// **'Add Blueprint name'**
  String get blueprintAddName;

  /// Add Blueprint description
  ///
  /// In en, this message translates to:
  /// **'Add Blueprint description'**
  String get blueprintAddDescription;

  /// No photo yet
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get photoNotYet;

  /// Make photo
  ///
  /// In en, this message translates to:
  /// **'Make photo'**
  String get photoMake;

  /// Choose from gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoGallery;

  /// No description provided for @photoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get photoAdd;

  /// Create PDF
  ///
  /// In en, this message translates to:
  /// **'Create PDF'**
  String get pdfCreate;

  /// PDF file list
  ///
  /// In en, this message translates to:
  /// **'PDF file list'**
  String get pdfList;

  /// My PDF files
  ///
  /// In en, this message translates to:
  /// **'My PDF files'**
  String get pdfMyFiles;

  /// Admin PDF file list
  ///
  /// In en, this message translates to:
  /// **'Admin PDF file list'**
  String get pdfListAdmin;

  /// Your PDF file has been saved as: {fileName1}.{fileName2}.pdf
  ///
  /// In en, this message translates to:
  /// **'Your PDF file has been saved as: {fileName1}.{fileName2}.pdf'**
  String pdfDownloaded(String fileName1, String fileName2);

  /// The list of lists
  ///
  /// In en, this message translates to:
  /// **'The list of lists'**
  String get listOfLists;

  /// Add List
  ///
  /// In en, this message translates to:
  /// **'Add List'**
  String get lOLAdd;

  /// Edit List
  ///
  /// In en, this message translates to:
  /// **'Edit List'**
  String get lOLEdit;

  /// List number
  ///
  /// In en, this message translates to:
  /// **'List number'**
  String get lOLNumber;

  /// Please enter list number
  ///
  /// In en, this message translates to:
  /// **'Please enter list number'**
  String get lOLNumberText;

  /// List name
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get lOLName;

  /// Please enter list name
  ///
  /// In en, this message translates to:
  /// **'Please enter list name'**
  String get lOLNameText;

  /// Person authorized to see the list
  ///
  /// In en, this message translates to:
  /// **'Authorization: {person}'**
  String lOLAuthorization(int person);

  /// Add authorized person
  ///
  /// In en, this message translates to:
  /// **'Add authorized person'**
  String get lOLAddAuthoried;

  /// The list number to which the blueprint is assigned
  ///
  /// In en, this message translates to:
  /// **'List number: {number}'**
  String listNumber(int number);

  /// The number of the position on the list to which the blueprint is assigned
  ///
  /// In en, this message translates to:
  /// **'List position: {position}'**
  String listPosition(int position);

  /// Manage Users
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// Super Admin Page
  ///
  /// In en, this message translates to:
  /// **'Super Admin Page'**
  String get superAdminPage;

  /// Admin Page
  ///
  /// In en, this message translates to:
  /// **'Admin Page'**
  String get adminPage;

  /// Don't have an account yet?
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get accountNotYet;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dark Mode
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Edit your information
  ///
  /// In en, this message translates to:
  /// **'Edit your information'**
  String get editInformation;

  /// Instant messenger
  ///
  /// In en, this message translates to:
  /// **'Instant messenger'**
  String get messenger;

  /// Enter your message
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get enterMessage;

  /// Creation date
  ///
  /// In en, this message translates to:
  /// **'Creation date: {formattedDate}'**
  String dateCreation(String formattedDate);

  /// Fetching data
  ///
  /// In en, this message translates to:
  /// **'Fetching data'**
  String get dataFetching;

  /// Got data
  ///
  /// In en, this message translates to:
  /// **'Got data'**
  String get dataReceived;

  /// No data, sorry :(
  ///
  /// In en, this message translates to:
  /// **'No data, sorry :('**
  String get dataNoData;

  /// No description provided for @dataNoDataOffLine.
  ///
  /// In en, this message translates to:
  /// **'No data in offline mode, sorry :('**
  String get dataNoDataOffLine;

  /// Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get colorLight;

  /// Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get colorDark;

  /// Automatic
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get colorAutomatic;

  /// Color
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'fr',
        'nl',
        'pl',
        'wo'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'wo':
      return AppLocalizationsWo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get required => 'هذه الخانة مطلوبه!';

  @override
  String get homePage => 'الصفحة الرئيسية';

  @override
  String get welcomeToMC => 'مرحبا بكم في MCTruckCheck';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get logInText => 'قم بتسجيل الدخول إلى حسابك';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutText => 'لقد تم تسجيل خروجك';

  @override
  String get loading => 'تحميل...';

  @override
  String get status => 'الحالة';

  @override
  String get ok => 'نعم';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'نعم';

  @override
  String get add => 'يضيف';

  @override
  String get confirm => 'يتأكد';

  @override
  String get cancel => 'يلغي';

  @override
  String get open => 'يفتح';

  @override
  String get download => 'تحميل';

  @override
  String get details => 'انظر التفاصيل';

  @override
  String get edit => 'يحرر';

  @override
  String get delete => 'يمسح';

  @override
  String get restore => 'Restore';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmDeleteText => 'هل أنت متأكد أنك تريد الحذف؟';

  @override
  String get confirmApprove => 'هل توافق على هذا المستخدم؟';

  @override
  String get confirmApproveText =>
      'هل أنت متأكد أنك تريد الموافقة على هذا المستخدم؟';

  @override
  String get confirmDisapprove => 'تأكيد الرفض';

  @override
  String get confirmDisapproveText => 'هل أنت متأكد أنك تريد رفض هذا المستخدم؟';

  @override
  String get errorSavingData => 'Error Saving Data';

  @override
  String get userProfileEdit => 'تحرير الملفات الشخصية';

  @override
  String get userLoading => 'تحميل بيانات المستخدم (المستخدمين).';

  @override
  String userHello(String userName) {
    return 'مرحبًا $userName';
  }

  @override
  String userWithName(String userName) {
    return 'المستخدم: $userName';
  }

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get userNewName => 'اسم مستخدم جديد';

  @override
  String get userFirstName => 'الاسم الأول';

  @override
  String get userLastName => 'اسم العائلة';

  @override
  String get usernameTaken => 'اسم المستخدم تم أخذه بالفعل';

  @override
  String adminHello(String userName) {
    return 'مرحبًا بك في صفحة المشرف، $userName';
  }

  @override
  String get userApprove => 'الموافقة على مستخدم';

  @override
  String get userDataNotFound => 'لا توجد بيانات المستخدم المتاحة';

  @override
  String role(String userRole) {
    return 'الأدوار $userRole';
  }

  @override
  String get searchLocationPlaceholder => 'ابحث عن مكان';

  @override
  String get mapTitle => 'بطاقة';

  @override
  String get viewOnGoogleMaps => 'عرض على خرائط جوجل';

  @override
  String get viewMaps => 'عرض على خرائط جوجل';

  @override
  String get quickStatistics => 'الإحصائيات السريعة';

  @override
  String get activeTrucks => 'الشاحنات النشطة';

  @override
  String get numberOfInterventions => 'عدد التدخلات';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get newIntervention => 'تدخل جديد';

  @override
  String get dailyReport => 'التقرير اليومي';

  @override
  String get maintenance => 'الصيانة';

  @override
  String get passForgot => 'نسيت كلمة السر؟';

  @override
  String get passNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passReset => 'إعادة تعيين كلمة المرور';

  @override
  String get passChange => 'تغيير كلمة المرور';

  @override
  String get passEnter => 'أدخل كلمة المرور الخاصة بك';

  @override
  String get passRepeat => 'كرر كلمة المرور';

  @override
  String get eMail => 'عنوان البريد الإلكتروني';

  @override
  String get eMailEnter => 'أدخل بريدك الإلكتروني';

  @override
  String get eMailOrUsernameEnter => 'أدخل بريدك الإلكتروني أو اسم المستخدم';

  @override
  String get eMailSend => 'إرسال إعادة تعيين البريد الإلكتروني';

  @override
  String get company => 'شركة';

  @override
  String get companyList => 'قائمة الشركة';

  @override
  String get companyAdd => 'إضافة شركة جديدة';

  @override
  String get companyEdit => 'تحرير تفاصيل الشركة';

  @override
  String get companySelect => 'اختر شركة';

  @override
  String get companyNotFound => 'لا يمكن العثور على الشركة';

  @override
  String companyWithName(String companyName) {
    return 'الشركة: $companyName';
  }

  @override
  String get companyName => 'اسم الشركة';

  @override
  String get companySiret => 'سيريت';

  @override
  String get companySirene => 'سيرينا';

  @override
  String get companyDescription => 'وصف الشركة';

  @override
  String get companyPhone => 'رقم الاتصال';

  @override
  String get companyEMail => 'الاتصال بالبريد الإلكتروني';

  @override
  String get companyAddress => 'عنوان المراسلة';

  @override
  String get companyResponsible => 'الشخص المسؤول عن الاتصال';

  @override
  String get companyAdmin => 'المشرف الرئيسي للشركة';

  @override
  String get companyLogo => 'شعار الشركة';

  @override
  String get companyErrorLoading => 'Error loading Companies';

  @override
  String get camionType => 'نوع الشاحنة';

  @override
  String get camionsList => 'قائمة الشاحنات';

  @override
  String get camionName => 'اسم الشاحنة';

  @override
  String get camionResponsible => 'الشخص المسؤول عن المركبة';

  @override
  String get camionChecks => 'فحوصات السيارة';

  @override
  String get camionLastIntervention => 'تاريخ آخر تدخل';

  @override
  String get camionTypesList => 'قائمة أنواع الشاحنات';

  @override
  String get camionTypeName => 'اسم النوع';

  @override
  String get camionTypeEquipment => 'المعدات الموجودة في المركبة';

  @override
  String get camionTypeErrorLoading => 'Error loading CamionTypes';

  @override
  String get noCamionsAvailable => 'لا توجد شاحنات متاحة';

  @override
  String get camionMenuTrucks => 'الشاحنات';

  @override
  String get camionMenuEquipment => 'المعدات';

  @override
  String get camionMenuTypes => 'الأنواع';

  @override
  String get camionAddedSuccessfully => 'Truck added successfully';

  @override
  String get historyCheck => 'سجل الفحوصات';

  @override
  String get checkPerformedOn => 'أجرى فحصًا على';

  @override
  String get timeAgo => 'منذ';

  @override
  String get noChecksFound => 'لم يتم العثور على أي فحص لشركتك.';

  @override
  String get camionUpdatedSuccessfully => 'Truck updated successfully';

  @override
  String get sort => 'الفرز';

  @override
  String get sortName => 'الفرز حسب الاسم';

  @override
  String get sortType => 'الفرز حسب النوع';

  @override
  String get sortEntreprise => 'الفرز حسب المؤسسة';

  @override
  String get sortDescending => 'الفرز من الألف إلى الياء/من الياء إلى الألف';

  @override
  String get filterType => 'التصفية حسب النوع';

  @override
  String get filterEntreprise => 'التصفية حسب المؤسسة';

  @override
  String get equipmentIdShop => 'Equipment id in stock';

  @override
  String get equipmentName => 'اسم المعدات';

  @override
  String get equipmentList => 'قائمة المعدات';

  @override
  String get equipmentDescription => 'وصف المعدات';

  @override
  String get equipmentQuantity => 'Quantity of this equipment';

  @override
  String get equipmentEnterQuantity => 'Please enter a valid quantity';

  @override
  String get equipmentErrorLoading => 'Error loading equipment';

  @override
  String get checkList => 'قائمة التحقق';

  @override
  String get checkListDescribe => 'صف المشكلة';

  @override
  String get checkListValidation => 'عملية التحقق من الصحة';

  @override
  String get blueprintAdd => 'أضف مخططًا';

  @override
  String get blueprintAddName => 'أضف اسم المخطط';

  @override
  String get blueprintAddDescription => 'إضافة وصف المخطط';

  @override
  String get photoNotYet => 'لا توجد صورة بعد';

  @override
  String get photoMake => 'اصنع صورة';

  @override
  String get photoGallery => 'اختر من المعرض';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get pdfCreate => 'إنشاء قوات الدفاع الشعبي';

  @override
  String get pdfList => 'قائمة ملفات PDF';

  @override
  String get pdfMyFiles => 'ملفات PDF الخاصة بي';

  @override
  String get pdfListAdmin => 'قائمة ملفات PDF المشرف';

  @override
  String pdfDownloaded(String fileName1, String fileName2) {
    return 'تم حفظ ملف PDF الخاص بك باسم: $fileName1.$fileName2.pdf';
  }

  @override
  String get listOfLists => 'قائمة القوائم';

  @override
  String get lOLAdd => 'إضافة قائمة';

  @override
  String get lOLEdit => 'تحرير القائمة';

  @override
  String get lOLNumber => 'رقم الرسالة';

  @override
  String get lOLNumberText => 'الرجاء إدخال رقم القائمة';

  @override
  String get lOLName => 'اسم الرسالة';

  @override
  String get lOLNameText => 'الرجاء إدخال اسم القائمة';

  @override
  String lOLAuthorization(int person) {
    return 'التفويض: $person';
  }

  @override
  String get lOLAddAuthoried => 'أضف الشخص المعتمد';

  @override
  String listNumber(int number) {
    return 'رقم القائمة: $number';
  }

  @override
  String listPosition(int position) {
    return 'موضع القائمة: $position';
  }

  @override
  String get manageUsers => 'إدارة المستخدمين';

  @override
  String get superAdminPage => 'صفحة المشرف الفائقة';

  @override
  String get adminPage => 'صفحة المشرف';

  @override
  String get accountNotYet => 'ليس لديك حساب حتى الآن؟';

  @override
  String get settings => 'إعدادات';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get language => 'لغة';

  @override
  String get editInformation => 'تحرير المعلومات الخاصة بك';

  @override
  String get messenger => 'رسول فوري';

  @override
  String get enterMessage => 'أدخل رسالتك';

  @override
  String dateCreation(String formattedDate) {
    return 'تاريخ الإنشاء: $formattedDate';
  }

  @override
  String get dataFetching => 'جلب البيانات';

  @override
  String get dataReceived => 'حصلت على موعد';

  @override
  String get dataNoData => 'لا يوجد تاريخ، آسف :(';

  @override
  String get dataNoDataOffLine => 'No data in offline mode, sorry :(';

  @override
  String get colorLight => 'ضوء';

  @override
  String get colorDark => 'مظلم';

  @override
  String get colorAutomatic => 'تلقائي';

  @override
  String get color => 'كولوr';
}

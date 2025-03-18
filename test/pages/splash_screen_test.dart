
import 'package:flutter_application_1/locale_provider.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); 

  setUp(() async {
    // Initialise SharedPreferences pour éviter les erreurs
    SharedPreferences.setMockInitialValues({});
  });

  test('LocaleProvider setLocale fonctionne correctement', () async {
    final localeProvider = LocaleProvider('en');

    // Vérifie si la locale initiale est 'en'
    expect(localeProvider.locale.languageCode, 'en');

    // Change la locale en 'fr'
    await localeProvider.setLocale('fr'); 

    // Vérifie si la locale a bien été changée
    expect(localeProvider.locale.languageCode, 'fr');
  });
}

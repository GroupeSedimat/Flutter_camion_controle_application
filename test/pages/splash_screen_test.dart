import 'package:flutter_application_1/pages/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';


void main() {
  testWidgets('Le bouton Log In est accessible et cliquable', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: SplashScreen(),
      ),
    );

    
    final logInButton = find.text('Log In');
    expect(logInButton, findsOneWidget);

    
    await tester.tap(logInButton);

    
    await tester.pumpAndSettle();
  });
}
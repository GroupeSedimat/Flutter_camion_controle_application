import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user/login_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';



class FakeAuthController extends GetxController {
  void login(String identifier, String password) {
 
    print("Connexion simulée pour $identifier avec mot de passe $password");
  }
}
void main() {
  testWidgets('LoginPage displays correctly and triggers login action', (WidgetTester tester) async {

    final fakeAuthController = FakeAuthController();
    Get.put<FakeAuthController>(fakeAuthController);

    await tester.pumpWidget(
      GetMaterialApp(
        home: LoginPage(),
      ),
    );

    expect(find.text('Email or Username'), findsOneWidget);   
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('Login'));

    await tester.pump();

    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });
}

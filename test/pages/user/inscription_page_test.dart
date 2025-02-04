
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getWelcomeText returns correct text', () {
    // Appel de la fonction
    final text = getWelcomeText();

    // Vérification de la valeur retournée
    expect(text, 'Welcome to the app!');
  });
}
String getWelcomeText() {
  return 'Welcome to the app!';
}




//test widget commenté
/**void main() {
  testWidgets('Text visibility test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text('Welcome to the app!'),
        ),
      ),
    );

    
    expect(find.text('Welcome to the app!'), findsOneWidget);
  });



  
}**/

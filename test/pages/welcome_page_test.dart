import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        //AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: child,
    );
  }

  testWidgets('Affiche un indicateur de chargement lorsque FutureBuilder est en attente', (WidgetTester tester) async {
   
    await tester.pumpWidget(
      createTestableWidget(FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return const Text("Done");
          }
        },
      )),
    );

   
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));


    expect(find.text("Done"), findsOneWidget);
  });

 /** testWidgets('Affiche le message d\'erreur si une erreur survient dans FutureBuilder', (WidgetTester tester) async {
  
    await tester.pumpWidget(
      createTestableWidget(FutureBuilder(
        future: Future.error("Erreur simulée"),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return const CircularProgressIndicator();
          }
        },
      )),
    );

    await tester.pump();

    // Vérifie que le message d'erreur est affiché
    expect(find.textContaining("Error: Erreur simulée"), findsOneWidget);
  }); */ 

  /**testWidgets('Affiche un message de bienvenue pour un utilisateur admin', (WidgetTester tester) async {
    // Simule un utilisateur admin
    //final MyUser testUser = MyUser(username: "AdminUser", role: "admin", email: '', name: '', company: '', firstname: '', apresFormationDoc: '', camion: '');

    FutureOr<MyUser>? testUser;
    await tester.pumpWidget(
      createTestableWidget(FutureBuilder<MyUser>(
        future: Future.value(testUser), 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            final message = user.role == 'admin'
                ? 'Hello AdminUser'
                : 'Hello ${user.username}';
            return Text(message);
          } else {
            return const CircularProgressIndicator();
          }
        },
      )),
    );

    // Laisse le Future se résoudre
    await tester.pump();

    // Vérifie que le message "Hello AdminUser" est affiché
    expect(find.text('Hello AdminUser'), findsOneWidget);
  }); **/

  testWidgets('Affiche un bouton et vérifie qu\'il est cliquable', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(
        ElevatedButton(
          onPressed: () {},
          child: const Text('Voir maps'),
        ),
      ),
    );

    // Vérifie que le bouton "Voir maps" est affiché
    expect(find.text('Voir maps'), findsOneWidget);

    // Simule un clic sur le bouton
    await tester.tap(find.text('Voir maps'));
    await tester.pump();


  });

  /**testWidgets('Affiche "No data available" si aucune donnée utilisateur n\'est disponible', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestableWidget(FutureBuilder<MyUser>(
        future: Future.value(null),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text("No data available");
          } else {
            final user = snapshot.data!;
            return Text('Hello ${user.username}');
          }
        },
      )),
    );

    // Laisse le Future se résoudre
    await tester.pump();
    expect(find.text('No data available'), findsOneWidget);
  }); **/
}
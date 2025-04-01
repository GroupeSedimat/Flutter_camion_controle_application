import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/menu.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class BasePage extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final String? title;
  const BasePage({super.key, required this.body, this.appBar, this.title});

  /// La base de chaque nouvelle page
  ///
  ///Lors de la création d'une page, ajoutez-la comme "body"
  /// "BasePage(
  ///  title : _titre(),
  ///  body : _buildBody(),
  ///  )
  ///  en changeant les couleurs et le thème ici, vous les changez pour toute l'application
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: appBar ?? AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        /// Entrez "titre" pour utiliser la AppBar intégrée avec le nom du site
        /// Créez votre propre AppBar et appelez-la comme "appBar"
        title: Text(
            title ?? "",
            style: TextStyle(
              color: Colors.black,
            ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(() => SettingsPage());
            },
          ),
        ],
      ),
      /// le menu est ajouté à chaque page
      drawer: MenuWidget(),
      /// "body" que vous créez sera affiché sur la page avec le même thème que sur les autres pages.
      body: body,
    );
  }
}
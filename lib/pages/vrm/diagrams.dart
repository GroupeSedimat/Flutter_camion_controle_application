import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/base_page.dart';
import 'package:flutter_application_1/pages/vrm/loading.dart';
import 'package:flutter_application_1/services/data_api/get_data.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// la classe était initialement censée afficher des diagrammes basés
/// sur des données téléchargées à partir du site Web VRM
/// actuellement mis de côté "pour plus tard"
class Diagrams extends StatefulWidget {
  const Diagrams({super.key});

  @override
  State<Diagrams> createState() => _DiagramsState();
}

class _DiagramsState extends State<Diagrams> {

  String data = 'No data, sorry :(';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    setupGetData();
  }

  /// Utiliser la fonction GetData pour créer une instance et récupérer des données
  void setupGetData() async {
    GetData instance = GetData(signature: "381831", precision: "/stats");
    await instance.getData();
    setState(() {
      loading = false;
      data = instance.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : BasePage(
      appBar: appBar(),
      body: body(context),
    );
  }

  /// définir et créer body
  body(BuildContext context) {
    return ListView(
      children: <Widget>[
        TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/checklist');
          },
          label: Text(AppLocalizations.of(context)!.checkList),

          icon: const Icon(Icons.check),
        ),
        /// afficher les données téléchargées sous forme de texte
        Text(
          data,
        ),
      ],
    );
  }

  /// définir et créer appBar
  appBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.dataReceived),
      backgroundColor: Colors.blue[800],
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            AuthController.instance.logOut();
          },
          child: Text(AppLocalizations.of(context)!.logOut),
        ),
      ],
    );
  }
}
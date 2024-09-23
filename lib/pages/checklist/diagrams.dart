import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/checklist/loading.dart';
import 'package:flutter_application_1/pages/data_api/get_data.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Diagrams extends StatefulWidget {
  const Diagrams({super.key});

  @override
  State<Diagrams> createState() => _DiagramsState();
}

class _DiagramsState extends State<Diagrams> {

  String data = 'No data, sorry :(';
  bool loading = true;

  void setupGetData() async {
    GetData instance = GetData(signature: "381831", precision: "/stats");
    await instance.getData();
    setState(() {
      loading = false;
      data = instance.data;
    });
  }

  @override
  void initState() {
    super.initState();
    setupGetData();
  }


  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : BasePage(
      appBar: appBar(),
      body: body(context),
    );
  }

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
        Text(
          data,
        ),
      ],
    );
  }

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
            Navigator.pushReplacementNamed(context, '/wrapper');
          },
          child: Text(AppLocalizations.of(context)!.logOut),
        ),
      ],
    );
  }
}
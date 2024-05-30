import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/checklist/loading.dart';
import 'package:flutter_application_1/checklist/get_data_vrm_api/get_data.dart';
import 'package:flutter_application_1/auth_controller.dart';
import 'package:flutter_application_1/models/menu.dart';

class Diagrams extends StatefulWidget {
  const Diagrams({super.key});

  @override
  State<Diagrams> createState() => _DiagramsState();
}

class _DiagramsState extends State<Diagrams> {

  String data = 'No data, sorry :(';
  bool loading = true;
  final User? user = AuthController().auth.currentUser;
  final String username = AuthController().getUserName();
  final String role = AuthController().getRole();

  void setupGetData() async {
    GetData instance = GetData(signature: "219757", precision: "/stats");
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

  // final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    return loading ? const Loading() : Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text('Got data'),
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
            child: const Text('Logout'),
          ),
        ],
      ),
      drawer: MenuWidget(username: username),
      body: ListView(
        children: <Widget>[
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/checklist');
            },
            label: const Text('Go to check list'),

            icon: const Icon(Icons.check),
          ),
          Text(
            data,
          ),
        ],
      ),
    );
  }
}
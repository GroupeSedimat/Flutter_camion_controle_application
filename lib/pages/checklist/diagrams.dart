import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/checklist/loading.dart';
import 'package:flutter_application_1/pages/checklist/get_data_vrm_api/get_data.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/menu.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/user_service.dart';

class Diagrams extends StatefulWidget {
  const Diagrams({super.key});

  @override
  State<Diagrams> createState() => _DiagramsState();
}

class _DiagramsState extends State<Diagrams> {

  String data = 'No data, sorry :(';
  bool loading = true;

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
      drawer: FutureBuilder<MyUser>(
        future: UserService().getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final MyUser userData = snapshot.data!;
            return MenuWidget(username: userData.username, role: userData.role);
          } else {
            return const Center(child: Text("No data available"));
          }
        },
      ),
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
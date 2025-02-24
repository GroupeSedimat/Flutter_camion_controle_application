import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:provider/provider.dart';


class UserTile extends StatefulWidget {
  final MyUser user;
  final Map<String, String> userData;

  UserTile({required this.user, required this.userData});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  late NetworkService networkService;
  late DatabasePDFService databasePDFService;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initService();
  }

  Future<void> _initService() async {
    try {
      networkService = Provider.of<NetworkService>(context, listen: false);
      databasePDFService = DatabasePDFService();
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("❗User Tile build ${widget.user.username}");
    print("❗${widget.userData}");
    return ExpansionTile(
      backgroundColor: Colors.lightBlueAccent,
      collapsedBackgroundColor: Colors.lightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        widget.user.username,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.userData.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (BuildContext context, int index){
            final entry = widget.userData.entries.toList()[index];
            final fileName = entry.key;
            final url = entry.value;
            return PDFShowTemplate(fileName: fileName, url: url, user: widget.user,);
          },
        ),
      ],
    );
  }
}
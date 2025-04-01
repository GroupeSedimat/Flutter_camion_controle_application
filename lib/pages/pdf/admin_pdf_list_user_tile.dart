import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/pdf/pdf_show_template.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_application_1/services/pdf/database_pdf_service.dart';
import 'package:provider/provider.dart';

/// une classe qui affiche une liste PDF pour un utilisateur donné
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
      /// initialisation des services
      networkService = Provider.of<NetworkService>(context, listen: false);
      databasePDFService = DatabasePDFService();
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double listHeight = MediaQuery.of(context).size.height * 0.8;
    double minHeight = 200;
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
        SizedBox(
          height: listHeight < minHeight ? minHeight : listHeight,
          /// afficher une liste de fichiers PDF en utilisant la classe PDFShowTemplate
          /// (vous pouvez ajouter une pagination pour un plus grand nombre de fichiers)
          child: ListView.builder(
            itemCount: widget.userData.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (BuildContext context, int index) {
              final entry = widget.userData.entries.toList()[index];
              final fileName = entry.key;
              final url = entry.value;
              return PDFShowTemplate(fileName: fileName, url: url, user: widget.user);
            },
          ),
        ),
      ],
    );
  }
}
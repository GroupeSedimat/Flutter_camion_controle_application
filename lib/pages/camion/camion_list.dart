import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/add_camion_form.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CamionList extends StatefulWidget {
  const CamionList({super.key});

  @override
  State<CamionList> createState() => _CamionListState();
}

class _CamionListState extends State<CamionList> {
  final DatabaseCamionService databaseCamionService = DatabaseCamionService();
  Future<MyUser>? _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = getUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          MyUser user = snapshot.data!;
          return Scaffold(
              body: FutureBuilder(
                future: getCamionsData(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Camion> camionList = snapshot.data!;
                    return DefaultTabController(
                      initialIndex: 0,
                      length: camionList.length,
                      child: BasePage(
                        title: title(user),
                        body: _buildBody(camionList, user),
                      ),
                    );
                  }
                },
              ),
              floatingActionButton: Visibility(
                visible: user.role == 'superadmin',
                child: FloatingActionButton(
                  heroTag: "addCamionHero",
                  onPressed: () {
                    /// Todo  showCamionModal();
                  },
                  // backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.fire_truck,
                    color: Colors.white,
                  ),
                ),
              )
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<MyUser> getUser() async {
    UserService userService = UserService();
    return await userService.getCurrentUserData();
  }

  Future<List<Camion>> getCamionsData(MyUser user) async {
    if (user.role == 'superadmin') {
      return databaseCamionService.getAllCamions();
    } else if (user.role == 'admin') {
      List<Camion> camions = [];
      String companyId = user.company;
      camions = await databaseCamionService.getCompanyCamions(companyId);
      return camions;
    } else {
      List<Camion> camions = [];
      return camions;
    }
  }

  Widget _buildBody(List<Camion> camionList, MyUser user) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: camionList.length,
      itemBuilder: (_, index) {
        Widget leading;
        if (camionList.elementAt(index).camionType == "") {
          leading = Icon(Icons.car_crash, color: Colors.deepPurple, size: 60);
        } else {
          leading = Icon(Icons.fire_truck, color: Colors.deepPurple, size: 60);
          // leading = Image.network(
            // camionList.values.elementAt(index).logo,
            // height: 60,
          // );
        }
        return Padding(
          padding: EdgeInsets.all(8),
          child: ExpansionTile(
            leading: leading,
            title: Text(camionList.elementAt(index).name, style: TextStyle(fontSize: 24, color:Theme.of(context).primaryColor, ),),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == 'edit') {
                  // showCompanyModal(
                  //   company: camionList.values.elementAt(index),
                  //   companyID: camionList.keys.elementAt(index),
                  // );
                } else if (value == 'delete') {
                  // _showDeleteConfirmation(camionList.elementAt(index));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(AppLocalizations.of(context)!.edit),
                ),
                if(user.role == "superadmin")
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppLocalizations.of(context)!.delete),
                ),
              ],
            ),
            children: [
              Wrap(
                spacing: 15,
                children: [
                  if(camionList.elementAt(index).company != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.company}: ${camionList.elementAt(index).company}",
                      style: textStyle(),
                    ),
                  ),
                  if(camionList.elementAt(index).camionType != "")
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.camionType}: ${camionList.elementAt(index).camionType}",
                      style: textStyle(),
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      "${AppLocalizations.of(context)!.status}: ${camionList.elementAt(index).status}",
                      style: textStyle(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle textStyle(){
    return TextStyle(fontSize: 20);
  }

  String title(MyUser user) {
    if(user.role == "superadmin"){
      return AppLocalizations.of(context)!.camionsList;
    }else{
      return AppLocalizations.of(context)!.details;
    }
  }
  void showCamionModal({
    Camion? camion,
    String? camionID,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.fromLTRB(
              10, 50, 10, MediaQuery.of(context).viewInsets.bottom
          ),
          child: AddCamion(
            camion: camion,
            camionID: camionID,
            onCamionAdded: () {
              setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String camionID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () {
              databaseCamionService.deleteCamion(camionID);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: Colors.red)),
              // AppLocalizations.of(context)!
          ),
        ],
      ),
    );
  }
}

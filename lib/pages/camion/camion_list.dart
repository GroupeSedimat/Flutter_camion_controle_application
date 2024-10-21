import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/add_camion_form.dart';
import 'package:flutter_application_1/pages/camion/camion_type_list.dart';
import 'package:flutter_application_1/pages/equipment/equipment_list.dart';
import 'package:flutter_application_1/services/camion/database_camion_service.dart';
import 'package:flutter_application_1/services/camion/database_camion_type_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CamionList extends StatefulWidget {
  const CamionList({super.key});

  @override
  State<CamionList> createState() => _CamionListState();
}

class _CamionListState extends State<CamionList> {
  final DatabaseCamionService databaseCamionService = DatabaseCamionService();
  final DatabaseCamionTypeService databaseCamionTypeService = DatabaseCamionTypeService();
  Future<MyUser>? _futureUser;
  Future<Map<String, String>>? _futureCamionTypes;

  @override
  void initState() {
    super.initState();
    _futureUser = getUser();
    _futureCamionTypes = databaseCamionTypeService.getTypesIdAndName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyUser>(
      future: _futureUser,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        } else if (userSnapshot.hasData) {
          MyUser user = userSnapshot.data!;

          return FutureBuilder<Map<String, String>>(
            future: _futureCamionTypes,
            builder: (context, camionTypesSnapshot) {
              if (camionTypesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (camionTypesSnapshot.hasError) {
                return Center(child: Text('Error: ${camionTypesSnapshot.error}'));
              } else if (camionTypesSnapshot.hasData) {
                Map<String, String> camionTypesMap = camionTypesSnapshot.data!;

                return Scaffold(
                  body: FutureBuilder(
                    future: getCamionsData(user),
                    builder: (context, camionsSnapshot) {
                      if (camionsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (camionsSnapshot.hasError) {
                        return Center(child: Text('Error: ${camionsSnapshot.error}'));
                      } else {
                        Map<String, Camion> camionList = camionsSnapshot.data!;
                        return DefaultTabController(
                          initialIndex: 0,
                          length: camionList.length,
                          child: BasePage(
                            title: title(user),
                            body: _buildBody(camionList, user, camionTypesMap),
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
                        showCamionModal();
                      },
                      child: const Icon(
                        Icons.fire_truck,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
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

  Future<Map<String, Camion>> getCamionsData(MyUser user) async {
    if (user.role == 'superadmin') {
      return databaseCamionService.getAllCamions();
    } else if (user.role == 'admin') {
      Map<String, Camion> camions = HashMap();
      String companyId = user.company;
      camions = await databaseCamionService.getCompanyCamions(companyId);
      return camions;
    } else {
      Map<String, Camion> camions = HashMap();
      return camions;
    }
  }

  Widget _buildBody(Map<String, Camion> camionList, MyUser user, Map<String, String> camionTypesMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 30,
          children: [
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionsList),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CamionTypeList()),
                );
              },
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionTypesList),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EquipmentList()),
                );
              },
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.equipmentList),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
            itemCount: camionList.length,
            itemBuilder: (_, index) {
              String camionTypeId = camionList.values.elementAt(index).camionType;
              String camionTypeName = camionTypesMap[camionTypeId] ?? 'Unknown Type'; // Wyświetla nazwę typu lub 'Unknown Type', jeśli brak w mapie.

              Widget leading;
              if (camionTypeId.isEmpty) {
                leading = Icon(Icons.car_crash, color: Colors.deepPurple, size: 60);
              } else {
                leading = Icon(Icons.fire_truck, color: Colors.deepPurple, size: 60);
              }

              return Padding(
                padding: EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: leading,
                  title: Text(
                    camionList.values.elementAt(index).name,
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showCamionModal(
                          camion: camionList.values.elementAt(index),
                          camionID: camionList.keys.elementAt(index),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(camionList.keys.elementAt(index));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      if (user.role == "superadmin")
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
                        if (camionList.values.elementAt(index).company.isNotEmpty)
                          SizedBox(
                            child: Text(
                              "${AppLocalizations.of(context)!.company}: ${camionList.values.elementAt(index).company}",
                              style: textStyle(),
                            ),
                          ),
                        if (camionTypeId.isNotEmpty)
                          SizedBox(
                            child: Text(
                              "${AppLocalizations.of(context)!.camionType}: $camionTypeName",
                              style: textStyle(),
                            ),
                          ),
                        SizedBox(
                          child: Text(
                            "${AppLocalizations.of(context)!.status}: ${camionList.values.elementAt(index).status}",
                            style: textStyle(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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

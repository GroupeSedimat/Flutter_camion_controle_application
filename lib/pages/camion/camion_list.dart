import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  MyUser? _user;
  Map<String, String>? _camionTypes;
  Map<String, Camion> _camionList = HashMap();
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadData() async {
    await _loadUser();
    await _loadCamionTypes();
    _loadMoreCamions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore && _hasMoreData) {
      print("-------------------------scroll listener");
      _loadMoreCamions();
    }
  }

  Future<void> _loadUser() async {
    try {
      print("-------------------------load user");
      MyUser user = await getUser();
      setState(() {
        print("-------------------------setState load user");
        _user = user;
      });
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _loadCamionTypes() async {
    try {
      Map<String, String> types = await databaseCamionTypeService.getTypesIdAndName();
      setState(() {
        _camionTypes = types;
      });
    } catch (e) {
      print("Error loading camion types: $e");
    }
  }

  Future<void> _loadMoreCamions() async {
    if (!_hasMoreData || _user == null) return;
    _isLoadingMore = true;

    try {
      var paginatedData = await databaseCamionService.getCamionsPaginated(
        companyId: _user!.role == 'admin' ? _user!.company : null,
        lastDocument: _lastDocument,
        limit: 20,
      );

      Map<String, Camion> newCamionsSnapshot = paginatedData['camions'];
      DocumentSnapshot? lastDocumentFromQuery = paginatedData['lastDocument'];

      if (newCamionsSnapshot.isNotEmpty) {
        setState(() {
          _camionList.addAll(newCamionsSnapshot);
          _lastDocument = lastDocumentFromQuery;
          _hasMoreData = newCamionsSnapshot.length >= 20;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print("Error loading camions: $e");
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null || _camionTypes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: BasePage(
        title: title(_user!),
        body: _buildBody(_camionList, _user!, _camionTypes!),
      ),
      floatingActionButton: Visibility(
        visible: _isSuperAdmin(),
        child: FloatingActionButton(
          heroTag: "addCamionHero",
          onPressed: () {
            showCamionModal();
          },
          child: const Icon(Icons.fire_truck, color: Colors.white),
        ),
      ),
    );
  }

  bool _isSuperAdmin() {
    return _user?.role == 'superadmin';
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
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: _camionList.length,
            itemBuilder: (context, index) {
              if (_camionList.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noCamionsAvailable),
                );
              }

              String camionId = _camionList.keys.elementAt(index);
              Camion camion = _camionList[camionId]!;

              String camionTypeName = camionTypesMap[camion.camionType] ?? 'Unknown Type';

              Widget leading;
              if (camion.camionType.isEmpty) {
                leading = Icon(Icons.car_crash, color: Colors.deepPurple, size: 60);
              } else {
                leading = Icon(Icons.fire_truck, color: Colors.deepPurple, size: 60);
              }
              return Padding(
                padding: EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: leading,
                  title: Text(
                    camion.name, // Nazwa ciężarówki
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showCamionModal(
                          camion: camion, // Obiekt Camion
                          camionID: camionId, // ID ciężarówki
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(camionId); // Usuwanie ciężarówki po ID
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
                        if (camion.company.isNotEmpty)
                          SizedBox(
                            child: Text(
                              "${AppLocalizations.of(context)!.company}: ${camion.company}",
                              style: textStyle(),
                            ),
                          ),
                        if (camion.camionType.isNotEmpty)
                          SizedBox(
                            child: Text(
                              "${AppLocalizations.of(context)!.camionType}: $camionTypeName",
                              style: textStyle(),
                            ),
                          ),
                        SizedBox(
                          child: Text(
                            "${AppLocalizations.of(context)!.status}: ${camion.status}",
                            style: textStyle(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  TextStyle textStyle(){
    return TextStyle(fontSize: 20);
  }

  String title(MyUser user) {
    if (user.role == "superadmin") {
      return AppLocalizations.of(context)!.camionsList;
    } else {
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
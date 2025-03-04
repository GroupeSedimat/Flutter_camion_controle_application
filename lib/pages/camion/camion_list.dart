import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/add_camion_form.dart';
import 'package:flutter_application_1/pages/camion/camion_type_list.dart';
import 'package:flutter_application_1/pages/equipment/equipment_list.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class CamionList extends StatefulWidget {
  const CamionList({super.key});

  @override
  State<CamionList> createState() => _CamionListState();
}

class _CamionListState extends State<CamionList> {

  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;

  Map<String, String>? _camionTypes;
  Map<String, Camion> _camionList = HashMap();
  Map<String, String>? _companiesNames;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _selectedFilterType;
  String? _selectedFilterCompany;
  String? _selectedSortField;
  String? _searchQuery;
  bool _isSortDescending = false;

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _initDatabase();
    await _initService();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    }else{
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }{
      await _syncData();
    }
    await _loadDataFromDatabase();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initService() async {
    try {
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
      _scrollController.addListener(_scrollListener);
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _loadUserToConnection() async {
    print("welcome user to connection firebase ☢☢☢☢☢☢☢");
    Map<String, MyUser>? users = await getThisUser(db);
    print("users: $users");
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      print("user ☢☢☢☢☢☢☢ $user");
      String? userId = await userService.userID;
      print("userId ☢☢☢☢☢☢☢ $userId");
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    print("welcome page local ☢☢☢☢☢☢☢");
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      print("connected as  $users");
      MyUser user = users!.values.first;
      print("local user ☢☢☢☢☢☢☢ $user");
      String? userId = users.keys.first;
      print("local userId ☢☢☢☢☢☢☢ $userId");
      _userId = userId;
      _user = user;
    } catch (e) {
      print("Error loading user: $e");
    }
  }

  Future<void> _syncData() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db, _user.role).then((camionsMap) {
        if(camionsMap != null){
          for(var camion in camionsMap.entries){
            if(!camionsTypeIdList.contains(camion.value.camionType)){
              camionsTypeIdList.add(camion.value.camionType);
            }
          }
        }
      });
      print("💽 Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes",  user: _user, userId: _userId, dataPlus: camionsTypeIdList);
      List<String> camionListOfListId = [];
      Map<String, CamionType>? camionTypesMap = await getAllCamionTypes(db, _user.role);
      if(camionTypesMap != null){
        for(var camionType in camionTypesMap.entries){
          if(camionType.value.lol != null){
            for(var list in camionType.value.lol!){
              if(!camionListOfListId.contains(list)){
                camionListOfListId.add(list);
              }
            }
          }
        }
      }
      print("💽 Synchronizing PDFs...");
      await syncService.fullSyncTable("pdf", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadCamionTypes();
    await _loadCompaniesNames();
    await _loadLocalCamions();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore && _hasMoreData) {
      _loadLocalCamions();
    }
  }

  Future<void> _loadCamionTypes() async {
    try {
      Map<String, String>? types = await getAllCamionTypeNames(db, _user.role);
      if(types != null){
        _camionTypes = types;
      }
    } catch (e) {
      print("Error loading camion types: $e");
    }
  }

  Future<void> _loadCompaniesNames() async {
    try {
      Map<String, String>? companies = await getAllCompaniesNames(db, _user.role);
      if(companies != null){
        _companiesNames = companies;
      }
    } catch (e) {
      print("Error loading Companies Names: $e");
    }
  }

  Future<void> _loadLocalCamions() async {
    try {
      Map<String, Camion>? camionList = await getAllCamions(db, _user.role);
      if(camionList != null){
        _camionList = camionList;
      }
    }catch (e) {
      print("Error loading camions from local db: $e");
    }
  }

  Future<void> _loadMoreCamions() async {
    if (!_hasMoreData) return;
    _isLoadingMore = true;

    try {
      var paginatedData = await getSortedFilteredCamions(
        dbOrTxn: db,
        sortByField: _selectedSortField ?? 'name',
        isDescending: _isSortDescending,
        camionTypeId: _selectedFilterType,
        searchQuery: _searchQuery,
      );

      if (paginatedData != null) {
        setState(() {
          _camionList.addAll(paginatedData);
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
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.4),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: BasePage(
        title: title(),
        body: _buildBody(),
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
    return _user.role == 'superadmin';
  }

  void _showSubMenuSort(BuildContext context, Offset position) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        PopupMenuItem(
          value: 'sortName',
          child: Text(AppLocalizations.of(context)!.sortName),
        ),
        PopupMenuItem(
          value: 'sortType',
          child: Text(AppLocalizations.of(context)!.sortType),
        ),
        if(_isSuperAdmin())
        PopupMenuItem(
          value: 'sortEntreprise',
          child: Text(AppLocalizations.of(context)!.sortEntreprise),
        ),
        PopupMenuItem(
          value: 'sortDescending',
          child: Text(AppLocalizations.of(context)!.sortDescending),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleSubMenuSort(value);
      }
    });
  }

  void _handleSubMenuSort(String value) {
    setState(() {
      _selectedSortField = value == 'sortEntreprise' ? 'company' : (value == 'sortType' ? 'camionType' : (value == 'sortName' ? 'name' : _selectedSortField));
      _isSortDescending = value == 'sortDescending'? _isSortDescending = !_isSortDescending : _isSortDescending;
      _camionList.clear();
      _lastDocument = null;
      _hasMoreData = true;
    });
    _loadMoreCamions();
  }

  void _showSubMenuFilter(BuildContext context, Offset position) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        PopupMenuItem(
          value: 'filterType',
          child: Text(AppLocalizations.of(context)!.filterType),
        ),
        if(_isSuperAdmin())
        PopupMenuItem(
          value: 'filterEntreprise',
          child: Text(AppLocalizations.of(context)!.filterEntreprise),
        ),
      ],
    ).then((value) {
      if (value == 'filterType') {
        // Wyświetl dialog z listą typów camion
        _showFilterDialog(
          context,
          AppLocalizations.of(context)!.filterType,
          _camionTypes!,
              (selectedType) {
            setState(() {
              _selectedFilterType = selectedType;
              _camionList.clear();
              _lastDocument = null;
              _hasMoreData = true;
            });
            _loadMoreCamions();
          },
        );
      } else if (value == 'filterEntreprise') {
        _showFilterDialog(
          context,
          AppLocalizations.of(context)!.filterEntreprise,
          _companiesNames!,
              (selectedCompany) {
            setState(() {
              _selectedFilterCompany = selectedCompany;
              _camionList.clear();
              _lastDocument = null;
              _hasMoreData = true;
            });
            _loadMoreCamions();
          },
        );
      }
    });
  }


  void _showFilterDialog(BuildContext context, String title, Map<String, String> options, Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                String key = options.keys.elementAt(index);
                String value = options[key]!;
                return ListTile(
                  title: Text(value),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(key);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {

    List<String> sortedKeys = _camionList.keys.toList();
    sortedKeys.sort((a, b) {

      int comparison;
      if (_selectedSortField == 'name' || _selectedSortField == '' || _selectedSortField == null) {
        comparison = _isSortDescending
            ? _camionList[b]!.name.compareTo(_camionList[a]!.name)
            : _camionList[a]!.name.compareTo(_camionList[b]!.name);
      } else if (_selectedSortField == 'camionType') {
        // Sortujemy najpierw po camionType, a jeśli są równe, to alfabetycznie po name
        comparison = _isSortDescending
            ? _camionList[b]!.camionType.compareTo(_camionList[a]!.camionType)
            : _camionList[a]!.camionType.compareTo(_camionList[b]!.camionType);

        if (comparison == 0) {
          // Jeśli camionType jest taki sam, sortujemy po name
          comparison = _isSortDescending
              ? _camionList[b]!.name.compareTo(_camionList[a]!.name)
              : _camionList[a]!.name.compareTo(_camionList[b]!.name);
        }
      } else if (_selectedSortField == 'company') {
        // Sortujemy najpierw po company, a jeśli są równe, to alfabetycznie po name
        comparison = _isSortDescending
            ? _camionList[b]!.company.compareTo(_camionList[a]!.company)
            : _camionList[a]!.company.compareTo(_camionList[b]!.company);

        if (comparison == 0) {
          // Jeśli company jest taki sam, sortujemy po name
          comparison = comparison = _isSortDescending
              ? _camionList[b]!.name.compareTo(_camionList[a]!.name)
              : _camionList[a]!.name.compareTo(_camionList[b]!.name);
        }
      } else {
        comparison = 0;
      }

      return comparison;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 5,
          children: [
            if(_isSuperAdmin())
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(AppLocalizations.of(context)!.camionMenuTrucks),
            ),
            if(_isSuperAdmin())
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
              child: Text(AppLocalizations.of(context)!.camionMenuTypes),
            ),
            if(_isSuperAdmin())
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
              child: Text(AppLocalizations.of(context)!.camionMenuEquipment),
            ),
            PopupMenuButton(
              icon: Icon(Icons.search_rounded, color: Colors.red),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'search',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.search_rounded, color: Colors.red),
                          Text("Search name"),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Enter name",
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = _searchController.text.trim();
                                _camionList.clear();
                                _lastDocument = null;
                                _hasMoreData = true;
                              });
                              _loadMoreCamions();
                            },
                            child: Text("Search"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = null;
                                _camionList.clear();
                                _lastDocument = null;
                                _hasMoreData = true;
                                _selectedSortField = null;
                                _isSortDescending = false;
                                _selectedFilterCompany = null;
                                _selectedFilterType = null;
                              });
                              _loadMoreCamions();
                            },
                            child: Text("Reset Serch"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'sort',
                  onTap: () async {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      RenderBox renderBox = context.findRenderObject() as RenderBox;
                      Offset position = renderBox.localToGlobal(Offset.zero);
                      _showSubMenuSort(context, position);
                    });
                  },
                  child: Row(
                    children: const [
                      Text("Sort by"),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'filter',
                  onTap: () async {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      RenderBox renderBox = context.findRenderObject() as RenderBox;
                      Offset position = renderBox.localToGlobal(Offset.zero);
                      _showSubMenuFilter(context, position);
                    });
                  },
                  child: Row(
                    children: const [
                      Text("Filter by"),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ],
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

              String camionId = sortedKeys[index];
              Camion camion = _camionList[camionId]!;

              String camionTypeName = _camionTypes![camion.camionType] ?? 'Unknown Type';

              Widget leading;
              if (camion.camionType.isEmpty) {
                leading = Icon(Icons.car_crash, color: Colors.deepPurple, size: 60);
              } else {
                leading = Icon(Icons.fire_truck, color: Colors.deepPurple, size: 60);
              }
              String isDeleted;
              if(camion.deletedAt != null){
                isDeleted = " (deleted)";
              }else{
                isDeleted = "";
              }
              return Padding(
                padding: EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: leading,
                  title: Text(
                    "${index+1} ${camion.name} $isDeleted",
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showCamionModal(
                          camion: camion,
                          camionID: camionId,
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(camionId);
                      } else if (value == 'restore') {
                        await restoreCamion(db, camionId);
                        if (networkService.isOnline) {
                          await _syncCamions();
                        }
                        await _loadDataFromDatabase();
                        setState(() {});
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      if (_isSuperAdmin())
                        camion.deletedAt == null
                          ? PopupMenuItem(
                            value: 'delete',
                            child: Text(AppLocalizations.of(context)!.delete),
                        )
                          : PopupMenuItem(
                            value: 'restore',
                            child: Text(AppLocalizations.of(context)!.restore),
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
                              "${AppLocalizations.of(context)!.company}: ${_companiesNames?[camion.company] ?? 'Unknown Company'}",
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

  Future<void> _syncCamions() async {
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during global data synchronization: $e");
      rethrow;
    }
  }

  TextStyle textStyle(){
    return TextStyle(fontSize: 20);
  }

  String title() {
    if (_isSuperAdmin()) {
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
            onCamionAdded: () async {
              if (networkService.isOnline) {
                await _syncCamions();
              }
              await _loadDataFromDatabase();
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
            onPressed: () async {
              await softDeleteCamion(db, camionID);
              if (networkService.isOnline) {
                await _syncCamions();
              }
              await _loadDataFromDatabase();
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/admin/UserDetailsPage.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/companies_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class UserManagementPage extends StatefulWidget {
  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

//for superadmin

class _UserManagementPageState extends State<UserManagementPage> {
  late Database db;
  late MyUser _user;
  late String _userId;
  List<MyUser> _allUsers = [];
  Map<String, MyUser> _allUsersMap = {};
  bool _isLoading = true;
  Map<String, String> _companyNames = {};
  Map<String, List<MyUser>> _usersByCompany = {};

  late AuthController authController;
  late UserService userService;
  late NetworkService networkService;

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
    print("equipment list page local ☢☢☢☢☢☢☢");
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
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadUsersList();
    await _loadCompanyList();
    await _loadUsersByCompany();
  }

  Future<void> _loadCompanyList() async {
    Map<String, String>? companyList = await getAllCompaniesNames(db, _user.role);
    print("company list $companyList");
    if(companyList != null){
      _companyNames = companyList;
    }
  }

  Future<void> _loadUsersList() async {
    Map<String, MyUser>? usersMap = await getAllUsers(db, _user.role);
    print("Users map $usersMap");
    if(usersMap != null){
    List<MyUser>? usersList = usersMap.values.toList();
      _allUsersMap = usersMap;
      _allUsers = usersList;
    }
  }

  Future<void> _loadUsersByCompany() async {
    _usersByCompany = {};
    for (MyUser user in _allUsersMap.values) {
      print("company ${user.company} of user ${user.name}");
      var companyName = _companyNames[user.company] ?? 'Unknown';
      if (_usersByCompany[companyName] == null) {
        _usersByCompany[companyName] = [];
      }
      _usersByCompany[companyName]!.add(user);
    }
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

    return BasePage(
      title: AppLocalizations.of(context)!.manageUsers,
      body: ListView.builder(
      itemCount: _usersByCompany.length,
      itemBuilder: (context, index) {
        var company = _usersByCompany.keys.elementAt(index);
        var companyUsers = _usersByCompany[company]!;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            title: Text(
              company,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            children: companyUsers.map((user) {
              String userId = _allUsersMap.keys.firstWhere(
                      (element) => _allUsersMap[element] == user);
              String isDeleted = "";
              if(user.deletedAt != null){
                isDeleted = " (deleted)";
              }
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    child: Text(
                      user.username[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    "${user.username}$isDeleted",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(user.email),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (String value) {
                      switch (value) {
                        case 'view':
                          Get.to(() => UserDetailsPage());
                          break;
                        case 'edit':
                          Get.to(() => UserEditPage(userId: userId));
                          break;
                        case 'reset_password':
                          _resetPassword(user.email);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(userId);
                          break;
                        case 'restore':
                          _restoreUser(userId);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.details),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reset_password',
                          child: Row(
                            children: [
                              Icon(Icons.lock, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.passReset),
                            ],
                          ),
                        ),
                        user.deletedAt == null
                          ? PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.delete),
                              ],
                            ),
                          )
                          : PopupMenuItem(
                            value: 'restore',
                            child: Row(
                              children: [
                                Icon(Icons.restore, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.restore),
                              ],
                            ),
                          ),
                      ];
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    ),
    );
  }

  void _showDeleteConfirmation(String userId) {
    print("show_delete delete user with id: $userId");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () async {
                await softDeleteUser(db, userId);
                if (networkService.isOnline) {
                  await _syncData();
                }
                await _loadDataFromDatabase();
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _restoreUser(String userId) async {
    await restoreUser(db, userId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    setState(() {});
  }


  void _deleteUserConfirmed(String username) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userDoc.docs.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userDoc.docs[0].id).delete();
        Get.snackbar(
          "User deleted",
          "User has been deleted successfully.",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          "Error!",
          "User not found.",
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error while deleting",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _resetPassword(String email) async {
    try {
      await authController.resetPassword(email);
    } catch (e) {
      Get.snackbar(
        "Error while resetting",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
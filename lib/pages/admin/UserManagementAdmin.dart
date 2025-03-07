import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserDetailsPage.dart';
import 'package:flutter_application_1/pages/admin/UserEditPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class UserManagementAdmin extends StatefulWidget {

//for company admin
  @override
  State<UserManagementAdmin> createState() => _UserManagementAdminState();
}

class _UserManagementAdminState extends State<UserManagementAdmin> {
/// todo make offline
  late Database db;
  late MyUser _user;
  late String _userId;
  bool _isLoading = true;
  late Map<String, MyUser> _usersList;

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
    Map<String, MyUser>? users = await getThisUser(db);
    if(users != null ){
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      final syncService = Provider.of<SyncService>(context, listen: false);
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  Future<void> _loadUser() async {
    try {
      Map<String, MyUser>? users = await getThisUser(db);
      MyUser user = users!.values.first;
      String? userId = users.keys.first;
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
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  Future<void> _loadDataFromDatabase() async {
    await _loadUsersLists();
  }

  Future<void> _loadUsersLists() async {
    Map<String, MyUser>? usersList = await getAllUsers(db, _user.role);
    if(usersList != null){
      _usersList = usersList;
    }else {
      _usersList = {};
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
        itemCount: _usersList.length,
        itemBuilder: (context, index) {
          String userId = _usersList.keys.elementAt(index);
          MyUser user = _usersList[userId]!;
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              title: Text(user.username),
              subtitle: Text(user.email),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (String value) {
                  switch (value) {
                    case 'view':
                      Get.to(() => UserDetailsPage(userToShow: _usersList.entries.elementAt(index)));
                      break;
                    case 'edit':
                      Get.to(() => UserEditPage(userId: userId));
                      break;
                    case 'reset_password':
                      _resetPassword(user.email);
                      break;
                    case 'delete':
                      _confirmDeleteUser(userId);
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
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.details),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.edit),
                        ],
                      ),
                    ),
                    if (networkService.isOnline)
                    PopupMenuItem(
                      value: 'reset_password',
                      child: Row(
                        children: [
                          Icon(Icons.lock),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.passReset),
                        ],
                      ),
                    ),
                    if(user.deletedAt == null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.delete),
                        ],
                      ),
                    ),
                    if(user.deletedAt != null)
                    PopupMenuItem(
                      value: 'restore',
                      child: Row(
                        children: [
                          Icon(Icons.restore),
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
        },
      ),
    );
  }

  void _resetPassword(String email) async {
    try {
      await authController.resetPassword(email);
      Get.snackbar(
        "Password reset",
        "A reset email has been sent.",
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error while resetting",
        e.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _confirmDeleteUser(String userId) {
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
              onPressed: () {
                _deleteUser(userId);
              },
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) async {
    await softDeleteUser(db, userId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    Navigator.of(context).pop();
  }

  void _restoreUser(String userId) async {
    await restoreUser(db, userId);
    if (networkService.isOnline) {
      await _syncData();
    }
    await _loadDataFromDatabase();
    Navigator.of(context).pop();
  }
}

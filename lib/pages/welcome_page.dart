import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/database_local/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import 'map/map_page.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Database db;
  MyUser? _user;
  String? _userId;
  bool _isDataLoaded = false;
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
    await _initServices();
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    } else {
      await _loadUserToConnection();
    }
    await _loadUser();
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }
    {
      await _syncData();
    }
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<void> _initServices() async {
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
    if (users != null) {
      return;
    }
    try {
      MyUser user = await userService.getCurrentUserData();
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

  Future<void> _initDatabase() async {
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _syncData() async {
    if (_user == null || _userId == null) {
      print("Cannot sync data: user or userID is not loaded");
      return;
    } else {
      print("Can sync data: user: ${_user!.name} is loaded");
    }
    try {
      final syncService = Provider.of<SyncService>(context, listen: false);
      print("💽 Synchronizing Users...");
      await syncService.fullSyncTable("users", user: _user, userId: _userId);
      print("💽 Synchronizing users Camions...");
      await syncService.fullSyncTable("camions", user: _user, userId: _userId);
      List<String> camionsTypeIdList = [];
      await getAllCamions(db, _user!.role).then((camionsMap) {
        if (camionsMap != null) {
          for (var camion in camionsMap.entries) {
            if (!camionsTypeIdList.contains(camion.value.camionType)) {
              camionsTypeIdList.add(camion.value.camionType);
            }
          }
        }
      });
      print("Camion types Ids in list: $camionsTypeIdList");
      print("💽 Synchronizing CamionTypess...");
      await syncService.fullSyncTable("camionTypes",
          user: _user, userId: _userId, dataPlus: camionsTypeIdList);
      List<String> camionListOfListId = [];
      Map<String, CamionType>? camionTypesMap =
          await getAllCamionTypes(db, _user!.role);
      if (camionTypesMap != null) {
        for (var camionType in camionTypesMap.entries) {
          if (camionType.value.lol != null) {
            for (var list in camionType.value.lol!) {
              if (!camionListOfListId.contains(list)) {
                camionListOfListId.add(list);
              }
            }
          }
        }
      }
      print("💽 Synchronizing Companies...");
      await syncService.fullSyncTable("companies",
          user: _user, userId: _userId);
      print("💽 Synchronizing Equipments...");
      await syncService.fullSyncTable("equipments",
          user: _user, userId: _userId);
      print("Camion List of Lists Ids: $camionListOfListId");
      print("💽 Synchronizing LOL...");
      await syncService.fullSyncTable("listOfLists",
          user: _user, userId: _userId, dataPlus: camionListOfListId);
      print("💽 Synchronizing Blueprints...");
      await syncService.fullSyncTable("blueprints",
          user: _user, userId: _userId);
      print("💽 Synchronizing Validate Tasks...");
      await syncService.fullSyncTable("validateTasks",
          user: _user, userId: _userId);
      print("💽 Synchronizing PDFs...");
      await syncService.fullSyncTable("pdf", user: _user, userId: _userId);
      print("💽 Synchronization with SQLite completed.");
    } catch (e) {
      print("💽 Error during synchronization with SQLite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.homePage,
      body: _isDataLoaded ? _buildBody(context) : CircularProgressIndicator(),
    );
  }

  Widget _buildBody(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<MyUser>(
      future: UserService().getCurrentUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final MyUser userData = snapshot.data!;
          String welcomeMessage = userData.role == 'admin'
              ? AppLocalizations.of(context)!.adminHello(userData.username)
              : AppLocalizations.of(context)!.userHello(userData.username);

          return AnimationLimiter(
            child: ListView(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  _buildHeader(context, w, h * 0.3, welcomeMessage, isDarkMode),
                  SizedBox(height: 20),
                  _buildInfoCard(context),
                  SizedBox(height: 20),
                  _buildMapCard(context, '/map'),
                  SizedBox(height: 20),
                  _buildQuickActions(context),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text("No data available"));
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context, double width, double height,
      String welcomeMessage, bool isDarkMode) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[800]!, Colors.grey[900]!]
              : [Colors.blue[300]!, Colors.blue[600]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/mc.jpg",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          Center(
            child: Text(
              welcomeMessage,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                      color: Colors.black, offset: Offset(2, 2), blurRadius: 5),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.quickStatistics,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    context, AppLocalizations.of(context)!.activeTrucks, "15"),
                _buildStatItem(context,
                    AppLocalizations.of(context)!.numberOfInterventions, "42"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildMapCard(BuildContext context, String? route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Get.to(() => MapPage());
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.map,
                    size: 30, color: Theme.of(context).primaryColor),
                SizedBox(width: 16),
                Text(
                  AppLocalizations.of(context)!.viewMaps,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios,
                    color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.quickActions,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildActionChip(
                  context,
                  AppLocalizations.of(context)!.newIntervention,
                  Icons.local_shipping),
              _buildActionChip(context,
                  AppLocalizations.of(context)!.dailyReport, Icons.assessment),
              _buildActionChip(context,
                  AppLocalizations.of(context)!.maintenance, Icons.build),
              _buildActionChip(context, "New Dialogys", Icons.open_in_new,
                  onPressed: () => _launchDialogys(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon,
      {VoidCallback? onPressed}) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      label: Text(label),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onPressed: onPressed ?? () {},
    );
  }

  Future<void> _launchDialogys(BuildContext context) async {
    final Uri url = Uri.parse('https://newdialogys.renault.com/#!/connection');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir le lien')),
      );
    }
  }
}

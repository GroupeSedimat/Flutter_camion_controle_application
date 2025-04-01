import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/camion/camion_type.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_application_1/services/database_local/camion_types_table.dart';
import 'package:flutter_application_1/services/database_local/camions_table.dart';
import 'package:flutter_application_1/services/database_local/database_helper.dart';
import 'package:flutter_application_1/services/sync_service.dart';
import 'package:flutter_application_1/services/database_local/users_table.dart';
import 'package:flutter_application_1/services/network_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_1/widgets/base_page.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// page d'accueil user et admin
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
    /// vérifier si l'application est en ligne
    if (!networkService.isOnline) {
      print("Offline mode, no user update possible");
    } else {
      await _loadUserToConnection();
    }
    await _loadUser();
    /// vérifier si l'application est en ligne avant d'essayer de synchroniser
    if (!networkService.isOnline) {
      print("Offline mode, no sync possible");
    }
    {
      await _syncData();
    }
    if (mounted) {
      /// une fois l'initialisation terminée, modifiez la valeur de _isDataLoaded en true pour afficher le contenu de la page chargée
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  Future<void> _initDatabase() async {
    /// initialisation de la base de données locale
    db = await Provider.of<DatabaseHelper>(context, listen: false).database;
  }

  Future<void> _initServices() async {
    try {
      /// initialisation des services
      authController = AuthController();
      userService = UserService();
      networkService = Provider.of<NetworkService>(context, listen: false);
    } catch (e) {
      print("Error loading services: $e");
    }
  }

  Future<void> _loadUserToConnection() async {
    /// téléchargement des données utilisateur actuelles
    Map<String, MyUser>? users = await getThisUser(db);
    print("users: $users");
    if (users != null) {
      /// si l'utilisateur actuel est dans la base de données, quittez la fonction et continuez
      return;
    }
    try {
      /// si l'utilisateur actuel n'est pas encore dans la base de données, synchroniser les données utilisateur
      MyUser user = await userService.getCurrentUserData();
      String? userId = await userService.userID;
      final syncService = Provider.of<SyncService>(context, listen: false);
      await syncService.fullSyncTable("users", user: user, userId: userId);
    } catch (e) {
      print("💽 Error loading user: $e");
    }
  }

  /// enregistrer l'ID utilisateur actuel et les données dans des variables
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

  /// synchroniser chaque table séparément,
  Future<void> _syncData() async {
    if (_user == null || _userId == null) {
      print("Cannot sync data: user or userID is not loaded");
      return;
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

  /// Nous construisons le site basé sur BasePage.
  /// Si les données n'ont pas encore été chargées, nous afficherons le chargement "CircularProgressIndicator"
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
              "assets/images/truck.jpg",
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
                //Données statiques: pas de vraies données , données réelles à récupérer plutard avec la bd
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
            if (route != null) {
              Navigator.pushReplacementNamed(context, route);
            }
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      label: Text(label),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onPressed: () {},
    );
  }
}

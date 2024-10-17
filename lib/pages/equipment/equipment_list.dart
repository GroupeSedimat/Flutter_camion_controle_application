import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/equipment/equipment.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/equipment/add_equipment_form.dart';
import 'package:flutter_application_1/services/equipment/database_equipment_service.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EquipmentList extends StatefulWidget {
  const EquipmentList({super.key});

  @override
  State<EquipmentList> createState() => _EquipmentListState();
}

class _EquipmentListState extends State<EquipmentList> {
  final DatabaseEquipmentService databaseEquipmentService = DatabaseEquipmentService();
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
                future: databaseEquipmentService.getAllEquipments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    Map<String, Equipment> equipmentList = snapshot.data!;
                    return DefaultTabController(
                      initialIndex: 0,
                      length: equipmentList.length,
                      child: BasePage(
                        title: title(user),
                        body: _buildBody(equipmentList, user),
                      ),
                    );
                  }
                },
              ),
              floatingActionButton: Visibility(
                visible: user.role == 'superadmin',
                child: FloatingActionButton(
                  heroTag: "addEquipmentHero",
                  onPressed: () {
                    showEquipmentModal();
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

  Widget _buildBody(Map<String, Equipment> equipmentList, MyUser user) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: equipmentList.length,
      itemBuilder: (_, index) {
        Widget leading = const Icon(Icons.cell_tower_outlined, color: Colors.deepPurple, size: 60);

        Equipment equipment = equipmentList.values.elementAt(index);

        return Padding(
          padding: const EdgeInsets.all(8),
          child: ExpansionTile(
            leading: leading,
            title: Text(
              equipment.name,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == 'edit') {
                  showEquipmentModal(
                    equipment: equipment,
                    equipmentID: equipmentList.keys.elementAt(index),
                  );
                } else if (value == 'delete') {
                  _showDeleteConfirmation(equipmentList.keys.elementAt(index));
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
              // if(equipmentList.values.elementAt(index).name.isNotEmpty)
              // SizedBox(
              //   child: Text(
              //     "${AppLocalizations.of(context)!.equipmentName}: ${equipmentList.values.elementAt(index).name}",
              //     style: textStyle(),
              //   ),
              // ),
              if(equipmentList.values.elementAt(index).description.isNotEmpty)
              SizedBox(
                child: Text(
                  "${AppLocalizations.of(context)!.equipmentDescription}: ${equipmentList.values.elementAt(index).description}",
                  style: textStyle(),
                ),
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
  TextStyle textStyleBold(){
    return TextStyle(fontSize: 25, fontWeight: FontWeight.bold);
  }

  String title(MyUser user) {
    if(user.role == "superadmin"){
      return AppLocalizations.of(context)!.equipmentList;
    }else{
      return AppLocalizations.of(context)!.equipmentDescription;
    }
  }
  void showEquipmentModal({
    Equipment? equipment,
    String? equipmentID,
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
          child: AddEquipment(
            equipment: equipment,
            equipmentID: equipmentID,
            onEquipmentAdded: () {
              setState(() {});
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String equipmentID) {
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
              databaseEquipmentService.deleteEquipment(equipmentID);
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

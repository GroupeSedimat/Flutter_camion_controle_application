import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/checklist/add_list_form.dart';
import 'package:flutter_application_1/services/database_firestore/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/database_firestore/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListOfListsControlPage extends StatefulWidget {
  const ListOfListsControlPage({super.key});

  @override
  State<ListOfListsControlPage> createState() => _ListOfListsControlPageState();
}

class _ListOfListsControlPageState extends State<ListOfListsControlPage> {
  final DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([
          databaseListOfListsService.getAllLists(),
          userService.getUsersIdAndName()
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<ListOfLists> listOfLists = snapshot.data![0] as List<ListOfLists>;
            Map<String, String> userMap = snapshot.data![1] as Map<String, String>;
            return DefaultTabController(
              initialIndex: 0,
              length: listOfLists.length,
              child: BasePage(
                title: AppLocalizations.of(context)!.listOfLists,
                body: body(listOfLists, userMap),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddListForm(),
            ),
          );
          setState(() {});
        },
        tooltip: AppLocalizations.of(context)!.lOLAdd,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget body(List<ListOfLists> listOfLists, Map<String, String> userMap) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 50),
      itemCount: listOfLists.length,
      itemBuilder: (_, index) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Card(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            child: ExpansionTile(
              leading: const Icon(Icons.edit, color: Colors.deepPurple, size: 50),
              title: Text(
                "${listOfLists[index].listNr}. ${listOfLists[index].listName}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
              ),
              trailing: PopupMenuButton(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddListForm(
                          listItem: listOfLists[index],
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    bool confirmed = await _showConfirmationDialog(context);
                    if (confirmed) {
                      await databaseListOfListsService.deleteListItemByListNr(listOfLists[index].listNr);
                    }
                  }
                  setState(() {});
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(
                      AppLocalizations.of(context)!.edit,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }
  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDelete),
          content: Text(AppLocalizations.of(context)!.confirmDeleteText),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.no),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yes),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
}
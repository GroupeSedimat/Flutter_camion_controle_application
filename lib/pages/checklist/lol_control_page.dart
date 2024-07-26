import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/checklist/add_list_form.dart';
import 'package:flutter_application_1/services/check_list/database_list_of_lists_service.dart';
import 'package:flutter_application_1/services/user_service.dart';

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
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data found"));
          } else {
            List<ListOfLists> listOfLists = snapshot.data![0] as List<ListOfLists>;
            Map<String, String> userMap = snapshot.data![1] as Map<String, String>;
            return DefaultTabController(
              initialIndex: 0,
              length: listOfLists.length,
              child: BasePage(
                title: "List of Lists",
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
        child: Icon(Icons.add),
        tooltip: 'Add New List',
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
          child: ExpansionTile(
            leading: const Icon(Icons.edit, color: Colors.deepPurple, size: 50),
            title: Text("${listOfLists[index].listNr}. ${listOfLists[index].listName}"),
            subtitle: Text('Tap here for details'),
            trailing: PopupMenuButton(
              onSelected: (value) async {
                if (value == 'edit') {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddListForm(listItem: listOfLists[index]),
                    ),
                  );
                } else if (value == 'delete') {
                  await databaseListOfListsService.deleteListItemByListNr(listOfLists[index].listNr);
                }
                setState(() {});
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
            children: listOfLists[index].types.map<Widget>((type) {
              return ListTile(
                title: Text(userMap[type] ?? type),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
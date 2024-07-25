import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/checklist/list_of_lists.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/checklist/add_list_form.dart';
import 'package:flutter_application_1/services/check_list/database_list_of_lists_service.dart';

class ListOfListsControlPage extends StatefulWidget {
  const ListOfListsControlPage({super.key});

  @override
  State<ListOfListsControlPage> createState() => _ListOfListsControlPageState();
}

class _ListOfListsControlPageState extends State<ListOfListsControlPage> {

  final DatabaseListOfListsService databaseListOfListsService = DatabaseListOfListsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: databaseListOfListsService.getAllLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found"));
          } else {
            List<ListOfLists> listOfLists = snapshot.data!;
            return DefaultTabController(
              initialIndex: 0,
              length: listOfLists.length,
              child: BasePage(
                body: body(listOfLists),
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

  Widget body(List<ListOfLists> listOfLists) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: listOfLists.length,
      itemBuilder: (_, index) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: ExpansionTile(
            leading: Icon(Icons.edit, color: Colors.deepPurple, size: 50),
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
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
            children: listOfLists[index].types.map<Widget>((type) {
              return ListTile(
                title: Text(type),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
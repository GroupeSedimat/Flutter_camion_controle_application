import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/database_company_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserDetailsPage extends StatelessWidget {
  final MyUser user;
  final DatabaseCompanyService companyService = DatabaseCompanyService();

  UserDetailsPage({required this.user});

  Future<String> getCompanyName(String companyId) async {
    var company = await companyService.getCompanyByID(companyId);
    return company.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.details),
        actions: const [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(user.username),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.eMail,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(user.email),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userFirstName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(user.firstname),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userLastName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(user.name),
              SizedBox(height: 16),
              Text(
                'Role:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(user.role),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: user.apresFormation, onChanged: null),
                  Text(
                    'User after Formation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Apres Formation Doc:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if(user.apresFormationDoc != "")
              Image.network(user.apresFormationDoc, width: 600),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.company,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              FutureBuilder<String>(
                future: getCompanyName(user.company),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Company name not found');
                  } else {
                    return Text(snapshot.data!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

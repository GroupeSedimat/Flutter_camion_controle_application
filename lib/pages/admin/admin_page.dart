// ignore_for_file: use_super_parameters, prefer_const_constructors, unused_import
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/admin/UserApprovalPage.dart';
import 'package:flutter_application_1/pages/admin/UserManagementPage.dart';
import 'package:flutter_application_1/pages/base_page.dart';
import 'package:flutter_application_1/pages/camion/camion_list.dart';
import 'package:flutter_application_1/pages/camion/camion_type_list.dart';
import 'package:flutter_application_1/pages/checklist/checklist.dart';
import 'package:flutter_application_1/pages/checklist/lol_control_page.dart';
import 'package:flutter_application_1/pages/company/company_list.dart';
import 'package:flutter_application_1/pages/equipment/equipment_list.dart';
import 'package:flutter_application_1/pages/pdf/admin_pdf_list_view.dart';
import 'package:flutter_application_1/pages/user/user_role.dart';
import 'package:flutter_application_1/pages/welcome_page.dart';
import 'package:flutter_application_1/services/auth_controller.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:get/get.dart';

class AdminPage extends StatelessWidget {
  final UserRole userRole;

  const AdminPage({Key? key, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.superAdminPage,
      body: _buildModernDashboard(context),
    );
  }

  Widget _buildModernDashboard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
          childAspectRatio = 1.5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          childAspectRatio = 1.5;
        } else {
          crossAxisCount = 1;
          childAspectRatio = 1.8;
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.manageUsers,
                    Icons.people,
                    Colors.blue,
                    () => Get.to(() => UserManagementPage()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.checkList,
                    Icons.checklist,
                    Colors.green,
                    () => Get.to(() => const CheckList()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.listOfLists,
                    Icons.list_alt,
                    Colors.orange,
                    () => Get.to(() => const ListOfListsControlPage()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.company,
                    Icons.business,
                    Colors.purple,
                    () => Get.to(() => CompanyList()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.camionsList,
                    Icons.local_shipping,
                    Colors.red,
                    () => Get.to(() => CamionList()),
                  ),
                  _buildDashboardItem(
                    context,
                    AppLocalizations.of(context)!.pdfListAdmin,
                    Icons.picture_as_pdf,
                    Colors.teal,
                    () => Get.to(() => AdminPdfListView()),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

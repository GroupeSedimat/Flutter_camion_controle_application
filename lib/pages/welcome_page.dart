import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user/my_user.dart';
import 'package:flutter_application_1/services/user_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter_application_1/pages/base_page.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: AppLocalizations.of(context)!.homePage,
      body: _buildBody(context),
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

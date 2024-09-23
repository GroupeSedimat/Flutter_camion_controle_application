import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/data_api/get_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingData extends StatefulWidget {
  const LoadingData({super.key});

  @override
  State<LoadingData> createState() => _LoadingDataState();
}

class _LoadingDataState extends State<LoadingData> {

  String data = 'Loading';

  void setupGetData() async {
    GetData instance = GetData(signature: "219757", precision: "/stats");
    await instance.getData();
    Navigator.pushReplacementNamed(context, '/diagrams', arguments: {
      "data": instance.data,
    });
  }

  @override
  void initState() {
    super.initState();
    setupGetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  AppLocalizations.of(context)!.dataFetching,
                  style: TextStyle(
                      fontSize: 25
                  )
              ),
              SizedBox(height: 20,),
              SpinKitPouringHourGlass(
                color: Colors.white,
                size: 80.0,
              ),
            ]
        ),
      ),
    );
  }
}

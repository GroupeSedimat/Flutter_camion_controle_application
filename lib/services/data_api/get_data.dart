import 'dart:io';
import 'package:http/http.dart';
import 'dart:convert';

/// Une classe créée pour récupérer des données du portail VRM à l'aide de l'API
/// pour plus de détails https://vrm-api-docs.victronenergy.com/#/
class GetData {

  String apitoken = 'Token 58d409d30d5c72aae1e58e0dc6145ef7d7f1b827b9e93aef13f0ab1fe9b4ad31'; // token connection to VRM
  String url = 'https://vrmapi.victronenergy.com/v2/installations/'; // url main part
  String signature; // signature of installation. ex: '219757'
  String precision; // precision of what i want,start with '/'. Here example stats from installation: '/stats'
  String start; // where we want to start getting info (timestamp)
  String end; // where we want to end getting info. 0 = now (timestamp)
  String interval; // interval time of probing. 15mins, hours, 2hours, days, weeks, months,years
  String? type; // venus, live_feed, consumption, solar_yield, kwh, generator, generator-runtime, custom, forecast
  String prefix = '?';  // prefix to add things to $url
  String data = ''; // predefine data as placeholder

  GetData({
    required this.signature,
    required this.precision,
    this.start = '0',  // not required data (if not provided, default data will be apply - '1701352817')
    this.end = '0',
    this.interval = '',
    this.type = ''
  });

  Future<void> getData() async {
    try {
      String urlFinal = '$url$signature$precision';
      if (start != '0') {
        urlFinal = '$urlFinal${prefix}start=$start';
        prefix = '&';
      }
      if (end != '0') {
        urlFinal = '$urlFinal${prefix}end=$end';
        prefix = '&';
      }
      if (interval.isNotEmpty) {
        urlFinal = '$urlFinal${prefix}interval=$interval';
        prefix = '&';
      }
      if (type != '') {
        urlFinal = '$urlFinal${prefix}type=$type';
        prefix = '&';
      }

      Response response = await get(
          Uri.parse(urlFinal),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'x-authorization': apitoken
          }
      );
      Map dataFromServer = await jsonDecode(response.body);
      if(dataFromServer.keys.last == 'error_code'){
        data = dataFromServer.toString();
      }else{
        data = dataFromServer['records'].toString();
      }
    }
    catch (e){
      data = 'could not get data, error: $e';
    }
  }
}
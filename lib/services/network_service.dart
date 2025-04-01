import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Une classe chargée de vérifier si l'appareil dispose d'une connexion Internet
class NetworkService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  NetworkService() {
    _initialize();
  }

  void _initialize() async {
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    _updateStatus(results);

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    _isOnline = results.any((result) => result != ConnectivityResult.none);
    notifyListeners();
  }
}

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _connectivityStreamController =
      StreamController<ConnectivityResult>();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      for (var result in results) {
        _connectivityStreamController.add(result);
      }
    });
  }

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityStreamController.stream;

  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _connectivity.checkConnectivity();
  }

  void dispose() {
    _connectivityStreamController.close();
  }
}

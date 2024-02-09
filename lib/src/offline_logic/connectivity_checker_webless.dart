// Flutter imports:
import 'package:connectivity_plus/connectivity_plus.dart';
// Package imports:
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> isInternetAvailable(ConnectivityResult result) async {
  if (result == ConnectivityResult.none) {
    return false;
  } else {
    return await InternetConnectionChecker().hasConnection;
  }
}

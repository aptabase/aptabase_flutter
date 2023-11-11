// Flutter imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
// Package imports:
import 'package:internet_connection_checker/internet_connection_checker.dart';

Future<bool> get isConnected async {
  try {
    final result = await Connectivity().checkConnectivity();
    return await _isInternetAvailable(result);
  } on PlatformException catch (e) {
    developer.log(e.toString());
    return false;
  }
}

Future<bool> _isInternetAvailable(ConnectivityResult result) async {
  if (result == ConnectivityResult.none) {
    return false;
  } else {
    return await InternetConnectionChecker().hasConnection;
  }
}

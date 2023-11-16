// Flutter imports:
import 'package:aptabase_flutter/src/offline_logic/connectivity_checker_webless.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

Future<bool> get isConnected async {
  try {
    final result = await Connectivity().checkConnectivity();
    if (kIsWeb) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.bluetooth) {
        return true;
      } else {
        return false;
      }
    } else {
      return await isInternetAvailable(result);
    }
  } on PlatformException catch (e) {
    developer.log(e.toString());
    return false;
  }
}

library aptabase_flutter;
import 'package:aptabase_flutter/sys_info.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

class Aptabase {
  static const String _sdkVersion = "aptabase_flutter@0.0.1";

  static const Map<String, String> _regions = {
    'EU': "https://api-eu.aptabase.com",
    'US': "https://api-us.aptabase.com",
    'DEV': "http://localhost:5251",
  };

  static final http = HttpClient();
  static SystemInfo? _sysInfo;
  static String _appKey = "";
  static Uri? _apiUrl;

  Aptabase._();
  static final instance = Aptabase._();

  static Future init(String appKey) async {
    _appKey = appKey;

    var parts = _appKey.split("-");
    if (parts.length != 3) {
      developer.log('The Aptabase appKey "$_appKey" is invalid. Tracking will be disabled.');
      return;
    }

    _sysInfo = await SystemInfo.get();
    if (_sysInfo == null) {
      developer.log('This environment is not supported by Aptabase SDK. Tracking will be disabled.');
      return;
    }

    var region = parts[1];
    var baseUrl = _regions[region] ?? _regions["DEV"];
    _apiUrl = Uri.parse('$baseUrl/v0/event');
  }

  Future<void> trackEvent(String eventName, [Map<String, dynamic>? props]) async {
    if (_appKey.isEmpty || _apiUrl == null || _sysInfo == null) {
      return;
    }

    try {
      final request = await http.postUrl(_apiUrl!);
      request.headers.set("App-Key", _appKey);
      request.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

      final systemProps = {
          "osName": _sysInfo!.osName,
          "osVersion": _sysInfo!.osVersion,
          "locale": _sysInfo!.locale,
          "appVersion": _sysInfo!.appVersion,
          "appBuildNumber": _sysInfo!.buildNumber,
          "sdkVersion": _sdkVersion,
        };

      final body = json.encode({
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "sessionId": "123", // TODO ??
        "eventName": eventName,
        "systemProps": systemProps,
        "props": props,
      });

      request.write(body);
      final response = await request.close();
      if (kDebugMode && response.statusCode >= 300) {
        final body = await response.transform(utf8.decoder).join();
        developer.log('trackEvent failed with status code ${response.statusCode}: $body');
      }

    } on Exception catch (e, st) {
      if (kDebugMode) {
        developer.log('Exception $e: $st');
      }
    }
  }
}

library aptabase_flutter;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

class Aptabase {
  static final http = HttpClient();
  static _SystemInfo? _sysInfo;
  static String _appKey = "";
  static Uri? _apiUrl;

  Aptabase._();
  static final instance = Aptabase._();

  static Future init(String appKey) async {
    developer.log("Aptabase initialized with App Key: $appKey"); // TODO Remove this
    
    _appKey = appKey;

    var parts = _appKey.split("-");
    if (parts.length != 3) {
      developer.log('The Aptabase appKey "$_appKey" is invalid. Tracking will be disabled.');
      return;
    }

    _sysInfo = await _SystemInfo.get();
    if (_sysInfo == null) {
      developer.log('This environment is not supported by Aptabase SDK. Tracking will be disabled.');
      return;
    }

    var baseUrl = _getApiBaseUrl(parts[1]);
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
          "sdkVersion": "aptabase_flutter@0.0.0",
        };

      final body = json.encode({
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "sessionId": "123", // TODO ??
        "eventName": eventName,
        "systemProps": systemProps,
        "props": props,
      });

      request.write(body);
      await request.close();
    } on Exception catch (e, st) {
      if (!kReleaseMode) {
        developer.log('Exception $e: $st');
      }
    }
  }

  static String _getApiBaseUrl(String region) {
    switch (region) {
      case "US":
        return "https://api-us.aptabase.com";
      case "EU":
        return "https://api-eu.aptabase.com";
      default:
        return "http://172.20.10.2:5251";
    }
  }
}

class _SystemInfo {
   String osName; 
   String osVersion; 
   String appVersion; 
   String buildNumber; 
   String locale; 

  _SystemInfo._({
    required this.osName,
    required this.osVersion,
    required this.locale,
    required this.buildNumber,
    required this.appVersion
  });

  static Future<_SystemInfo?> get() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final osName = await _getOsName(deviceInfo);
    if (osName == null) {
      return null;
    }

    final osVersion = await _getOsVersion(deviceInfo);

    return _SystemInfo._(
      osName: osName,
      osVersion: osVersion,
      locale: Platform.localeName,
      buildNumber: packageInfo.buildNumber,
      appVersion: packageInfo.version,
    );
  }

  static Future<String?> _getOsName(DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "iOS";
    } else if (Platform.isMacOS) {
      return "macOS";
    } else  if (Platform.isWindows) {
      return "Windows";
    } else  if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      return info.name;
    }

    return null;
  }

  static Future<String> _getOsVersion(DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.version.release;
    }
    
    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.systemVersion ?? '';
    }
    
    if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      return info.osRelease;
    }
    
    if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      return '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}';
    }
    
    if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      return info.versionId ?? '';
    }

    return '';
  }
}
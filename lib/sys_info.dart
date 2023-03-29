library aptabase_flutter;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SystemInfo {
  String osName;
  String osVersion;
  String appVersion;
  String buildNumber;
  String locale;

  SystemInfo._(
      {required this.osName,
      required this.osVersion,
      required this.locale,
      required this.buildNumber,
      required this.appVersion});

  static Future<SystemInfo?> get() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final osName = await _getOsName(deviceInfo);
    if (osName == null) {
      return null;
    }

    final osVersion = await _getOsVersion(deviceInfo);

    return SystemInfo._(
        osName: osName,
        osVersion: osVersion,
        locale: Platform.localeName,
        buildNumber: packageInfo.buildNumber,
        appVersion: packageInfo.version);
  }

  static Future<String?> _getOsName(DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      final iPad = info.model?.toLowerCase().contains("ipad") ?? false;
      return iPad ? "iPadOS" : "iOS";
    } else if (Platform.isMacOS) {
      return "macOS";
    } else if (Platform.isWindows) {
      return "Windows";
    } else if (Platform.isLinux) {
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
      // TODO: wait for https://github.com/fluttercommunity/plus_plugins/pull/1649
      return '';
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

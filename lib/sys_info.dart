import 'package:universal_io/io.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// System information about the current device.
class SystemInfo {
  String osName;
  String osVersion;
  String appVersion;
  String buildNumber;
  String locale;

  SystemInfo._({
    required this.osName,
    required this.osVersion,
    required this.locale,
    required this.buildNumber,
    required this.appVersion,
  });

  static const String _kAndroidOsName = 'Android';
  static const String _kIPadOsName = 'iPadOS';
  static const String _kIPhoneOsName = 'iOS';
  static const String _kMacOsName = 'macOS';
  static const String _kWindowsOsName = 'Windows';
  static const String _kWebOsName = '';
  static const String _kWebOsVersion = '';

  static const String _kUnknownOsVersion = '';
  static const String _kIpadModelString = 'ipad';

  /// Returns the system information for the current device.
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
      appVersion: packageInfo.version,
    );
  }

  /// Returns the name of the operating system.
  static Future<String?> _getOsName(DeviceInfoPlugin deviceInfo) async {
    if (kIsWeb) {
      return _kWebOsName;
    } else if (Platform.isAndroid) {
      return _kAndroidOsName;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      final iPad = info.model.toLowerCase().contains(_kIpadModelString);
      return iPad ? _kIPadOsName : _kIPhoneOsName;
    } else if (Platform.isMacOS) {
      return _kMacOsName;
    } else if (Platform.isWindows) {
      return _kWindowsOsName;
    } else if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      return info.name;
    }

    return null;
  }

  /// Returns the version of the operating system.
  static Future<String> _getOsVersion(DeviceInfoPlugin deviceInfo) async {
    if (kIsWeb) {
      return _kWebOsVersion;
    }

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.version.release;
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.systemVersion;
    }

    if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      return '${info.majorVersion}.${info.minorVersion}.${info.patchVersion}';
    }

    if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      return '${info.majorVersion}.${info.minorVersion}.${info.buildNumber}';
    }

    if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;
      return info.versionId ?? _kUnknownOsVersion;
    }

    return _kUnknownOsVersion;
  }
}

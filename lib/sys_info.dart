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
  static Future<SystemInfo> get() async {
    final osInfo = await _getOsInfo();

    final packageInfo = await PackageInfo.fromPlatform();

    return SystemInfo._(
      osName: osInfo.name,
      osVersion: osInfo.version,
      locale: Platform.localeName,
      buildNumber: packageInfo.buildNumber,
      appVersion: packageInfo.version,
    );
  }

  /// Returns info (name and version) of the operating system.
  static Future<({String name, String version})> _getOsInfo() async {
    if (kIsWeb) {
      return (name: _kWebOsName, version: _kWebOsVersion);
    }

    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return (
        name: _kAndroidOsName,
        version: info.version.release,
      );
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      final isIPad = info.model.toLowerCase().contains(_kIpadModelString);
      final osName = isIPad ? _kIPadOsName : _kIPhoneOsName;

      return (name: osName, version: info.systemVersion);
    }

    if (Platform.isMacOS) {
      final info = await deviceInfo.macOsInfo;
      final version = '${info.majorVersion}.'
          '${info.minorVersion}.'
          '${info.patchVersion}';

      return (name: _kMacOsName, version: version);
    }

    if (Platform.isWindows) {
      final info = await deviceInfo.windowsInfo;
      final version = '${info.majorVersion}.'
          '${info.minorVersion}.'
          '${info.buildNumber}';

      return (name: _kWindowsOsName, version: version);
    }

    if (Platform.isLinux) {
      final info = await deviceInfo.linuxInfo;

      return (
        name: info.name,
        version: info.versionId ?? _kUnknownOsVersion,
      );
    }

    return (
      name: Platform.operatingSystem,
      version: Platform.operatingSystemVersion,
    );
  }
}

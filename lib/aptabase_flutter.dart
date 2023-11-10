/// The Flutter SDK for Aptabase, a privacy-first and simple analytics platform for apps.
library aptabase_flutter;

import 'dart:math';
import 'package:aptabase_flutter/connectivity_cheker.dart';
import 'package:aptabase_flutter/persist_event.dart';
import 'package:aptabase_flutter/shared_prefs.dart';
import 'package:aptabase_flutter/sys_info.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'dart:developer' as developer;

/// Additional options for initializing the Aptabase SDK.
class InitOptions {
  final String? host;

  const InitOptions({this.host});
}

/// Aptabase Client for Flutter
///
/// Initialize the client with `Aptabase.init(appKey)` and then use `Aptabase.instance.trackEvent(eventName, props)` to record events.
class Aptabase {
  static const String _sdkVersion = "aptabase_flutter@0.1.1";
  static const Duration _sessionTimeout = Duration(hours: 1);

  static const Map<String, String> _hosts = {
    'EU': "https://eu.aptabase.com",
    'US': "https://us.aptabase.com",
    'DEV': "http://localhost:3000",
    'SH': ""
  };

  static final http = newUniversalHttpClient();
  static final rnd = Random();
  static SystemInfo? _sysInfo;
  static String _appKey = "";
  static Uri? _apiUrl;
  static String _sessionId = newSessionId();
  static DateTime _lastTouchTs = DateTime.now().toUtc();
  static SharedPreferences? _prefs;

  Aptabase._();
  static final instance = Aptabase._();

  /// Initializes the Aptabase SDK with the given appKey.
  static Future init(String appKey, [InitOptions? opts]) async {
    _appKey = appKey;

    var parts = _appKey.split("-");
    if (parts.length != 3 || _hosts[parts[1]] == null) {
      developer.log(
          'The Aptabase App Key "$_appKey" is invalid. Tracking will be disabled.');
      return;
    }

    _sysInfo = await SystemInfo.get();
    if (_sysInfo == null) {
      developer.log(
          'This environment is not supported by Aptabase SDK. Tracking will be disabled.');
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    if (_prefs == null) {
      developer.log('persistence not available');
    }

    var region = parts[1];
    _apiUrl = _getApiUrl(region, opts);
  }

  /// Returns the session id for the current session.
  /// If the session is too old, a new session id is generated.
  String _evalSessionId() {
    final now = DateTime.now().toUtc();
    final elapsed = now.difference(_lastTouchTs);
    if (elapsed > _sessionTimeout) {
      _sessionId = newSessionId();
    }

    _lastTouchTs = now;
    return _sessionId;
  }

  /// Records an event with the given name and optional properties.
  Future<void> trackEvent(
    String eventName, [
    Map<String, dynamic>? props,
  ]) async {
    if (_appKey.isEmpty || _apiUrl == null || _sysInfo == null) {
      return;
    }
    if (await isConnected) {
      _sendEvent(eventName, props);
      final persistedEvents = getAllPersistedEvents(_prefs);
      if (persistedEvents.isNotEmpty) {
        for (final pEvent in persistedEvents) {
          _sendEvent(pEvent.eventName, pEvent.props);
          // delete pEvent (whether sent or not, keep it simple)
          final isDeleted = await deleteIt(_prefs, pEvent);
          if (isDeleted == false) {
            developer.log('could not delete event ${pEvent.eventName}');
          }
        }
      }
    } else {
      // prepare the event for persistence
      final event = Event(eventName, DateTime.now(), props);
      // persist the event
      final isPersisted = await persistIt(_prefs, event);
      if (isPersisted == false) {
        developer.log('could not save event ${event.eventName}');
      }
    }
  }

  void _sendEvent(
    String eventName, [
    Map<String, dynamic>? props,
  ]) async {
    try {
      final request = await http.postUrl(_apiUrl!);
      request.headers.set("App-Key", _appKey);
      request.headers.set(
          HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

      if (!kIsWeb) {
        request.headers.set(HttpHeaders.userAgentHeader, _sdkVersion);
      }

      final systemProps = {
        "isDebug": kDebugMode,
        "osName": _sysInfo!.osName,
        "osVersion": _sysInfo!.osVersion,
        "locale": _sysInfo!.locale,
        "appVersion": _sysInfo!.appVersion,
        "appBuildNumber": _sysInfo!.buildNumber,
        "sdkVersion": _sdkVersion,
      };

      final body = json.encode({
        "timestamp": DateTime.now().toUtc().toIso8601String(),
        "sessionId": _evalSessionId(),
        "eventName": eventName,
        "systemProps": systemProps,
        "props": props,
      });

      request.write(body);
      final response = await request.close();

      if (kDebugMode && response.statusCode >= 300) {
        final body = await response.transform(utf8.decoder).join();
        developer.log(
            'trackEvent failed with status code ${response.statusCode}: $body');
      }
    } on Exception catch (e, st) {
      if (kDebugMode) {
        developer.log('Exception $e: $st');
      }
    }
  }

  /// Returns the API URL for the given region.
  static Uri? _getApiUrl(String region, InitOptions? opts) {
    var baseUrl = _hosts[region]!;
    if (region == "SH") {
      if (opts?.host != null) {
        baseUrl = opts!.host!;
      } else {
        developer.log(
            'Host parameter must be defined when using Self-Hosted App Key. Tracking will be disabled.');
        return null;
      }
    }

    return Uri.parse('$baseUrl/api/v0/event');
  }

  /// Returns a new session id.
  static String newSessionId() {
    String epochInSeconds =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    String random = (rnd.nextInt(100000000)).toString().padLeft(8, '0');

    return epochInSeconds + random;
  }
}

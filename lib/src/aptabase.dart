/// The Flutter SDK for Aptabase, a privacy-first and simple analytics platform for apps.
// ignore_for_file: void_checks

import 'dart:math';
import 'package:aptabase_flutter/src/offline_logic/connectivity_checker.dart';
import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:aptabase_flutter/src/offline_logic/services/events_service_abstract.dart';
import 'package:aptabase_flutter/src/sys_info.dart';
import 'package:flutter/foundation.dart';
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
  ///
  /// Pass an EventsService if you want to persist unsent events.
  /// The example shows how to handle this with Sembast with EventsServiceSembast
  /// if you'd rather use another solution such as Hive or Moor submit a PR
  Future<void> trackEvent<E extends EventsServiceAbstract>(String eventName,
      [Map<String, dynamic>? props, E? service]) async {
    if (_appKey.isEmpty || _apiUrl == null || _sysInfo == null) {
      return;
    }
    if (await isConnected == false) {
      // prepare the event for persistence
      final event = EventOffline(eventName, props);
      // persist the event
      if (service != null) {
        final isPersisted = await service.addEvent.request(event);
        if (isPersisted == false) {
          developer.log('could not save event ${event.eventName}');
        }
      } else {
        developer.log('no persistence event service passed, ignoring event');
      }
    } else {
      var isDataPassingThrough = await _sendEvent(eventName, props);
      if (service != null) {
        final persistedEvents = await service.getAllEvents.request([]);
        if (persistedEvents.isNotEmpty) {
          for (var i = 0; i < persistedEvents.length; i++) {
            if (isDataPassingThrough) {
              final event = EventOffline.fromMap(persistedEvents[i].value);
              final eventKey = persistedEvents[i].key;
              isDataPassingThrough =
                  await _sendEvent(event.eventName, event.props);
              if (isDataPassingThrough) {
                isDataPassingThrough =
                    await service.deleteEvent.request(eventKey);
                if (isDataPassingThrough == false) {
                  developer.log('could not delete event ${event.eventName}');
                } else {
                  developer
                      .log('deleted event ${i + 1}/${persistedEvents.length}');
                }
              }
            }
          }
          await service.removeObsoleteLinesFromDb.request([]);
        }
      }
    }
  }

  Future<bool> _sendEvent(
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
        return false;
      }
      return true;
    } on Exception catch (e, st) {
      if (kDebugMode) {
        developer.log('Exception $e: $st');
      }
      return false;
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

/// The Flutter SDK for Aptabase, a privacy-first and simple analytics platform for apps.
// ignore_for_file: void_checks

import 'dart:math';
import 'package:aptabase_flutter/src/offline_logic/connectivity_checker.dart';
import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:aptabase_flutter/src/offline_logic/services_asbtract/events_service_abstract.dart';
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

enum SendingStatus {
  sendingFailedSaveAndResendLater,
  sendingFailedDismiss,
  sendingSuccress
}

class ResponseCodeParser {
  final int code;
  const ResponseCodeParser(this.code);
  SendingStatus get sendingStatus {
    if (code >= 300) {
      final c = code.toString();
      if (c.startsWith('4')) {
        return SendingStatus.sendingFailedDismiss;
      } else {
        return SendingStatus.sendingFailedSaveAndResendLater;
      }
    } else {
      return SendingStatus.sendingSuccress;
    }
  }
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

  static final _http = newUniversalHttpClient();
  static final _rnd = Random();
  static SystemInfo? _sysInfo;
  static String _appKey = "";
  static Uri? _apiUrl;
  static String _sessionId = newSessionId();
  static DateTime _lastTouchTs = DateTime.now().toUtc();
  // persistence
  static EventsServiceAbstract? _service;
  static int _batchEventsCount = 25;

  Aptabase._();
  static final instance = Aptabase._();

  /// Initializes the Aptabase SDK with the given appKey.
  static Future<void> initPersistence<E extends EventsServiceAbstract>(
      E? service,
      {int? batchEvents}) async {
    if (service != null) {
      _service = service;
    }
    if (batchEvents != null) {
      _batchEventsCount = batchEvents;
    }
  }

  /// Initializes the Aptabase SDK with the given appKey.

  static Future<void> init(String appKey, [InitOptions? opts]) async {
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
  Future<void> trackEvent<E>(String eventName,
      [Map<String, dynamic>? props]) async {
    if (_appKey.isEmpty || _apiUrl == null || _sysInfo == null) {
      return;
    }
    final event = EventOffline(eventName, props);
    if (await isConnected == false) {
      // prepare the event for persistence
      // persist the event
      if (_service != null) {
        final isPersisted = await _service!.addEvent.request(event);
        if (isPersisted == false) {
          developer.log('could not save event ${event.eventName}');
        }
      } else {
        developer.log('no persistence event service passed, ignoring event');
      }
    } else {
      final sendingStatus = await _sendEvent(eventName, props: props);
      // send all events in batches of 25 items max.
      if (_service != null) {
        if (sendingStatus == SendingStatus.sendingFailedSaveAndResendLater) {
          // it seems there was connexion & event data is fine but still sending event failed, so we save it
          final isPersisted = await _service!.addEvent.request(event);
          if (isPersisted == false) {
            developer.log('could not save event ${event.eventName}');
          }
        } else if (sendingStatus == SendingStatus.sendingSuccress) {
          // since the latest event was sent might as well send the old ones
          final batchesOfEventsAndKeys = await _getAndGroupEvents();
          if (batchesOfEventsAndKeys.isNotEmpty) {
            _batchSendAndThenDelete(batchesOfEventsAndKeys);
          }
        }
      }
    }
  }

  static int _howManyLoops(int eventsCount) =>
      (eventsCount / _batchEventsCount).ceil();

  Future<List<EventsOfflineAndKeys>> _getAndGroupEvents() async {
    final persistedEvents = await _service!.getAllEvents.request([]);
    if (persistedEvents.isEmpty) {
      return []; // cause you know...
    } else {
      final loops = _howManyLoops(persistedEvents.length);
      final eventsOfflineAndKeys = <EventsOfflineAndKeys>[];
      for (var i = 0; i < loops; i++) {
        final eventsKeys = <int>[];
        final eventsToBeSent = <EventOffline>[];

        for (var j = 0; j < _batchEventsCount; j++) {
          final k = j + i * _batchEventsCount;
          if (k < persistedEvents.length) {
            // only add if possible
            final event = EventOffline.fromMap(persistedEvents[k].value);
            final eventKey = persistedEvents[k].key;

            eventsToBeSent.add(event);
            eventsKeys.add(eventKey);
          }
        }
        final batch = EventsOfflineAndKeys(eventsToBeSent, eventsKeys);
        eventsOfflineAndKeys.add(batch);
      }
      return eventsOfflineAndKeys;
    }
  }

  Future<void> _batchSendAndThenDelete(
      List<EventsOfflineAndKeys> batches) async {
    final systemProps = {
      "isDebug": kDebugMode,
      "osName": _sysInfo!.osName,
      "osVersion": _sysInfo!.osVersion,
      "locale": _sysInfo!.locale,
      "appVersion": _sysInfo!.appVersion,
      "appBuildNumber": _sysInfo!.buildNumber,
      "sdkVersion": _sdkVersion,
    };
    for (final batch in batches) {
      final status = await _sendBatch(batch, systemProps);
      if (status == SendingStatus.sendingFailedDismiss ||
          status == SendingStatus.sendingSuccress) {
        _deleteOneByOne(batch.keys);
      }
    }
    await _service!.removeObsoleteLinesFromDb.request([]);
    return;
  }

  Future<void> _deleteOneByOne(List<int> keys) async {
    for (final eventKey in keys) {
      final isBatchDeleted = await _service!.deleteEvent.request(eventKey);
      if (isBatchDeleted == false) {
        developer.log('could not delete events in batch');
      }
    }
  }

  Future<SendingStatus> _sendBatch(
    EventsOfflineAndKeys batch,
    Map<String, Object> systemProps,
  ) async {
    try {
      final uriRaw = '${Uri.decodeFull('${_apiUrl!}')}s';
      final uri = Uri.parse(uriRaw);
      final request = await _http.postUrl(uri);
      request.headers.set("App-Key", _appKey);
      request.headers.set(
          HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");
      if (!kIsWeb) {
        request.headers.set(HttpHeaders.userAgentHeader, _sdkVersion);
      }
      final listOfEventsMap = batch.events
          .map((e) => {
                "timestamp": DateTime.now().toUtc().toIso8601String(),
                "sessionId": _evalSessionId(),
                "eventName": e.eventName,
                "systemProps": systemProps,
                "props": e.props,
              })
          .toList();
      final eventsJson = json.encode(listOfEventsMap);
      request.write(eventsJson);
      final response = await request.close();

      if (kDebugMode && response.statusCode >= 300) {
        final body = await response.transform(utf8.decoder).join();
        developer.log(
            'trackEvent failed with status code ${response.statusCode}: $body');
      }
      final parser = ResponseCodeParser(response.statusCode);
      return parser.sendingStatus;
    } on Exception catch (e, st) {
      if (kDebugMode) {
        developer.log('Exception $e: $st');
      }
      return SendingStatus.sendingFailedDismiss;
    }
  }

  Future<SendingStatus> _sendEvent(String eventName,
      {Map<String, dynamic>? props}) async {
    try {
      final request = await _http.postUrl(_apiUrl!);
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

      final parser = ResponseCodeParser(response.statusCode);
      return parser.sendingStatus;
    } on Exception catch (e, st) {
      if (kDebugMode) {
        developer.log('Exception $e: $st');
      }
      return SendingStatus.sendingFailedDismiss;
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
    String random = (_rnd.nextInt(100000000)).toString().padLeft(8, '0');

    return epochInSeconds + random;
  }
}

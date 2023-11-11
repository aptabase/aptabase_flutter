import 'dart:convert';

import 'package:flutter/foundation.dart';

class EventOffline {
  final String eventName;
  final Map<String, dynamic>? props;
  const EventOffline(this.eventName, [this.props]);

  static const dummy = EventOffline('test');
  static const dummy2 = EventOffline('test2', {"counter": 1});

  EventOffline copyWith({
    String? eventName,
    DateTime? dateCreation,
    Map<String, dynamic>? props,
  }) {
    return EventOffline(
      eventName ?? this.eventName,
      props ?? this.props,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'props': props,
    };
  }

  factory EventOffline.fromMap(Map<String, dynamic> map) {
    return EventOffline(
      map['eventName'] ?? '',
      map['props'] == null ? null : Map<String, dynamic>.from(map['props']),
    );
  }

  String toJson() => json.encode(toMap());

  factory EventOffline.fromJson(String source) =>
      EventOffline.fromMap(json.decode(source));

  @override
  String toString() => 'PersistEvent(eventName: $eventName, props: $props)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EventOffline &&
        other.eventName == eventName &&
        mapEquals(other.props, props);
  }

  @override
  int get hashCode => eventName.hashCode ^ props.hashCode;
}

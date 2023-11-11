import 'dart:convert';

import 'package:flutter/foundation.dart';

class Event {
  final String eventName;
  final Map<String, dynamic>? props;
  const Event(this.eventName, [this.props]);

  static const dummy = Event('test');
  static const dummy2 = Event('test2', {"counter": 1});

  Event copyWith({
    String? eventName,
    DateTime? dateCreation,
    Map<String, dynamic>? props,
  }) {
    return Event(
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

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      map['eventName'] ?? '',
      map['props'] == null ? null : Map<String, dynamic>.from(map['props']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Event.fromJson(String source) => Event.fromMap(json.decode(source));

  @override
  String toString() => 'PersistEvent(eventName: $eventName, props: $props)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event &&
        other.eventName == eventName &&
        mapEquals(other.props, props);
  }

  @override
  int get hashCode => eventName.hashCode ^ props.hashCode;
}

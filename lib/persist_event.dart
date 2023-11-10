import 'dart:convert';

import 'package:flutter/foundation.dart';

extension Handler on List<PersistEvent> {
  List<PersistEvent> get orderAsc =>
      this..sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
  List<PersistEvent> get orderDesc =>
      this..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
}

class PersistEvent {
  final String eventName;
  final DateTime dateCreation;
  final Map<String, dynamic>? props;
  const PersistEvent(this.eventName, this.dateCreation, [this.props]);

  String get key => dateCreation.toIso8601String();

  static final dummy = PersistEvent('test', DateTime(2000, 0, 0));
  static final dummy2 = PersistEvent('test2', DateTime(2002, 0, 0));

  PersistEvent copyWith({
    String? eventName,
    DateTime? dateCreation,
    Map<String, dynamic>? props,
  }) {
    return PersistEvent(
      eventName ?? this.eventName,
      dateCreation ?? this.dateCreation,
      props ?? this.props,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'dateCreation': dateCreation.millisecondsSinceEpoch,
      'props': props,
    };
  }

  factory PersistEvent.fromMap(Map<String, dynamic> map) {
    return PersistEvent(
      map['eventName'] ?? '',
      DateTime.fromMillisecondsSinceEpoch(map['dateCreation']),
      map['props'] == null ? null : Map<String, dynamic>.from(map['props']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PersistEvent.fromJson(String source) =>
      PersistEvent.fromMap(json.decode(source));

  @override
  String toString() =>
      'PersistEvent(eventName: $eventName, dateCreation: $dateCreation, props: $props)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PersistEvent &&
        other.eventName == eventName &&
        other.dateCreation == dateCreation &&
        mapEquals(other.props, props);
  }

  @override
  int get hashCode =>
      eventName.hashCode ^ dateCreation.hashCode ^ props.hashCode;
}

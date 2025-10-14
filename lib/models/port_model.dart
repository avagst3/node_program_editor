import 'package:flutter/material.dart';

/// The `Port` class represents a port with an ID, maximum number of links, label, and position in Dart,
/// with methods for copying and converting to/from JSON.
class Port {
  final int id;
  final int maxLinks;
  final String label;
  Offset position; 

  Port({
    required this.id,
    this.maxLinks = 1,
    this.label = "Data",
    this.position = Offset.zero,
  });

  Port copyWith({Offset? position}) {
    return Port(
      id: id,
      maxLinks: maxLinks,
      label: label,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'maxLinks': maxLinks,
        'label': label,
      };

  factory Port.fromJson(Map<String, dynamic> json) => Port(
        id: json['id'],
        maxLinks: json['maxLinks'],
        label: json['label'],
      );
}
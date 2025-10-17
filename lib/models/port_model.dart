/// The `SelectedPortInfo` class in Dart represents information about a selected port, including the
/// node index, port index, and whether it is an output port.
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

  /// The `copyWith` function in Dart creates a new `Port` object with updated properties.
  /// 
  /// Args:
  ///   position (Offset): The `position` parameter in the `copyWith` method is an optional parameter of
  /// type `Offset`. It is used to specify the new position for the `Port` object being copied. If a new
  /// position is provided, it will be used in the copied `Port` object; otherwise, the
  /// 
  /// Returns:
  ///   A new instance of the `Port` class is being returned with the specified properties copied from
  /// the current instance, and the `position` property updated with the provided value or the current
  /// value if no new value is provided.
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

import 'package:flutter/material.dart';

class EntryTypesData {
  final String name;
  Color _color;

  Color get color => _color;

  EntryTypesData(this.name, this._color);

  void updateColor(Color newColor) {
    _color = newColor;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': (((_color.a * 255).round() << 24) |
                ((_color.r * 255).round() << 16) |
                ((_color.g * 255).round() << 8) |
                ((_color.b * 255).round()))
            .toRadixString(16),
      };

  EntryTypesData.fromJson(
    Map<String, dynamic> json,
  )   : name = json['name'],
        _color =Color(int.parse(json['color'], radix: 16));
}

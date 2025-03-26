import 'package:flutter/material.dart';

class EntryTypesData {
  final String name;
  Color _color;

  Color get color => _color;

  EntryTypesData(this.name, this._color);

  void updateColor(Color newColor) {
    _color = newColor;
  }
}

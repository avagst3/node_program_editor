import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/entry_types_data.dart';
import '../policy/builder_set_policy.dart';

class BuilderStyle extends ChangeNotifier {
  final List<EntryTypesData> _entriesColors = [];
  final BuilderSetPolicy policy;

  BuilderStyle({required this.policy});

  List<EntryTypesData> get entriesColors => _entriesColors;

  void addEntryTypeData(EntryTypesData data) {
    _entriesColors.add(data);
    notifyListeners();
  }

  void updateEntryColor(EntryTypesData data, Color color) {
    _entriesColors[_entriesColors.indexOf(data)].updateColor(color);
    policy.updateAllComponentStyle();
    notifyListeners();
  }

  void initData(List<String> data) {
    for (var entry in data) {
      _entriesColors.add(
        EntryTypesData(
          entry,
          Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
              .withOpacity(1.0),
        ),
      );
    }
  }

  List<Map<String, dynamic>> toJson() {
    return _entriesColors.map((entries) {
      return entries.toJson();
    }).toList();
  }

  void fromJson(List<dynamic> colorsData) {
    colorsData.forEach((colorData) {
      var tempEnt = EntryTypesData.fromJson(colorData);
      if (_entriesColors.any((entry) => entry.name == colorData["name"])) {
      } else {
        _entriesColors.add(tempEnt);
      }
    });
  }
}

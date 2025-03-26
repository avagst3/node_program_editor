import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/entry_types_data.dart';
import '../policy/builder_set_policy.dart';

class BuilderStyle extends ChangeNotifier {
  final List<EntryTypesData> _entriesColors = [];
  final BuilderSetPolicy policy;

  BuilderStyle({required this.policy});

  Color _gridBackgroundColor = Color(0xFFFFFFFF);
  Color _gridColor = Color(0xFFFFFFFF);

  List<EntryTypesData> get entriesColors => _entriesColors;
  Color get gridBackgroundColor => _gridBackgroundColor;
  Color get gridColor => _gridColor;

  void setGridBackgroundColor(Color newColor) {
    _gridBackgroundColor = newColor;

    notifyListeners();
  }

  void addEntryTypeData(EntryTypesData data) {
    _entriesColors.add(data);
    notifyListeners();
  }

  void updateEntryColor(EntryTypesData data, Color color) {
    _entriesColors[_entriesColors.indexOf(data)].updateColor(color);
    policy.updateAllComponentStyle();
    notifyListeners();
  }

  void updateGridColor(Color newColor) {
    _gridColor = newColor;
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
}

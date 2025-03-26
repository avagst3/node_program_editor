import 'package:flutter/material.dart';

class ProgramProvider extends ChangeNotifier {
  Map<String, dynamic>? _program;

   Map<String, dynamic>? get program => _program;

  void setPrograme(Map<String, dynamic> program) {
    _program = program;
    notifyListeners();
  }
}

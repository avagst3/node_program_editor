import 'package:flutter/material.dart';

class ProgramDataProvider extends ChangeNotifier {
  String? programName;
  String? authorName;
  ProgramDataProvider({this.authorName, this.programName}) {
    print(this.programName);
  }
}

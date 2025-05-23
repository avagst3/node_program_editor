import 'package:flutter/material.dart';

import '../models/diagram_text.dart';

class TextProvider extends ChangeNotifier {
  DiagramText _text;
  DiagramText get text => _text;
  TextProvider(this._text);
}

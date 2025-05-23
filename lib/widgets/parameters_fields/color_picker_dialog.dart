import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../providers/text_provider.dart';

Future<Color> showPickColorDialog(
    BuildContext context, Color oldColor, TextProvider provider) async {
  Color currentColor = oldColor;

  await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(provider.text.colorPickerTitle),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => currentColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(provider.text.colorPickerClose),
              onPressed: () {
                currentColor = oldColor;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(provider.text.colorPickerSet),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });

  return currentColor;
}

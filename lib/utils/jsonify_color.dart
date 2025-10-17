import 'package:flutter/material.dart';

Color colorFromJson(Map<String, dynamic> color) {
  return Color.fromARGB(color["a"], color["r"], color["g"], color["b"] as int);
}

Map<String, dynamic> colorToJson(Color color) {
  return {
    "a": (color.a * 255).toInt(),
    "r": (color.r * 255).toInt(),
    "g": (color.g * 255).toInt(),
    "b": (color.b * 255).toInt()
  };
}

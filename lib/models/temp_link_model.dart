import 'package:flutter/material.dart';

/// The classes `TempLink` and `SelectedPortInfo` are used to store information about temporary links
/// and selected ports in a Dart application.
class TempLink {
  final int nodeIndex;
  final int portIndex;
  final bool isOutput;
  Offset currentDragPosition;

  TempLink({
    required this.nodeIndex,
    required this.portIndex,
    required this.isOutput,
    required this.currentDragPosition,
  });
}


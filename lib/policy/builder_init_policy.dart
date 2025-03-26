import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

mixin BuilderInitPolicy implements InitPolicy {
  @override
  initializeDiagramEditor() {
    canvasWriter.state.setCanvasColor(const Color(0xFFE0E0E0));
  }
}

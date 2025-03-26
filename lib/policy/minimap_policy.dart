import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import 'builder_component_design_policy.dart';

class MiniMapPolicySet extends PolicySet
    with MiniMapInitPolicy, CanvasControlPolicy, BuilderComponentDesignPolicy {}

mixin MiniMapInitPolicy implements InitPolicy {
  @override
  initializeDiagramEditor() {
    canvasWriter.state.setMinScale(0.025);
    canvasWriter.state.setMaxScale(0.25);
    canvasWriter.state.setScale(0.1);
    canvasWriter.state.setCanvasColor(const Color(0xFFE0E0E0).withOpacity(0.9));
    canvasWriter.state.setPosition(const Offset(80, 60));
  }
}

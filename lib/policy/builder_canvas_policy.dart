import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import 'base_policy.dart';

mixin BuilderCanvasPolicy implements CanvasPolicy, BasePolicy {
  @override
  onCanvasTapUp(TapUpDetails details) {
    canvasWriter.model.hideAllLinkJoints();

    if (selectedPortId == null) {
      hideAllHighLights();
    }
    deselectAllPorts();
  }
}

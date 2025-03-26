import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import '../component/port.dart';
import '../component/rect_component.dart';

mixin BuilderComponentDesignPolicy implements ComponentDesignPolicy {
  @override
  Widget showComponentBody(ComponentData componentData) {
    if (componentData.type == "port") {
      return PortComponent(componentData: componentData);
    } else {
      return RectComponent(componentData: componentData);
    }
  }
}

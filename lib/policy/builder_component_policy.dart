import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import 'base_policy.dart';

mixin BuilderComponentPolicy implements BasePolicy, ComponentPolicy {
  late Offset lastFocalPoint;

  @override
  onComponentTap(String componentId) {
    canvasWriter.model.hideAllLinkJoints();

    var component = canvasReader.model.getComponent(componentId);

    if (component.type == 'port') {
      
      bool connected =
          connectComponents(selectedPortId, componentId, component.data.color);
      deselectAllPorts();
      if (!connected) {
        selectPort(componentId);
      }
      if (component.parentId != null) {
        hideComponentHighlight(selectedComponentId);
        highlightComponent(component.parentId!);
      }
    } else {
      hideComponentHighlight(selectedComponentId);
      highlightComponent(componentId);
      var cpt = canvasReader.model.getComponent(componentId);
      cpt.childrenIds.forEach((element) {
        var prt = canvasReader.model.getComponent(element);
        var con = prt.connections;
        con.forEach(
          (element) {
            var name = element.otherComponentId;
            var oprt = canvasReader.model.getComponent(name);
            var par = canvasReader.model.getComponent(oprt.parentId!);
            var parname = canvasReader.model.getComponent(par.id);
          },
        );
      });
    }
  }

  @override
  onComponentScaleStart(componentId, details) {
    lastFocalPoint = details.localFocalPoint;
  }

  @override
  onComponentScaleUpdate(componentId, details) {
    Offset positionDelta = details.localFocalPoint - lastFocalPoint;

    var component = canvasReader.model.getComponent(componentId);

    if (component.type != 'port') {
      canvasWriter.model.moveComponentWithChildren(componentId, positionDelta);
    } else if (component.type == 'port' && component.parentId != null) {
      canvasWriter.model
          .moveComponentWithChildren(component.parentId!, positionDelta);
    }

    lastFocalPoint = details.localFocalPoint;
  }

  
}

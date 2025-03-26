import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc/show_component_settings/show_component_settings_cubit.dart';
import '../component/port.dart';
import '../models/builder_component_data.dart';
import '../providers/builder_style.dart';
import 'base_policy.dart';

mixin BuilderComponentWidgetPolicy
    implements ComponentDesignPolicy, BasePolicy {
  @override
  Widget showCustomWidgetWithComponentDataOver(
      BuildContext context, ComponentData componentData) {
    if (componentData.type != 'port') {
      if (componentData.data.isHighlightVisible) {
        context.read<ShowComponentSettingsCubit>().showSettings(componentData);
      } else {
        context.read<ShowComponentSettingsCubit>().hideSettings();
      }
      return Visibility(
        visible: componentData.data.isHighlightVisible,
        child: Stack(
          children: [
            componentTopOptions(componentData, context),
            highlight(componentData, Colors.blueGrey.shade400),
            resizeCorner(componentData),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget componentTopOptions(
      ComponentData componentData, BuildContext context) {
    Offset componentPosition =
        canvasReader.state.toCanvasCoordinates(componentData.position);
    return Positioned(
      left: componentPosition.dx - 24,
      top: componentPosition.dy - 50,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              deleteComponentWithPorts(componentData);
              context.read<ShowComponentSettingsCubit>().hideSettings();
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              _copyComponentDataWithPorts(componentData, context);
            },
            icon: Icon(
              Icons.copy,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteComponentWithPorts(ComponentData componentData) {
    List<String> portIds = [];
    canvasReader.model.getAllComponents().forEach((id, comp) {
      if (comp.parentId == componentData.id) {
        portIds.add(comp.id);
      }
    });
    for (var portId in portIds) {
      canvasWriter.model.removeComponent(portId);
    }
    canvasWriter.model.removeComponent(componentData.id);
    componentList.remove(componentData.id);
  }

  _copyComponentDataWithPorts(ComponentData data, context) {
    var componentData = _addPortOnComponent(data, context);
    canvasWriter.model.addComponent(componentData);
    int zOrder = canvasWriter.model.moveComponentToTheFront(componentData.id);
    componentData.data.portData.forEach((PortData port) {
      var newPort = ComponentData(
        size: port.size,
        type: 'port',
        data: port,
        position: componentData.position +
            componentData.getPointOnComponent(port.alignmentOnComponent) -
            port.size.center(Offset.zero),
      );
      canvasWriter.model.addComponent(newPort);
      canvasWriter.model.setComponentParent(newPort.id, componentData.id);
      newPort.zOrder = zOrder - 1;
    });
    hideComponentHighlight(data.id);
    componentList.add(componentData.id);
  }

  ComponentData _addPortOnComponent(ComponentData data, BuildContext context) {
    var portComponent = ComponentData(
      size: const Size(300, 180),
      position: data.position + Offset(30, 30),
      type: data.type,
      data: BuilderComponentData.copy(data.data),
    );

    portComponent.data.inputData?.forEach((input) {
      try {
        portComponent.data.portData.add(_getCopyPortData(
            Alignment.centerLeft, true, input, portComponent.id, context));
      } catch (e) {}
    });
    portComponent.data.outputData?.forEach((output) {
      portComponent.data.portData.add(_getCopyPortData(
          Alignment.centerRight, false, output, portComponent.id, context));
    });

    return portComponent;
  }

  PortData _getCopyPortData(Alignment alignment, bool isInput,
      Map<String, dynamic> data, String id, BuildContext context) {
    var portData = PortData(
      id: id,
      type: data["type"],
      isInput: isInput,
      size: const Size(20, 20),
      alignmentOnComponent: alignment,
      isMandatory: data["mandatory"] ? true : data["mandatory"],
      builderStyle: Provider.of<BuilderStyle>(context, listen: false),
      name: data["name"],
    );
    portData.setPortState(arePortsVisible ? PortState.shown : PortState.hidden);
    return portData;
  }

  Widget highlight(ComponentData componentData, Color color) {
    List<ComponentData> childPorts = [];
    canvasReader.model.getAllComponents().forEach((id, comp) {
      if (comp.parentId == componentData.id) {
        childPorts.add(comp);
      }
    });

    Rect combinedRect = Rect.fromPoints(
      componentData.position,
      componentData.position + componentData.size.bottomRight(Offset.zero),
    );
    for (var port in childPorts) {
      Rect portRect = Rect.fromPoints(
          port.position, port.position + port.size.bottomRight(Offset.zero));
      combinedRect = combinedRect.expandToInclude(portRect);
    }

    // Ajuster la position et la taille du contour
    Offset highlightPosition = combinedRect.topLeft - const Offset(2, 2);
    double width = combinedRect.width + 4;
    double height = combinedRect.height + 4;

    return Positioned(
      left: canvasReader.state.toCanvasCoordinates(highlightPosition).dx,
      top: canvasReader.state.toCanvasCoordinates(highlightPosition).dy,
      child: CustomPaint(
        painter: ComponentHighlightPainter(
          width: width * canvasReader.state.scale,
          height: height * canvasReader.state.scale,
          color: color,
        ),
      ),
    );
  }

  resizeCorner(ComponentData componentData) {
    // Calcul du rectangle englobant composant + ports
    Rect combinedRect = Rect.fromPoints(
      componentData.position,
      componentData.position + componentData.size.bottomRight(Offset.zero),
    );

    canvasReader.model.getAllComponents().forEach((id, comp) {
      if (comp.parentId == componentData.id) {
        Rect portRect = Rect.fromPoints(
            comp.position, comp.position + comp.size.bottomRight(Offset.zero));
        combinedRect = combinedRect.expandToInclude(portRect);
      }
    });

    Offset combinedBottomRightCanvas =
        canvasReader.state.toCanvasCoordinates(combinedRect.bottomRight);

    return Positioned(
      left: combinedBottomRightCanvas.dx - 12,
      top: combinedBottomRightCanvas.dy - 12,
      child: GestureDetector(
        onPanUpdate: (details) {
          canvasWriter.model.resizeComponent(
              componentData.id, details.delta / canvasReader.state.scale);
          canvasWriter.model.updateComponentLinks(componentData.id);

          // Mise à jour des ports enfants
          final component = canvasReader.model.getComponent(componentData.id);
          canvasReader.model.getAllComponents().forEach((id, comp) {
            if (comp.parentId == component.id) {
              final portData = comp.data as PortData;
              final newPosition = component.position +
                  component.getPointOnComponent(portData.alignmentOnComponent) -
                  comp.size.center(Offset.zero);
              final delta = newPosition - comp.position;
              canvasWriter.model.moveComponent(id, delta);
            }
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeDownRight,
          child: Container(
            width: 24,
            height: 24,
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updatePortPositions(ComponentData componentData) {
    for (var port in componentData.data.portData) {
      var newPortPosition = componentData.position +
          componentData.getPointOnComponent(port.alignmentOnComponent) -
          port.size.center(Offset.zero);
      var portComponent = canvasReader.model.getComponent(port.id);
      canvasWriter.model.moveComponent(portComponent.id, newPortPosition);
    }
  }
}

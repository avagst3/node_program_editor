import 'dart:math';

import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../component/port.dart';
import '../models/builder_component_data.dart';
import '../models/result.dart';
import '../providers/builder_style.dart';

mixin BasePolicy implements PolicySet {
  String? selectedComponentId;
  String serializedDiagram = '{"components": [], "links": []}';
  List<String> componentList = [];

  deleteAllComponents() {
    // selectedComponentId = null;
    canvasWriter.model.removeAllComponents();
  }

  String? selectedPortId;
  bool arePortsVisible = true;

  bool canConnectThesePorts(String? portId1, String? portId2) {
    if (portId1 == null || portId2 == null) {
      return false;
    }
    if (portId1 == portId2) {
      return false;
    }
    var port1 = canvasReader.model.getComponent(portId1);
    var port2 = canvasReader.model.getComponent(portId2);
    if (port1.type != 'port' || port2.type != 'port') {
      return false;
    }
    if (port1.data.type != port2.data.type) {
      return false;
    }
    if (port1.data.isInput && port2.data.isInput) {
      return false;
    }
    if (!port1.data.isInput && !port2.data.isInput) {
      return false;
    }
    if (port1.connections.isNotEmpty || port2.connections.isNotEmpty) {
      return false;
    }
    if (port1.parentId == port2.parentId) {
      return false;
    }
    return true;
  }

  selectPort(String portId) {
    var port = canvasReader.model.getComponent(portId);
    port.data.setPortState(PortState.selected);
    port.updateComponent();
    selectedPortId = portId;
    canvasReader.model.getAllComponents().values.forEach((port) {
      if (canConnectThesePorts(portId, port.id)) {
        (port.data as PortData).setPortState(PortState.highlighted);
        port.updateComponent();
      }
    });
  }

  deselectAllPorts() {
    selectedPortId = null;
    canvasReader.model.getAllComponents().values.forEach((component) {
      if (component.type == 'port') {
        (component.data as PortData)
            .setPortState(arePortsVisible ? PortState.shown : PortState.hidden);
        component.updateComponent();
      }
    });
  }

  hideAllHighLights() {
    canvasWriter.model.hideAllLinkJoints();
    canvasReader.model.getAllComponents().values.forEach(
      (component) {
        if (component.type != "port") {
          if (component.data.isHighlightVisible) {
            component.data.hideHighlight();
            canvasWriter.model.updateComponent(component.id);
          }
        }
      },
    );
  }

  updateAllComponentStyle() {
    canvasReader.model.getAllComponents().values.forEach(
      (component) {
        canvasWriter.model.updateComponent(component.id);
      },
    );
    canvasReader.model.getAllLinks().values.forEach((link) {
      ComponentData data =
          canvasReader.model.getComponent(link.sourceComponentId);
      link.linkStyle.color = data.data.color;
      canvasWriter.model.updateLink(link.id);
    });
  }

  addComponentDataWithPorts(ComponentData data, BuildContext context) {
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
    componentList.add(componentData.id);
  }

  ComponentData _addPortOnComponent(ComponentData data, BuildContext context) {
    int inputPortLen = data.data.inputData?.length;
    int outputPortLen = data.data.outputData?.length;
    double height = max(180, max(inputPortLen, outputPortLen) * 2 * 20);
    double width = (height * 5) / 3;
    var portComponent = ComponentData(
      size: Size(width, height),
      position: data.position,
      type: data.type,
      data: BuilderComponentData.copy(data.data),
    );

    switch (portComponent.data.inputData?.length) {
      case 0:
        break;
      case > 1:
        addMultipleInputPort(portComponent, context);
      case 1:
        portComponent.data.inputData?.forEach((input) {
          try {
            portComponent.data.portData.add(
              _getPortData(
                  Alignment.centerLeft, true, input, portComponent.id, context),
            );
          } catch (e) {}
        });
    }
    switch (portComponent.data.outputData?.length) {
      case 0:
        break;
      case > 1:
        addMultipleOutputPort(portComponent, context);
      case 1:
        portComponent.data.outputData?.forEach((output) {
          portComponent.data.portData.add(
            _getPortData(Alignment.centerRight, false, output, portComponent.id,
                context),
          );
        });
    }

    return portComponent;
  }

  void addMultipleInputPort(ComponentData data, BuildContext context) {
    var step = data.data.inputData?.length;
    var halfStep = 1.6 / step;
    var pos = -0.8 + (halfStep / 2);
    data.data.inputData?.forEach((input) {
      try {
        data.data.portData.add(
          _getPortData(Alignment(-1, pos), true, input, data.id, context),
        );
        pos += halfStep;
      } catch (e) {}
    });
  }

  void addMultipleOutputPort(ComponentData data, BuildContext context) {
    var step = data.data.outputData?.length;
    var halfStep = 1.6 / step;
    var pos = -0.8 + (halfStep / 2);
    data.data.outputData?.forEach((input) {
      try {
        data.data.portData.add(
          _getPortData(Alignment(1, pos), false, input, data.id, context),
        );
        pos += halfStep;
      } catch (e) {}
    });
  }

  PortData _getPortData(Alignment alignment, bool isInput,
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

  void highlightComponent(String componentId) {
    if (!canvasReader.model.componentExist(componentId))
      return; // Vérifie si le composant existe
    canvasReader.model.getComponent(componentId).data.showHighlight();
    canvasReader.model.getComponent(componentId).updateComponent();
    selectedComponentId = componentId;
  }

  void hideComponentHighlight(String? componentId) {
    if (componentId == null || !canvasReader.model.componentExist(componentId))
      return;
    canvasReader.model.getComponent(componentId).data.hideHighlight();
    canvasReader.model.getComponent(componentId).updateComponent();
    selectedComponentId = null;
  }

  // Save the diagram to String in json format.
  void serialize() {
    serializedDiagram = canvasReader.model.serializeDiagram();
  }

  // Load the diagram from json format. Do it cautiously, to prevent unstable state remove the previous diagram (id collision can happen).
  void deserialize() {
    canvasWriter.model.removeAllComponents();
    canvasWriter.model.deserializeDiagram(
      serializedDiagram,
      decodeCustomComponentData: BuilderComponentData.fromJson,
      decodeCustomLinkData: null,
    );
  }

  Result<Map<String, dynamic>, bool> toProgram() {
    final Map<String, dynamic> program = {};
    final List<Map<String, dynamic>> blocks = [];
    bool asFailure = false;
    for (var componentId in componentList) {
      var component = canvasReader.model.getComponent(componentId);
      BuilderComponentData componentData = component.data;
      Map<String, dynamic> parameters = {};
      for (var parameter in componentData.parameters) {
        parameters[parameter.name] = parameter.value;
      }
      var io = fetchBlockIO(component);
      if (io is Success) {
        var blockData = {
          "block_name": component.type,
          "block_id": component.id,
          "parameters": parameters,
          "outputs": (io as Success).value[1],
          "inputs": (io as Success).value[0],
        };
        blocks.add(blockData);
      } else {
        asFailure = true;
      }
    }
    program["blocks"] = blocks;
    return asFailure ? Failure(true) : Success(program);
  }

  Result<List<List<dynamic>>, bool> fetchBlockIO(ComponentData blockData) {
    List<Map<String, dynamic>> inputs = [];
    List<String> outputs = [];
    bool asEmptyMandatory = false;
    for (var portId in blockData.childrenIds) {
      var port = canvasReader.model.getComponent(portId);
      PortData portData = port.data;

      var portConnections = port.connections;
      if (portData.isMandatory && portConnections.isEmpty) {
        asEmptyMandatory = true;
        break;
      } else {
        portConnections.forEach(
          (connection) {
            var name = connection.otherComponentId;
            var linkedPort = canvasReader.model.getComponent(name);
            PortData linkedPortData = linkedPort.data;
            var linkedPortParent =
                canvasReader.model.getComponent(linkedPort.parentId!);
            if (portData.isInput) {
              inputs.add({
                "input_name": portData.name,
                "depend_block_name": linkedPortParent.type,
                "depend_block_id": linkedPortParent.id,
                "depend_on_block_output": linkedPortData.name,
              });
            } else {
              outputs.add(
                portData.name,
              );
            }
          },
        );
      }
    }
    return asEmptyMandatory ? Failure(false) : Success([inputs, outputs]);
  }
}

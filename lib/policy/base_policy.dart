import 'dart:math';

import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../component/port.dart';
import '../models/builder_component_data.dart';
import '../models/component_parameter.dart';
import '../models/result.dart';
import '../providers/builder_style.dart';

mixin BasePolicy implements PolicySet {
  String? selectedComponentId;
  String? selectedLinkId;
  String serializedDiagram = '{"components": [], "links": []}';
  List<String> componentList = [];
  dynamic diagram;
  Offset tapLinkPosition = Offset.zero;

  deleteAllComponents() {
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

  hideLinkOption() {
    selectedLinkId = null;
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
    var componentData = addPortOnComponent(data, context, 0);
    canvasWriter.model.addComponent(componentData);
    int zOrder =
        canvasWriter.model.moveComponentToTheFront(componentData.id) - 1;
    componentData.data.portData.forEach((PortData port) {
      var newPort = ComponentData(
        size: port.size,
        type: 'port',
        data: port,
        position: componentData.position +
            componentData.getPointOnComponent(port.alignmentOnComponent) -
            port.size.center(Offset.zero),
      );
      newPort.zOrder = zOrder;
      canvasWriter.model.addComponent(newPort);
      canvasWriter.model.setComponentParent(newPort.id, componentData.id);
    });
    componentList.add(componentData.id);
  }

  connectComponents(
      String? sourceComponentId, String? targetComponentId, Color color) {
    if (sourceComponentId == null || targetComponentId == null) return false;
    if (!canConnectThesePorts(sourceComponentId, targetComponentId)) {
      return false;
    }

    canvasWriter.model.connectTwoComponents(
      sourceComponentId: sourceComponentId,
      targetComponentId: targetComponentId,
      linkStyle: LinkStyle(
        arrowType: ArrowType.none,
        color: color,
        lineWidth: 4,
      ),
    );
    hideAllHighLights();

    return true;
  }

  addPortOnComponent(ComponentData data, BuildContext context, double offset) {
    int inputPortLen = data.data.inputData?.length;
    int outputPortLen = data.data.outputData?.length;
    double height = max(180, max(inputPortLen, outputPortLen) * 2 * 20);
    double width = (height * 5) / 3;
    var portComponent = ComponentData(
      size: Size(width, height),
      position: data.position + Offset(offset, offset),
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
    if (!canvasReader.model.componentExist(componentId)) {
      return; // Vérifie si le composant existe
    }
    canvasReader.model.getComponent(componentId).data.showHighlight();
    canvasReader.model.getComponent(componentId).updateComponent();
    selectedComponentId = componentId;
  }

  void hideComponentHighlight(String? componentId) {
    if (componentId == null ||
        !canvasReader.model.componentExist(componentId)) {
      return;
    }
    canvasReader.model.getComponent(componentId).data.hideHighlight();
    canvasReader.model.getComponent(componentId).updateComponent();
    selectedComponentId = null;
  }

  showLinkOption(String linkId, Offset position) {
    selectedLinkId = linkId;
    tapLinkPosition = position;
  }

  // Save the diagram to String in json format.
  serialize(BuilderStyle context) {
    diagram = exportDiagramToJson(context);
    return diagram;
  }

  importDiagramFromJson(
      BuildContext context, dynamic jsonDiagram, BuilderStyle styleProvider) {
    deleteAllComponents();
    styleProvider.fromJson(jsonDiagram["entry"]);
    for (var componentJson in jsonDiagram["components"]) {
      var mainComponent = ComponentData(
        id: componentJson["id"],
        type: componentJson["type"],
        data: BuilderComponentData(
          parameters: (componentJson["parameters"] as List)
              .map((param) => ComponentParameter.fromJson(param))
              .toList(),
          inputData: [], // Non utilisé lors du chargement
          outputData: [], // Non utilisé lors du chargement
          isOnMenu: false,
          color: Color(int.parse(componentJson["color"], radix: 16)),
          name: componentJson["name"],
        ),
        position: Offset(
          componentJson["position"]["x"],
          componentJson["position"]["y"],
        ),
        size: Size(
          componentJson["size"]["width"],
          componentJson["size"]["height"],
        ),
      );

      canvasWriter.model.addComponent(mainComponent);
      componentList.add(mainComponent.id);

      for (var portJson in componentJson["ports"]) {
        var portData = PortData(
          id: portJson["id"],
          type: portJson["type"],
          name: portJson["name"],
          isMandatory: portJson["isMandatory"],
          isInput: portJson["isInput"],
          size: Size(20, 20), // Taille fixe comme dans le code original
          alignmentOnComponent: Alignment(
            portJson["alignment"]["x"],
            portJson["alignment"]["y"],
          ),
          builderStyle: styleProvider,
        );

        // Calcul de la position relative au parent
        final portPosition = mainComponent.position +
            mainComponent.getPointOnComponent(portData.alignmentOnComponent) -
            portData.size.center(Offset.zero);

        var portComponent = ComponentData(
          id: portJson["id"],
          type: 'port',
          data: portData,
          position: portPosition,
          size: portData.size,
        );
        portComponent.zOrder -= 1;

        canvasWriter.model.addComponent(portComponent);
        canvasWriter.model
            .setComponentParent(portComponent.id, mainComponent.id);
      }
    }

    for (var connectionJson in jsonDiagram["connections"]) {
      final sourcePortId = connectionJson["source"]["port_id"];
      final targetPortId = connectionJson["target"]["port_id"];
      final color = Color(int.parse(connectionJson["color"], radix: 16));

      connectComponents(sourcePortId, targetPortId, color);
    }

    updateAllComponentStyle();
  }

  exportDiagramToJson(BuilderStyle context) {
    Map<String, dynamic> jsonDiagram = {
      "components": [],
      "connections": [],
    };
    for (ComponentData component
        in canvasReader.model.getAllComponents().values) {
      if (component.type != 'port') {
        BuilderComponentData componentData = component.data;

        List<Map<String, dynamic>> ports = [];
        for (String portId in component.childrenIds) {
          var portComponent = canvasReader.model.getComponent(portId);
          PortData portData = portComponent.data as PortData;
          ports.add({
            "id": portId,
            "name": portData.name,
            "type": portData.type,
            "isInput": portData.isInput,
            "isMandatory": portData.isMandatory,
            "alignment": {
              "x": portData.alignmentOnComponent.x,
              "y": portData.alignmentOnComponent.y,
            },
          });
        }

        jsonDiagram["components"].add({
          "id": component.id,
          "name": componentData.name,
          "type": component.type,
          "parameters":
              componentData.parameters.map((param) => param.toJson()).toList(),
          "position": {"x": component.position.dx, "y": component.position.dy},
          "size": {
            "width": component.size.width,
            "height": component.size.height
          },
          "color": componentData.color.value.toRadixString(16),
          "ports": ports,
        });
      }
    }
    if (componentList.isNotEmpty) {
      var allLinks = canvasReader.model.getAllLinks().values;
      for (var link in allLinks) {
        String sourcePortId = link.sourceComponentId;
        String targetPortId = link.targetComponentId;

        var sourcePort = canvasReader.model.getComponent(sourcePortId);
        var targetPort = canvasReader.model.getComponent(targetPortId);

        jsonDiagram["connections"].add({
          "source": {
            "block_id": sourcePort.parentId,
            "port_id": sourcePortId,
            "port_name": (sourcePort.data as PortData).name,
          },
          "target": {
            "block_id": targetPort.parentId,
            "port_id": targetPortId,
            "port_name": (targetPort.data as PortData).name,
          },
          "color": link.linkStyle.color.value.toRadixString(16),
        });
      }
    }

    jsonDiagram["entry"] = context.toJson();

    return jsonDiagram;
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

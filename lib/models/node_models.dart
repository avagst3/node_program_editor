import 'package:flutter/material.dart';
import '../models/node_data_model.dart';
import '../models/port_model.dart';

/// The `Node` class represents a node in a graphical system with input and output ports, allowing for
/// serialization and deserialization to JSON.
class Node {
  Offset position;
  Size size;
  final NodeData data;
  final int id;
  final List<Port> inputPorts;
  final List<Port> outputPorts;

  Node({
    required this.position,
    required this.data,
    required this.id,
    this.size = const Size(150, 80),
    List<Port>? inputs,
    List<Port>? outputs,
  })  : inputPorts = inputs ?? [],
        outputPorts = outputs ?? [] {
    _calculatePortPositions();
  }

  /// The function `_calculatePortPositions` assigns positions to input and output ports based on a
  /// visual start position and spacing.
  void _calculatePortPositions() {
    const double portVisualStartY = 50;
    const double portVisualSpacing = 20.0;
    for (int i = 0; i < inputPorts.length; i++) {
      inputPorts[i].position =
          Offset(0, portVisualStartY + (portVisualSpacing * i));
    }
    for (int i = 0; i < outputPorts.length; i++) {
      outputPorts[i].position =
          Offset(size.width, portVisualStartY + (portVisualSpacing * i));
    }
  }

  /// The function `setSize` sets a new size and calculates port positions accordingly.
  ///
  /// Args:
  ///   newSize (Size): The `newSize` parameter is of type `Size`, which likely represents the
  /// dimensions or size of an object or element. It is used to update the size of an object to the new
  /// dimensions provided.
  void setSize(Size newSize) {
    size = newSize;
    _calculatePortPositions();
  }

  /// The function `getPortCenterAbsolute` calculates the absolute center position of a port based on
  /// its index and whether it is an output port or not.
  ///
  /// Args:
  ///   index (int): The `index` parameter represents the index of the port within the `portList`
  /// (either `outputPorts` or `inputPorts`) for which you want to calculate the center position.
  ///   isOutput (bool): The `isOutput` parameter is a boolean value that indicates whether the port is
  /// an output port or not. If `isOutput` is true, it means the port is an output port; otherwise, it
  /// is an input port.
  ///
  /// Returns:
  ///   The function `getPortCenterAbsolute` returns an `Offset` object with the x-coordinate calculated
  /// based on the position of the port and whether it is an output port or not, and the y-coordinate
  /// based on the position of the port.
  Offset getPortCenterAbsolute(int index, bool isOutput) {
    final portList = isOutput ? outputPorts : inputPorts;
    final portPosition = portList[index].position;
    final double xOffset = isOutput ? size.width : 0;
    return Offset(
      position.dx + xOffset,
      position.dy + portPosition.dy,
    );
  }

  /// This function converts an object's properties into a JSON format.
  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data.toJson(),
        'position': {'dx': position.dx, 'dy': position.dy},
        'size': {'width': size.width, 'height': size.height},
        'inputPorts': inputPorts.map((p) => p.toJson()).toList(),
        'outputPorts': outputPorts.map((p) => p.toJson()).toList(),
      };

  /// The function `Node.fromJson` parses a JSON map to create a Node object with specified properties.
  ///
  /// Args:
  ///   json (Map<String, dynamic>): The `fromJson` method you provided is a factory constructor for
  /// creating a `Node` object from a JSON map. Here's a breakdown of the parameters used in the method:
  ///
  /// Returns:
  ///   The `Node` object created from the JSON data provided in the `fromJson` method is being
  /// returned.
  factory Node.fromJson(Map<String, dynamic> json) {
    var node = Node(
      id: json['id'],
      data: NodeData.fromJson(json['data']),
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      inputs: (json['inputPorts'] as List)
          .map((portJson) => Port.fromJson(portJson))
          .toList(),
      outputs: (json['outputPorts'] as List)
          .map((portJson) => Port.fromJson(portJson))
          .toList(),
    );
    node._calculatePortPositions();
    return node;
  }
}

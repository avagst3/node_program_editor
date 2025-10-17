import 'package:flutter/material.dart';
import 'package:node_program_editor/utils/jsonify_color.dart';

import 'port_model.dart';

/// The `NodeData` class in Dart represents data for a node with properties like colors, ports, node
/// type, name, icon, and icon color, and provides methods for JSON serialization and deserialization.
class NodeData {
  final Color portColor;
  final Color selectedPortColor;
  final Color selectedBorderColor;
  final Color iconColor;
  final String nodeName;
  final IconData icon;
  final String nodeType;
  final List<Port> inputPorts;
  final List<Port> outputPorts;

  /// The `NodeData` class constructor is initializing the properties of a `NodeData` object with the
  /// values passed as arguments. Here's a breakdown of what each parameter represents:
  NodeData(
    this.portColor,
    this.selectedPortColor,
    this.inputPorts,
    this.outputPorts,
    this.selectedBorderColor,
    this.nodeName,
    this.nodeType,
    this.icon,
    this.iconColor,
  );

  /// This function converts an object to a JSON map representation.
  Map<String, dynamic> toJson() => {
        'portColor': colorToJson(portColor),
        'selectedPortColor': colorToJson(selectedPortColor),
        'inputPorts': inputPorts.map((p) => p.toJson()).toList(),
        'outputPorts': outputPorts.map((p) => p.toJson()).toList(),
        'name': nodeName,
        'icon': {'codePoint': icon.codePoint, "family": icon.fontFamily},
        'nodeType': nodeType,
        'selectedBorderColor': colorToJson(selectedBorderColor),
        'iconColor': colorToJson(iconColor)
      };

  /// The `NodeData.fromJson` factory method parses a JSON map to create a `NodeData` object with
  /// various properties like colors, ports, node type, name, icon, and icon color.
  ///
  /// Args:
  ///   json (Map<String, dynamic>): The `fromJson` factory method you provided is used to create a
  /// `NodeData` object from a JSON map. Here is a breakdown of the parameters used in the method:
  ///
  /// Returns:
  ///   The `NodeData` object is being returned with the properties initialized using the values
  /// extracted from the provided `json` map.
  factory NodeData.fromJson(Map<String, dynamic> json) {
    final Color portColor = colorFromJson(json["portColor"]);
    final Color selectedPortColor = colorFromJson(json['selectedPortColor']);
    final String nodeType = json['nodeType'] as String;
    final String nodeName = json['name'] as String;
    final Color selectedBorderColor =
        colorFromJson(json["selectedBorderColor"]);
    final Color iconColor = colorFromJson(json["iconColor"]);
    final dynamic iconData = json["icon"];
    final IconData icon =
        IconData(iconData["codePoint"], fontFamily: iconData["family"]);
    final List<Port> inputPorts = (json['inputPorts'] as List)
        .map((pJson) => Port.fromJson(pJson as Map<String, dynamic>))
        .toList();
    final List<Port> outputPorts = (json['outputPorts'] as List)
        .map((pJson) => Port.fromJson(pJson as Map<String, dynamic>))
        .toList();

    return NodeData(
      portColor,
      selectedPortColor,
      inputPorts,
      outputPorts,
      selectedBorderColor,
      nodeName,
      nodeType,
      icon,
      iconColor,
    );
  }
}

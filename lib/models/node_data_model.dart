import 'package:flutter/material.dart';

import 'port_model.dart';

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

  Map<String, dynamic> toJson() => {
        'portColor': portColor.value,
        'selectedPortColor': selectedPortColor.value,
        'inputPorts': inputPorts.map((p) => p.toJson()).toList(),
        'outputPorts': outputPorts.map((p) => p.toJson()).toList(),
        'name': nodeName,
        'icon': {'codePoint': icon.codePoint, "family": icon.fontFamily},
        'type': nodeType,
        'selectedBorderColor': selectedBorderColor.value,
        'iconColor': iconColor.value
      };

  factory NodeData.fromJson(Map<String, dynamic> json) {
    final Color portColor = Color(json['portColor'] as int);
    final Color selectedPortColor = Color(json['selectedPortColor'] as int);
    final String nodeType = json['nodeType'] as String;
    final String nodeName = json['name'] as String;
    final Color selectedBorderColor = Color(json["selectedBorderColor"] as int);
    final Color iconColor = json["iconColor"];
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

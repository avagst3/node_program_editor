import 'package:flutter/material.dart';
import 'package:node_program_editor/models/io__data_template.dart';

import '../component/port.dart';
import 'component_parameter.dart';

class BuilderComponentData {
  final Color color;
  String name;
  final List<ComponentParameter> parameters;
  final List<IoDataTemplate> inputData;
  final List<IoDataTemplate> outputData;
  final bool isOnMenu;
  List<PortData> portData = [];

  

  bool isHighlightVisible = false;

  void showHighlight() {
    isHighlightVisible = true;
  }

  void hideHighlight() {
    isHighlightVisible = false;
  }

  // Function used to deserialize the diagram. Must be passed to `canvasWriter.model.deserializeDiagram` for proper deserialization.
  BuilderComponentData.fromJson(
    Map<String, dynamic> json,
  )   : isHighlightVisible = false,
        parameters = json["parameters"],
        name = json["name"],
        isOnMenu = true,
        outputData = [],
        inputData = [],
        color = Color(int.parse(json['color'], radix: 16));

  BuilderComponentData.copy(BuilderComponentData data)
      : this(
          color: data.color,
          name: data.name,
          parameters: data.parameters,
          inputData: data.inputData,
          outputData: data.outputData,
          isOnMenu: false,
        );

  // Function used to serialization of the diagram. E.g. to save to a file.
  Map<String, dynamic> toJson() => {
        'highlight': isHighlightVisible,
        'color': (((color.a * 255).round() << 24) |
                ((color.r * 255).round() << 16) |
                ((color.g * 255).round() << 8) |
                ((color.b * 255).round()))
            .toRadixString(16),
        'name': name,
        'parameters':parameters.map((parameter)=> parameter.toJson()).toList(),
        'input':inputData.map((data)=>data.toJson()).toList(),
        'output':outputData.map((data)=>data.toJson()).toList(),
        'on_menu':isOnMenu,
        'port_data':portData.map((port)=> port.toJson()).toList()
      };
  BuilderComponentData({
    required this.parameters,
    required this.inputData,
    required this.outputData,
    required this.isOnMenu,
    this.color = Colors.white,
    this.name = "",
  });
}

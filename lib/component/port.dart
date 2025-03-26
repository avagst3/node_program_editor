import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import '../providers/builder_style.dart';

class PortComponent extends StatelessWidget {
  final ComponentData componentData;

  const PortComponent({
    super.key,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    final PortData portData = componentData.data;

    return switch (portData.portState) {
      PortState.hidden => const SizedBox.shrink(),
      PortState.shown => Port(
          color: portData.color,
          borderColor: Colors.transparent,
          isSelected: false,
          isInput: portData.isInput,
        ),
      PortState.selected => Port(
          color: portData.color,
          borderColor: Colors.cyan,
          isSelected: true,
          isInput: portData.isInput,
        ),
      PortState.highlighted => Port(
          color: portData.color,
          borderColor: Colors.amber,
          isSelected: true,
          isInput: portData.isInput,
        ),
    };
  }
}

class Port extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final bool isSelected;
  final bool isInput;

  const Port({
    super.key,
    this.color = Colors.white,
    this.borderColor = Colors.black,
    required this.isSelected,
    required this.isInput,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = 5;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: isInput
            ? BorderRadius.only(
                topLeft: Radius.circular(radius),
                bottomLeft: Radius.circular(radius),
              )
            : BorderRadius.only(
                topRight: Radius.circular(radius),
                bottomRight: Radius.circular(radius),
              ),
        border: Border.all(
          width: 2,
          color: borderColor,
        ),
      ),
    );
  }
}

enum PortState { hidden, shown, selected, highlighted }

class PortData {
  final String id;
  final String type;
  final bool isMandatory;
  final bool isInput;
  final Size size;
  final Alignment alignmentOnComponent;
  final BuilderStyle builderStyle;
  final String name;

  PortState portState = PortState.shown;

  PortData({
    required this.id,
    required this.type,
    required this.name,
    required this.isMandatory,
    required this.isInput,
    required this.size,
    required this.alignmentOnComponent,
    required this.builderStyle,
  });

  Color get color {
    return builderStyle.entriesColors
        .firstWhere((entry) => entry.name == type)
        .color;
  }

  setPortState(PortState newState) {
    portState = newState;
  }
}

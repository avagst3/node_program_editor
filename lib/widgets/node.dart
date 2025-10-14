import 'package:flutter/material.dart';

import '../models/node_models.dart';
import '../models/port_model.dart';
import '../models/selected_port_info_model.dart';

typedef PortPanStartCallback = void Function(
    int portIndex, bool isOutput, DragStartDetails details);
typedef PortPanUpdateCallback = void Function(DragUpdateDetails details);
typedef PortPanEndCallback = void Function(DragEndDetails details);

class NodeWidget extends StatelessWidget {
  final Node node;
  final Widget nodeBody;
  final Color portColor;
  final Color selectedPortColor;
  final int nodeIndex;
  final bool isSelected;
  final void Function() onTap;
  final double scale;
  final SelectedPortInfo? selectedPortForLinking;
  final PortPanStartCallback onPortPanStart;
  final PortPanUpdateCallback onPortPanUpdate;
  final PortPanEndCallback onPortPanEnd;

  const NodeWidget({
    super.key,
    required this.node,
    required this.nodeIndex,
    required this.isSelected,
    required this.scale,
    required this.onTap,
    this.selectedPortForLinking,
    required this.onPortPanStart,
    required this.onPortPanUpdate,
    required this.onPortPanEnd,
    required this.nodeBody,
    required this.portColor,
    required this.selectedPortColor,
  });

  // Calcule la taille d'un texte pour dimensionner le nœud.
  Size getTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    final double portRadius = 8 * scale;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Corps principal du nœud
          nodeBody,
          // Ports d'entrée (gauche)
          for (int i = 0; i < node.inputPorts.length; i++)
            Positioned(
              left: -portRadius,
              top: node.inputPorts[i].position.dy * scale - portRadius,
              child: _buildPortWithLabel(
                port: node.inputPorts[i],
                portIndex: i,
                isOutput: false,
                isHighlighted: selectedPortForLinking != null &&
                    selectedPortForLinking!.nodeIndex == nodeIndex &&
                    selectedPortForLinking!.portIndex == i &&
                    !selectedPortForLinking!.isOutput,
              ),
            ),

          // Ports de sortie (droite)
          for (int i = 0; i < node.outputPorts.length; i++)
            Positioned(
              right: -portRadius,
              top: node.outputPorts[i].position.dy * scale - portRadius,
              child: _buildPortWithLabel(
                port: node.outputPorts[i],
                portIndex: i,
                isOutput: true,
                isHighlighted: selectedPortForLinking != null &&
                    selectedPortForLinking!.nodeIndex == nodeIndex &&
                    selectedPortForLinking!.portIndex == i &&
                    selectedPortForLinking!.isOutput,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortWithLabel({
    required Port port,
    required int portIndex,
    required bool isOutput,
    required bool isHighlighted,
  }) {
    final portWidget = GestureDetector(
      onPanStart: (details) => onPortPanStart(portIndex, isOutput, details),
      onPanUpdate: onPortPanUpdate,
      onPanEnd: onPortPanEnd,
      child: Container(
        width: 16 * scale,
        height: 16 * scale,
        decoration: BoxDecoration(
          color: isHighlighted ? selectedPortColor : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: portColor, width: 2 * scale),
        ),
      ),
    );

    final labelWidget = Text(
      port.label,
      style: TextStyle(fontSize: 14 * scale, color: Colors.black54),
    );

    if (isOutput) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [labelWidget, SizedBox(width: 8 * scale), portWidget],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [portWidget, SizedBox(width: 8 * scale), labelWidget],
      );
    }
  }
}

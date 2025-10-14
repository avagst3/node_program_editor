import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
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
    final double nodeBodyWidth = max(
          150.0,
          getTextSize("Instructions automates",
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w700))
                  .width +
              40,
        ) *
        scale;

    final double headerHeight = 50.0 * scale;
    final double footerHeight = 40.0 * scale;

    final double calculatedNodeHeight = headerHeight +
        footerHeight +
        max(node.inputPorts.length, node.outputPorts.length) *
            (16 * scale + 4 * scale) +
        (16 * scale);

    // Met à jour la taille du nœud dans le modèle après la construction du widget.
    // Cela évite les erreurs de "setState pendant le build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (node.size.width != nodeBodyWidth / scale ||
          node.size.height != calculatedNodeHeight / scale) {
        node.setSize(Size(nodeBodyWidth / scale, calculatedNodeHeight / scale));
      }
    });
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Corps principal du nœud
          Container(
            clipBehavior: Clip.hardEdge,
            width: nodeBodyWidth,
            height: calculatedNodeHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: isSelected
                      ? node.data.selectedBorderColor
                      : Colors.transparent,
                  width: isSelected ? 3 : 0,
                  strokeAlign: BorderSide.strokeAlignOutside),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0x02000000),
                  blurRadius: 42 * scale,
                  offset: Offset(-8 * scale, 106 * scale),
                ),
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 36 * scale,
                  offset: Offset(-5 * scale, 60 * scale),
                ),
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 26 * scale,
                  offset: Offset(-2 * scale, 26 * scale),
                ),
                BoxShadow(
                  color: Color(0x2C000000),
                  blurRadius: 17 * scale,
                  offset: Offset(-1 * scale, 7 * scale),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          node.data.icon,
                          size: 24 * scale,
                          color: node.data.iconColor,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: AutoSizeText(
                            node.data.nodeName,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Container()), // Espace central vide
                Container(
                  height: footerHeight,
                  color: Color(0xFFF1F1F1),
                  child: Center(
                    child: AutoSizeText(
                      node.data.nodeType,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

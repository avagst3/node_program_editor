import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../models/node_models.dart';
import '../models/port_model.dart';
import '../models/selected_port_info_model.dart';

/// The `typedef PortPanStartCallback` is defining a function type in Dart. It is creating an alias
/// `PortPanStartCallback` for a function that takes three parameters: `portIndex` of type `int`,
/// `isOutput` of type `bool`, and `details` of type `DragStartDetails`, and returns `void`. This allows
/// you to define functions with this signature and use them as callbacks in your code.
typedef PortPanStartCallback = void Function(
    int portIndex, bool isOutput, DragStartDetails details);
/// The `typedef PortPanUpdateCallback = void Function(DragUpdateDetails details);` line in the code is
/// defining a function type alias in Dart. It creates an alias `PortPanUpdateCallback` for a function
/// that takes one parameter `details` of type `DragUpdateDetails` and returns `void`. This allows you
/// to define functions with this specific signature and use them as callbacks in your code where
/// `PortPanUpdateCallback` type is expected.
typedef PortPanUpdateCallback = void Function(DragUpdateDetails details);
/// The `typedef PortPanEndCallback = void Function(DragEndDetails details);` line in the code is
/// defining a function type alias in Dart. It creates an alias `PortPanEndCallback` for a function that
/// takes one parameter `details` of type `DragEndDetails` and returns `void`. This allows you to define
/// functions with this specific signature and use them as callbacks in your code where
/// `PortPanEndCallback` type is expected.
typedef PortPanEndCallback = void Function(DragEndDetails details);


/// The `NodeWidget` class in Dart represents a widget that displays a node with input and output ports,
/// allowing for interaction through gestures.
class NodeWidget extends StatelessWidget {
  /// 
  final Node node;
  /// 
  final Color portColor;
  /// `
  final Color selectedPortColor;
  /// 
  final int nodeIndex;
  /// 
  final bool isSelected;
  /// 
  final void Function() onTap;
  /// 
  final double scale;
  /// 
  final SelectedPortInfo? selectedPortForLinking;
  /// 
  final PortPanStartCallback onPortPanStart;
  /// 
  final PortPanUpdateCallback onPortPanUpdate;
  /// 
  final PortPanEndCallback onPortPanEnd;
  /// Constructor
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


  /// The `getTextSize` function calculates and returns the size of the text when rendered with the
  /// specified style.
  /// 
  /// Args:
  ///   text (String): The `text` parameter is a String that represents the text for which you want to
  /// calculate the size.
  ///   style (TextStyle): The `style` parameter in the `getTextSize` method is of type `TextStyle`. It
  /// is used to specify the styling properties for the text that will be measured. This can include
  /// properties such as font size, font weight, color, and more. The `TextStyle` class in Flutter
  /// allows you
  /// 
  /// Returns:
  ///   The `Size` of the text after it has been styled and laid out using the provided `TextStyle`.
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
                Expanded(child: Container()), 
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

  /// This Dart function builds a widget that displays a port with a label, allowing for interaction
  /// through gestures.
  /// 
  /// Args:
  ///   port (Port): The `port` parameter is of type `Port` and is required for the
  /// `_buildPortWithLabel` function.
  ///   portIndex (int): The `portIndex` parameter is used to specify the index of the port within a
  /// list of ports. It helps in identifying the specific port that is being rendered or interacted with
  /// in the UI.
  ///   isOutput (bool): The `isOutput` parameter in the `_buildPortWithLabel` function is a boolean
  /// value that indicates whether the port is an output port or not. If `isOutput` is `true`, the
  /// function will return a `Row` widget with the label followed by the port widget. If `
  ///   isHighlighted (bool): The `isHighlighted` parameter in the `_buildPortWithLabel` function is
  /// used to determine whether the port should be displayed with a different color to indicate that it
  /// is highlighted. If `isHighlighted` is `true`, the color of the port will be set to
  /// `selectedPortColor`, otherwise
  /// 
  /// Returns:
  ///   The `_buildPortWithLabel` function returns a `Widget` that consists of a `Row` containing either
  /// the `labelWidget` followed by a `SizedBox` and then the `portWidget`, or the `portWidget` followed
  /// by a `SizedBox` and then the `labelWidget`, based on the value of the `isOutput` parameter.
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

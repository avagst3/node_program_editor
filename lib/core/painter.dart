import 'package:flutter/material.dart';

import '../models/connection_model.dart';
import '../models/node_models.dart';
import '../models/temp_link_model.dart';

/// The `EditorPainter` class in Dart is a custom painter that handles drawing nodes, connections, and
/// temporary links on a canvas with grid and Bezier curve functionality.
class EditorPainter extends CustomPainter {
  final Offset offset;
  final double scale;
  final List<Node> nodes;
  final List<Connection> connections;
  final TempLink? tempLink;
  final int? selectedNodeIndex;
  final int? selectedConnectionId;

  EditorPainter(this.offset, this.scale, this.nodes, this.connections,
      this.tempLink, this.selectedNodeIndex, this.selectedConnectionId);

  
  Node? _getNodeById(int id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Dessine la grille de fond
    final gridPaint = Paint()
      ..color = Colors.grey.withAlpha(100)
      ..strokeWidth = 1;

    var step = 20 * scale;
    final double offsetX = offset.dx % step;
    final double offsetY = offset.dy % step;
    for (double y = offsetY - step; y < size.height + step; y += step) {
      for (double x = offsetX - step; x < size.width + step; x += step) {
        canvas.drawCircle(Offset(x, y), 1 * scale, gridPaint);
      }
    }

    for (var link in connections) {
      final fromNode = _getNodeById(link.fromNodeId);
      final toNode = _getNodeById(link.toNodeId);
      if (fromNode == null || toNode == null) continue;

      final fromPortIndex =
          fromNode.outputPorts.indexWhere((p) => p.id == link.fromPortId);
      final toPortIndex =
          toNode.inputPorts.indexWhere((p) => p.id == link.toPortId);
      if (fromPortIndex == -1 || toPortIndex == -1) continue;

      final fromPort = fromNode.getPortCenterAbsolute(fromPortIndex, true);
      final toPort = toNode.getPortCenterAbsolute(toPortIndex, false);

      final path = _buildBezier(
        Offset(
            fromPort.dx * scale + offset.dx, fromPort.dy * scale + offset.dy),
        Offset(toPort.dx * scale + offset.dx, toPort.dy * scale + offset.dy),
      );

      final paint = Paint()
        ..color = (selectedConnectionId == link.id)
            ? Color(0xFF7296CE)
            : Color(0xFF0C489C)
        ..strokeWidth =
            (selectedConnectionId == link.id) ? 4 * scale : 2 * scale
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    if (tempLink != null) {
      final fromNode = nodes[tempLink!.nodeIndex];
      final fromPort = fromNode.getPortCenterAbsolute(
          tempLink!.portIndex, tempLink!.isOutput);
      final path = _buildBezier(
        Offset(
            fromPort.dx * scale + offset.dx, fromPort.dy * scale + offset.dy),
        Offset(tempLink!.currentDragPosition.dx * scale + offset.dx,
            tempLink!.currentDragPosition.dy * scale + offset.dy),
      );
      final paint = Paint()
        ..color = Color(0xFFD8E4FF)
        ..strokeWidth = 2 * scale
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
  }

  /// The `_buildBezier` function creates a Bezier curve path between two given points `p1` and `p2`.
  /// 
  /// Args:
  ///   p1 (Offset): The `p1` parameter represents the starting point of the Bezier curve. It is an
  /// `Offset` object that contains the x and y coordinates of the starting point.
  ///   p2 (Offset): The `p2` parameter represents the end point of the Bezier curve. It is an `Offset`
  /// object that contains the x and y coordinates of the end point.
  /// 
  /// Returns:
  ///   A `Path` object is being returned. The `Path` object is constructed by moving to the starting
  /// point `p1`, then creating a cubic Bezier curve using the control points `c1` and `c2`, and ending
  /// at point `p2`.
  Path _buildBezier(Offset p1, Offset p2) {
    final double tangentOffset = (p2.dx - p1.dx).abs() * 0.5;
    final c1 = Offset(p1.dx + tangentOffset, p1.dy);
    final c2 = Offset(p2.dx - tangentOffset, p2.dy);
    return Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

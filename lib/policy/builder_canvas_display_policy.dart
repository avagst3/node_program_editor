import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import 'base_policy.dart';

mixin BuilderCanvasDisplayPolicy implements CanvasWidgetsPolicy, BasePolicy {
  @override
  List<Widget> showCustomWidgetsOnCanvasBackground(BuildContext context) {
    return [
      Visibility(
        visible: true,
        child: CustomPaint(
          size: Size.infinite,
          painter: GridPainter(
            offset: canvasReader.state.position / canvasReader.state.scale,
            scale: canvasReader.state.scale,
            lineWidth: (canvasReader.state.scale < 1.0)
                ? canvasReader.state.scale
                : 1.0,
            matchParentSize: false,
            lineColor: const Color(0xFF0D47A1).withAlpha(60),
          ),
        ),
      ),
      DragTarget<ComponentData>(
        builder: (_, __, ___) => const SizedBox.shrink(),
        onWillAcceptWithDetails: (DragTargetDetails<ComponentData> data) =>
            true,
        onAcceptWithDetails: (DragTargetDetails<ComponentData> details) =>
            _onAcceptWithDetails(details, context),
      ),
    ];
  }

  _onAcceptWithDetails(
    DragTargetDetails details,
    BuildContext context,
  ) {
    hideAllHighLights();
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return;
    final Offset localOffset = (renderObject).globalToLocal(details.offset);
    ComponentData componentData = details.data;
    Offset componentPosition =
        canvasReader.state.fromCanvasCoordinates(localOffset);

    addComponentDataWithPorts(
      ComponentData(
        position: componentPosition,
        data: componentData.data,
        size: componentData.size,
        minSize: componentData.minSize,
        type: componentData.type,
      ),
      context,
    );
  }
}

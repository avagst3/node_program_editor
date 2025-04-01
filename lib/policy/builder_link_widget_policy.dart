import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'base_policy.dart';

mixin BuilderLinkWidgetPolicy implements LinkWidgetsPolicy, BasePolicy {
  @override
  List<Widget> showWidgetsWithLinkData(
      BuildContext context, LinkData linkData) {
    return [
      if (selectedLinkId == linkData.id) showLinkOptions(context, linkData),
    ];
  }

  Widget showLinkOptions(BuildContext context, LinkData linkData) {
    var nPos = canvasReader.state.toCanvasCoordinates(tapLinkPosition);
    return Positioned(
      left: nPos.dx,
      top: nPos.dy,
      child: GestureDetector(
        onTap: () {
          canvasWriter.model.removeLink(linkData.id);
        },
        child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            width: 32,
            height: 32,
            child: const Center(child: Icon(Icons.close, size: 20))),
      ),
    );
  }
}

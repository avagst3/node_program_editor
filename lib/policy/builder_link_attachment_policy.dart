import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

mixin BuilderLinkAttachmentPolicy implements LinkAttachmentPolicy {
  @override
  Alignment getLinkEndpointAlignment(
      ComponentData componentData, Offset targetPoint) {
    if (componentData.data.isInput) {
      return Alignment.centerLeft;
    } else {
      return Alignment.centerRight;
    }
  }
}

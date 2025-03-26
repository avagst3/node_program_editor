import 'package:diagram_editor/diagram_editor.dart';

import 'base_policy.dart';

mixin BuilderLinkJoinControlPolicy implements LinkJointPolicy, BasePolicy {
  
  @override
  void onLinkJointLongPress(int jointIndex, String linkId) {
    canvasWriter.model.removeLinkMiddlePoint(linkId, jointIndex);
    canvasWriter.model.updateComponent(linkId);
  }
}

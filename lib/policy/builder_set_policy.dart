import 'package:diagram_editor/diagram_editor.dart';

import 'base_policy.dart';
import 'builder_canvas_display_policy.dart';
import 'builder_canvas_policy.dart';
import 'builder_component_design_policy.dart';
import 'builder_component_policy.dart';
import 'builder_component_widget_policy.dart';
import 'builder_init_policy.dart';
import 'builder_link_attachment_policy.dart';
import 'builder_link_join_control_policy.dart';
class BuilderSetPolicy extends PolicySet
    with
        BasePolicy,
        BuilderCanvasPolicy,
        BuilderComponentDesignPolicy,
        BuilderComponentPolicy,
        BuilderInitPolicy,
        BuilderComponentWidgetPolicy,
        BuilderCanvasDisplayPolicy,
        CanvasControlPolicy,
        LinkControlPolicy,
        BuilderLinkAttachmentPolicy,
        BuilderLinkJoinControlPolicy,
        LinkJointControlPolicy {}

import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/menu/menu_bloc.dart';
import '../../bloc/settings_navigation/settings_navigation_bloc.dart';
import '../../policy/builder_set_policy.dart';
import '../parameters_menu_widgets/setting_box.dart';

class ParametersMenu extends StatelessWidget {
  final double width;
  final double height;
  final BuilderSetPolicy policy;
  const ParametersMenu({
    super.key,
    required this.diagramEditorContextMiniMap,
    required this.width,
    required this.height, required this.policy,
  });

  final DiagramEditorContext diagramEditorContextMiniMap;

  @override
  Widget build(BuildContext context) {
    final navBloc = BlocProvider.of<MenuBloc>(context);
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Visibility(
                visible: true,
                child: SizedBox(
                  width: width,
                  height: height * 0.25,
                  child: DiagramEditor(
                    diagramEditorContext: diagramEditorContextMiniMap,
                  ),
                ),
              ),
              BlocProvider(
                create: (context) => SettingsNavigationBloc(),
                child: SettingBox(
                  height: height * 0.75,
                  width: width,
                  policy: policy,
                ),
              )
            ],
          ),
          Positioned(
            bottom: height * 0.01,
            left: width * 0.02,
            child: IconButton(
              onPressed: () => navBloc.add(MenuEventClose()),
              icon: Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

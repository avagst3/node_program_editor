import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/menu/menu_bloc.dart';
import '../models/diagram_data.dart';
import '../policy/builder_set_policy.dart';
import '../policy/minimap_policy.dart';
import '../providers/builder_style.dart';
import 'menu/dragable_menu.dart';
import 'menu/parameters_menu.dart';

class DiagramApp extends StatefulWidget {
  final DiagramData diagramData;

  final BuilderSetPolicy myPolicySet;
  final double height;
  final double width;
  const DiagramApp({
    super.key,
    required this.diagramData,
    required this.myPolicySet,
    required this.height,
    required this.width,
  });

  @override
  DiagramAppState createState() => DiagramAppState();
}

class DiagramAppState extends State<DiagramApp> {
  MiniMapPolicySet miniMapPolicySet = MiniMapPolicySet();
  late DiagramEditorContext diagramEditorContext;
  late DiagramEditorContext diagramEditorContextMiniMap;

  bool isMiniMapVisible = true;
  bool isMenuVisible = true;
  bool isOptionsVisible = true;

  @override
  void initState() {
    diagramEditorContext = DiagramEditorContext(
      policySet: widget.myPolicySet,
    );

    diagramEditorContextMiniMap = DiagramEditorContext.withSharedModel(
      diagramEditorContext,
      policySet: miniMapPolicySet,
    );
    context
        .read<BuilderStyle>()
        .initData(widget.diagramData.entryData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    diagramEditorContext = diagramEditorContext;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            DiagramEditor(
              diagramEditorContext: diagramEditorContext,
            ),
            BlocProvider(
              create: (context) => MenuBloc(),
              child: BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  switch (state) {
                    case MenuOpened():
                      return Positioned(
                        right: 0,
                        child: ParametersMenu(
                          diagramEditorContextMiniMap:
                              diagramEditorContextMiniMap,
                          width: widget.width * 0.2,
                          height: widget.height,
                          policy: diagramEditorContext.policySet
                              as BuilderSetPolicy,
                        ),
                      );

                    default:
                      return Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () =>
                              BlocProvider.of<MenuBloc>(context).add(
                            MenuEventOpen(),
                          ),
                          icon: Icon(Icons.menu),
                        ),
                      );
                  }
                },
              ),
            ),
            BlocProvider(
              create: (context) => MenuBloc(),
              child: BlocBuilder<MenuBloc, MenuState>(
                builder: (context, state) {
                  switch (state) {
                    case MenuOpened():
                      return Positioned(
                        left: 0,
                        child: DraggableMenu(
                          policy: widget.myPolicySet,
                          blocks: widget.diagramData.blocksData,
                          width: widget.width * 0.15,
                        ),
                      );

                    default:
                      return Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          onPressed: () =>
                              BlocProvider.of<MenuBloc>(context).add(
                            MenuEventOpen(),
                          ),
                          icon: Icon(Icons.menu),
                        ),
                      );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

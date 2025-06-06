import 'package:auto_size_text/auto_size_text.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/menu/menu_bloc.dart';
import '../../models/block_template.dart';
import '../../models/builder_component_data.dart';
import '../../policy/base_policy.dart';

class DraggableMenu extends StatelessWidget {
  final double width;
  final BasePolicy policy;
  final List<BlockTemplate> blocks;
  const DraggableMenu(
      {super.key,
      required this.policy,
      required this.blocks,
      required this.width});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final navBloc = BlocProvider.of<MenuBloc>(context);
    return Container(
      color: Colors.grey.withAlpha(50),
      width: width,
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoSizeText(
                  "Menu",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => navBloc.add(MenuEventClose()),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...blocks.map(
                  (block) {
                    var componentData = _getData(block);
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width:
                                constraints.maxWidth < componentData.size.width
                                    ? componentData.size.width *
                                        (constraints.maxWidth /
                                            componentData.size.width)
                                    : componentData.size.width,
                            height:
                                constraints.maxWidth < componentData.size.width
                                    ? componentData.size.height *
                                        (constraints.maxWidth /
                                            componentData.size.width)
                                    : componentData.size.height,
                            child: Align(
                              alignment: Alignment.center,
                              child: AspectRatio(
                                aspectRatio: componentData.size.aspectRatio,
                                child: Tooltip(
                                  message: componentData.type,
                                  child: DraggableComponent(
                                    myPolicySet: policy,
                                    componentData: componentData,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ComponentData _getData(BlockTemplate block) {
    return ComponentData(
      size: Size(width, 100),
      minSize: const Size(80, 64),
      data: BuilderComponentData(
        color: Color(0xFFFFF6FA),
        name: block.name,
        parameters: block.parameters,
        inputData: block.inputData,
        outputData: block.outputData,
        isOnMenu: true,
      ),
      type: block.type,
    );
  }
}

class DraggableComponent extends StatelessWidget {
  final BasePolicy myPolicySet;
  final ComponentData componentData;
  const DraggableComponent(
      {super.key, required this.myPolicySet, required this.componentData});

  @override
  Widget build(BuildContext context) {
    return Draggable<ComponentData>(
      affinity: Axis.horizontal,
      ignoringFeedbackSemantics: true,
      data: componentData,
      childWhenDragging: myPolicySet.showComponentBody(componentData),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: componentData.size.width,
          height: componentData.size.height,
          child: myPolicySet.showComponentBody(componentData),
        ),
      ),
      child: myPolicySet.showComponentBody(componentData)!,
    );
  }
}

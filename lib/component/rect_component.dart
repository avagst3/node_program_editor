import 'package:auto_size_text/auto_size_text.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';

import '../models/builder_component_data.dart';

class RectComponent extends StatelessWidget {
  final ComponentData componentData;

  const RectComponent({
    super.key,
    required this.componentData,
  });

  @override
  Widget build(BuildContext context) {
    final BuilderComponentData builderComponentData = componentData.data;

    return Container(
      decoration: BoxDecoration(
          color: builderComponentData.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFFD0CDE1),
            width: 2,
          ) //BoxShadow
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              builderComponentData.name,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            builderComponentData.isOnMenu
                ? SizedBox.shrink()
                : Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withAlpha(20),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: SingleChildScrollView(
                          child: Column(
                            children:
                                builderComponentData.parameters.map<Widget>(
                              (parameter) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        "${parameter.name} : ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    Expanded(
                                      child: AutoSizeText(
                                        parameter.value.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

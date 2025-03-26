
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/program/program_cubit.dart';
import '../../models/result.dart';
import '../../policy/builder_set_policy.dart';
import '../../providers/builder_style.dart';
import '../parameters_fields/color_picker_dialog.dart';

class AppSettings extends StatelessWidget {
  final BuilderStyle properties;
  final BuilderSetPolicy policy;
  const AppSettings({
    super.key,
    required this.properties,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () {
                Result<Map<String,dynamic>,bool> program = policy.toProgram();
                if (program is Success) {
                  context.read<ProgramCubit>().emitProgram((program as Success).value);
                }
                
              },
              icon: Icon(Icons.upload_rounded),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Ports colors :",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Column(
          children: properties.entriesColors.map<Widget>((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.name),
                      GestureDetector(
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: entry.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onTap: () async {
                          var pickedColor = showPickColorDialog(
                              context, entry.color, 'Pick a component color');
                          context
                              .read<BuilderStyle>()
                              .updateEntryColor(entry, await pickedColor);
                        },
                      )
                    ],
                  ),
                  Divider(),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

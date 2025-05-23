import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc/program/program_cubit.dart';
import '../bloc/show_component_settings/show_component_settings_cubit.dart';
import '../models/diagram_data.dart';
import '../models/diagram_text.dart';
import '../policy/builder_set_policy.dart';
import '../providers/builder_style.dart';
import '../providers/program_data_provider.dart';
import '../providers/text_provider.dart';
import 'diagram_app.dart';

class NodeProgramEditor extends StatelessWidget {
  /// A node editor widget
  /// Create a node widget where you can create,load and save program
  final DiagramData data;
  final DiagramText? diagramText;
  final double? height;
  final double? width;
  final String? programName;
  final String? userName;
  final void Function(Map<String, dynamic> program)? onProgramEmitted;
  const NodeProgramEditor({
    super.key,
    required this.data,
    this.height,
    this.width,
    this.onProgramEmitted,
    this.programName,
    this.userName,
    this.diagramText,
  });

  @override
  Widget build(BuildContext context) {
    BuilderSetPolicy policy = BuilderSetPolicy();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BuilderStyle(policy: policy),
        ),
        ChangeNotifierProvider(
          create: (context) => ProgramDataProvider(
            programName: "hello word",
            authorName: userName,
          ),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ShowComponentSettingsCubit(),
          ),
          BlocProvider(
            create: (context) => ProgramCubit(),
          ),
        ],
        child: BlocListener<ProgramCubit, ProgramState>(
          listener: (context, state) {
            switch (state) {
              case ProgramEmitted():
                onProgramEmitted?.call(state.program);
                break;
              default:
            }
          },
          child: ChangeNotifierProvider(
            create: (context) => TextProvider(
              diagramText ??
                  DiagramText(
                    "Menu",
                    "No block selected",
                    "Global settings",
                    "Block settings",
                    "Ports color",
                    "Edit parameters",
                    "Edit parameters",
                    "Update",
                    "Export program",
                    "Save program",
                    "Load program",
                    "Color picker",
                    "Close",
                    "Set color",
                  ),
            ),
            child: DiagramApp(
              myPolicySet: policy,
              height: height ?? MediaQuery.of(context).size.height,
              width: width ?? MediaQuery.of(context).size.width,
              diagramData: data,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../bloc/program/program_cubit.dart';
import '../bloc/show_component_settings/show_component_settings_cubit.dart';
import '../policy/builder_set_policy.dart';
import '../providers/builder_style.dart';
import 'diagram_app.dart';

class NodeProgramEditor extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData? appTheme;
  final double? height;
  final double? width;
  final void Function(Map<String, dynamic> program)? onProgramEmitted;
  const NodeProgramEditor({
    super.key,
    required this.data,
    this.appTheme,
    this.height,
    this.width,
    this.onProgramEmitted,
  });

  @override
  Widget build(BuildContext context) {
    BuilderSetPolicy policy = BuilderSetPolicy();

    return ChangeNotifierProvider(
      create: (context) => BuilderStyle(policy: policy),
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
          child: DiagramApp(
            blocks: data,
            myPolicySet: policy,
            height: height ?? MediaQuery.of(context).size.height,
            width: width ?? MediaQuery.of(context).size.width,
          ),
        ),
      ),
    );
  }
}

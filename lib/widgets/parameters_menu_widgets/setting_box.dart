import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../bloc/settings_navigation/settings_navigation_bloc.dart';
import '../../bloc/show_component_settings/show_component_settings_cubit.dart';
import '../../policy/builder_set_policy.dart';
import '../../providers/builder_style.dart';
import 'app_settings.dart';
import 'builder_component_settings.dart';

class SettingBox extends StatelessWidget {
  final double height;
  final double width;
  final BuilderSetPolicy policy;
  const SettingBox(
      {super.key,
      required this.height,
      required this.width,
      required this.policy,});

  @override
  Widget build(BuildContext context) {
    final navBloc = BlocProvider.of<SettingsNavigationBloc>(context);
    return BlocBuilder<SettingsNavigationBloc, SettingsNavigationState>(
      builder: (context, state) {
        return Container(
          width: width,
          height: height,
          color: Colors.white,
          child: switch (state) {
            SettingsNavigationOnBlockSettings() => Stack(
                children: [
                  BlocBuilder<ShowComponentSettingsCubit,
                      ShowComponentSettingsState>(
                    builder: (context, state) {
                      switch (state) {
                        case ShowComponentSettingsInitial():
                          return Center(child: Text("No block selected"));
                        case ShowComponentSettingsShow():
                          return BuilderComponentSettings(
                            data: state.data,
                            width: width,
                            height: height,
                          );
                      }
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FilledButton(
                      onPressed: () =>
                          navBloc.add(SettingsNavigationToDiagramSettings()),
                      child: Text("Diagram settings"),
                    ),
                  )
                ],
              ),
            SettingsNavigationOnDiagramSettings() => Consumer<BuilderStyle>(
                builder: (context, properties, child) {
                  return Stack(
                    children: [
                      AppSettings(
                        properties: properties,
                        policy: policy,
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: FilledButton(
                          onPressed: () =>
                              navBloc.add(SettingsNavigationToBlockSettings()),
                          child: Text("Block settings"),
                        ),
                      )
                    ],
                  );
                },
              ),
            SettingsNavigationInitial() => Container(),
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:node_program_editor/providers/text_provider.dart';
import 'package:provider/provider.dart';

import '../../bloc/settings_navigation/settings_navigation_bloc.dart';
import '../../bloc/show_component_settings/show_component_settings_cubit.dart';
import '../../policy/builder_set_policy.dart';
import '../../providers/builder_style.dart';
import '../../providers/program_data_provider.dart';
import 'app_settings.dart';
import 'builder_component_settings.dart';
import 'program_actions.dart';
import 'settings_bottom_bar.dart';

class SettingBox extends StatelessWidget {
  final double height;
  final double width;
  final BuilderSetPolicy policy;
  const SettingBox({
    super.key,
    required this.height,
    required this.width,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<SettingsNavigationBloc, SettingsNavigationState>(
          builder: (context, state) {
            return Container(
              width: width,
              height: height,
              color: Colors.white,
              child: switch (state) {
                SettingsNavigationOnBlockSettings() => Column(
                    children: [
                      ProgramActions(
                        policy: policy,
                        provider: context.watch<ProgramDataProvider>(),
                        width: width,
                        styleProvider: context.watch<BuilderStyle>(),
                      ),
                      Expanded(
                        child: BlocBuilder<ShowComponentSettingsCubit,
                            ShowComponentSettingsState>(
                          builder: (context, state) {
                            switch (state) {
                              case ShowComponentSettingsInitial():
                                return Consumer<TextProvider>(
                                    builder: (context, textProvider, child) {
                                  return Center(
                                    child: Text(
                                      textProvider
                                          .text.settingsNoSelectedTarget,
                                    ),
                                  );
                                });
                              case ShowComponentSettingsShow():
                                return BuilderComponentSettings(
                                  data: state.data,
                                  width: width,
                                  height: height * 0.8,
                                );
                            }
                          },
                        ),
                      ),
                      SettingBottomBar(
                        event: SettingsNavigationToDiagramSettings(),
                        buttonLabel: "Global settings",
                      ),
                    ],
                  ),
                SettingsNavigationOnDiagramSettings() => Consumer<BuilderStyle>(
                    builder: (context, properties, child) {
                      return Column(
                        children: [
                          ProgramActions(
                            policy: policy,
                            provider: context.watch<ProgramDataProvider>(),
                            width: width,
                            styleProvider: context.watch<BuilderStyle>(),
                          ),
                          Expanded(
                            child: AppSettings(
                              properties: properties,
                              policy: policy,
                              height: height * 0.8,
                              width: width,
                            ),
                          ),
                          SettingBottomBar(
                            event: SettingsNavigationToBlockSettings(),
                            buttonLabel: "Bloc settings",
                          ),
                        ],
                      );
                    },
                  ),
                SettingsNavigationInitial() => Container(),
              },
            );
          },
        ),
      ],
    );
  }
}

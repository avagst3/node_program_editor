import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/settings_navigation/settings_navigation_bloc.dart';
import '../../bloc/menu/menu_bloc.dart';

class SettingBottomBar extends StatelessWidget {
  const SettingBottomBar({
    super.key,
    required this.event,
    required this.buttonLabel,
  });

  final SettingsNavigationEvent event;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final navBloc = BlocProvider.of<SettingsNavigationBloc>(context);
    final menuBloc = BlocProvider.of<MenuBloc>(context);
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => menuBloc.add(MenuEventClose()),
              icon: Icon(Icons.close),
            ),
            FilledButton(
              onPressed: () => navBloc.add(event),
              child: AutoSizeText(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

part of 'show_component_settings_cubit.dart';

@immutable
sealed class ShowComponentSettingsState {}

final class ShowComponentSettingsInitial extends ShowComponentSettingsState {}

final class ShowComponentSettingsShow extends ShowComponentSettingsState {
  final ComponentData data;
  ShowComponentSettingsShow(this.data);
}

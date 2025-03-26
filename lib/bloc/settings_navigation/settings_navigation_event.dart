part of 'settings_navigation_bloc.dart';

@immutable
sealed class SettingsNavigationEvent {}

class SettingsNavigationToBlockSettings extends SettingsNavigationEvent {}

class SettingsNavigationToDiagramSettings extends SettingsNavigationEvent {}

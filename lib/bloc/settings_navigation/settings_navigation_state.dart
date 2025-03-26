part of 'settings_navigation_bloc.dart';

@immutable
sealed class SettingsNavigationState {}

final class SettingsNavigationInitial extends SettingsNavigationState {}

final class SettingsNavigationOnBlockSettings extends SettingsNavigationState {}

final class SettingsNavigationOnDiagramSettings
    extends SettingsNavigationState {}

part of 'menu_bloc.dart';

@immutable
sealed class MenuState {}

final class MenuInitial extends MenuState {}

final class MenuOpened extends MenuState {}

final class MenuClosed extends MenuState {}

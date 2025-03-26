part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {}

class MenuEventClose extends MenuEvent {}

class MenuEventOpen extends MenuEvent {}

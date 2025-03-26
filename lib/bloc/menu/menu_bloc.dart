import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(MenuInitial()) {
    _init();
    on<MenuEventClose>(_closeMenu);
    on<MenuEventOpen>(_openMenu);
  }

  void _init() {
    emit(MenuOpened());
  }

  FutureOr<void> _closeMenu(MenuEventClose event, Emitter<MenuState> emit) {
    emit(MenuClosed());
  }

  FutureOr<void> _openMenu(MenuEventOpen event, Emitter<MenuState> emit) {
    emit(MenuOpened());
  }
}

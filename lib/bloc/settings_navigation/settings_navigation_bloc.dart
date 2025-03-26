import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'settings_navigation_event.dart';
part 'settings_navigation_state.dart';

class SettingsNavigationBloc
    extends Bloc<SettingsNavigationEvent, SettingsNavigationState> {
  SettingsNavigationBloc() : super(SettingsNavigationInitial()) {
    _init();
    on<SettingsNavigationToBlockSettings>(_toBlockSettings);
    on<SettingsNavigationToDiagramSettings>(_toDiagramSettings);
  }

  void _init() => emit(SettingsNavigationOnBlockSettings());

  FutureOr<void> _toBlockSettings(SettingsNavigationToBlockSettings event,
      Emitter<SettingsNavigationState> emit) {
    emit(SettingsNavigationOnBlockSettings());
  }

  FutureOr<void> _toDiagramSettings(SettingsNavigationToDiagramSettings event,
      Emitter<SettingsNavigationState> emit) {
    emit(SettingsNavigationOnDiagramSettings());
  }
}

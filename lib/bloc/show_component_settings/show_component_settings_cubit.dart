import 'package:bloc/bloc.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:meta/meta.dart';

part 'show_component_settings_state.dart';

class ShowComponentSettingsCubit extends Cubit<ShowComponentSettingsState> {
  ShowComponentSettingsCubit() : super(ShowComponentSettingsInitial());

  void showSettings(ComponentData data) {
    emit(ShowComponentSettingsShow(data));
  }

  void hideSettings() {
    emit(ShowComponentSettingsInitial());
  }
}

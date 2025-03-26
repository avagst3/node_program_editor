import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'program_state.dart';

class ProgramCubit extends Cubit<ProgramState> {
  ProgramCubit() : super(ProgramInitial());

  void emitProgram(Map<String, dynamic> program) {
    emit(ProgramInitial());
    emit(ProgramEmitted(program));
  }
}

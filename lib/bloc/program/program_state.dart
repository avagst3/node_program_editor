part of 'program_cubit.dart';

@immutable
sealed class ProgramState {}

final class ProgramInitial extends ProgramState {}

final class ProgramEmitted extends ProgramState {
  final Map<String, dynamic> program;
  ProgramEmitted(this.program);
}

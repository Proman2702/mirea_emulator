import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirea_emulator/shell/exceptions.dart';
import 'package:mirea_emulator/shell/shell.dart';
import 'package:mirea_emulator/terminal/cubit/terminal_state.dart';
import 'package:mirea_emulator/terminal/models/terminal_entry.dart';

class TerminalCubit extends Cubit<TerminalState> {
  TerminalCubit(this.shell) : super(TerminalState(entries: []));

  final Shell shell;

  void _addEntry(TerminalEntry entry) {
    emit(TerminalState(entries: [...state.entries, entry]));
  }

  void executeCommand(String command) {
    _addEntry(TerminalEntry(text: command, type: TerminalEntryType.command));

    try {
      _addEntry(TerminalEntry(text: shell.execute(command).toString(), type: TerminalEntryType.output));
    } on CommandParseException catch (e) {
      _addEntry(TerminalEntry(text: e.message, type: TerminalEntryType.error));
    } on ExitCommandException {
      exit(0);
    }
  }
}

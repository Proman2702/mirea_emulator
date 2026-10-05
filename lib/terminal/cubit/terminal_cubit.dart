import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirea_emulator/exceptions.dart';
import 'package:mirea_emulator/shell/shell.dart';
import 'package:mirea_emulator/terminal/cubit/terminal_state.dart';
import 'package:mirea_emulator/terminal/models/terminal_entry.dart';

class TerminalCubit extends Cubit<TerminalState> {
  TerminalCubit(this.shell, {required this.scriptPath}) : super(TerminalState(entries: []));

  final Shell shell;
  final String scriptPath;

  void _addEntry(TerminalEntry entry) {
    emit(TerminalState(entries: [...state.entries, entry]));
  }

  void executeCommand(String command) {
    _addEntry(TerminalEntry(text: command, type: TerminalEntryType.command));

    try {
      _addEntry(TerminalEntry(text: shell.execute(command).toString(), type: TerminalEntryType.output));
    } on CommandParseException catch (e) {
      _addEntry(TerminalEntry(text: e.message, type: TerminalEntryType.error));
    } on VfsException catch (e) {
      _addEntry(TerminalEntry(text: e.message, type: TerminalEntryType.error));
    } on ExitCommandException {
      exit(0);
    }
  }

  void executeScript() {
    final List<String> lines = File(scriptPath).readAsLinesSync();
    for (final String line in lines) {
      if (line.trim().isNotEmpty) executeCommand(line);
    }
  }
}

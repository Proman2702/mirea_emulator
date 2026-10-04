enum TerminalEntryType { command, output, error }

class TerminalEntry {
  final String text;
  final TerminalEntryType type;
  TerminalEntry({required this.text, required this.type});
}
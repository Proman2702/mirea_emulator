

class CommandParseException implements Exception {
  final String message;
  CommandParseException({required this.message});
}

class CmdParser {
  ParsedCommand parse(String raw) {
    List<String> args = [];
    int start = 0;
    bool quotes = false;

    for (int i = 0; i < raw.length; i++) {
      if (raw[i] == ' ' && !quotes) {
        if (raw.substring(start, i).isNotEmpty) args.add(raw.substring(start, i).replaceAll('"', ''));
        start = i + 1;
      } else if (raw[i] == '"') {
        quotes = !quotes;
      }
    }

    if (quotes) throw CommandParseException(message: "unclosed quote");

    if (raw.substring(start).isNotEmpty) args.add(raw.substring(start).replaceAll('"', ''));

    if (args.isEmpty) throw CommandParseException(message: "command not found");

    return ParsedCommand(command: args[0], args: args.sublist(1));
  }
}

class ParsedCommand {
  final String command;
  final List<String> args;

  ParsedCommand({required this.command, required this.args});
}

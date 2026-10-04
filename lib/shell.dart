import 'package:mirea_emulator/cmd_parser.dart';

class ExitCommandException implements Exception {}

class Shell {
  CmdParser parser = CmdParser();

  String execute(String raw) {
    ParsedCommand command = parser.parse(raw);
    switch (command.command) {
      case "exit":
        throw ExitCommandException();
      case "ls":
        return "command: ${command.command} \nargs: ${command.args.isEmpty ? "[]" : command.args.asMap().entries.map((e) => "[${e.key}] - ${e.value}").join(", ")}";
      case "cd":
        return "command: ${command.command} \nargs: ${command.args.isEmpty ? "[]" : command.args.asMap().entries.map((e) => "[${e.key}] - ${e.value}").join(", ")}";
      default:
        throw CommandParseException(message: "command not found");
    }
  }
}

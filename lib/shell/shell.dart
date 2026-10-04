import 'package:mirea_emulator/shell/cmd_parser.dart';
import 'package:mirea_emulator/shell/exceptions.dart';
import 'package:mirea_emulator/vfs/vfs.dart';

class Shell {
  final Vfs vfs;

  Shell(this.vfs);

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

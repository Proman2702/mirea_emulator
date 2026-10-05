import 'package:mirea_emulator/shell/cmd_parser.dart';
import 'package:mirea_emulator/exceptions.dart';
import 'package:mirea_emulator/vfs/vfs.dart';
import 'package:mirea_emulator/vfs/vfs_object.dart';

class Shell {
  final Stopwatch uptime = Stopwatch()..start();
  final Vfs vfs;

  Shell(this.vfs);

  CmdParser parser = CmdParser();

  final List<String> currentPath = [];
  final List<String> history = [];

  String _ls(ParsedCommand command) {
    if (command.args.isNotEmpty) {
      throw CommandParseException(message: "ls command doesn't take any arguments");
    }

    final path = "/${currentPath.join("/")}";
    final vfsObject = vfs.getObject(path);

    return vfsObject.children!.entries
        .map((e) => e.value.type == VfsObjectType.directory ? "${e.key}/" : e.key)
        .join("\n");
  }

  String _cd(ParsedCommand command) {
    if (command.args.length != 1) {
      throw CommandParseException(message: "cd command takes only 1 argument");
    }

    if (command.args[0] == "..") {
      if (currentPath.isEmpty) {
        throw CommandParseException(message: "You are in root directory");
      }
      currentPath.removeLast();
      return "/${currentPath.join("/")}";
    }

    final argumentParts = command.args[0].split("/").where((part) => part.isNotEmpty).toList();
    final newPath = command.args[0].startsWith("/") ? argumentParts : [...currentPath, ...argumentParts];

    if (vfs.getObject("/${newPath.join("/")}").type == VfsObjectType.file) {
      throw CommandParseException(message: "${command.args[0]} is not a directory");
    }

    currentPath
      ..clear()
      ..addAll(newPath);

    return "/${currentPath.join("/")}";
  }

  String _uptime(ParsedCommand command) {
    if (command.args.isNotEmpty) {
      throw CommandParseException(message: "uptime command doesn't take any arguments");
    }

    final timePassed = uptime.elapsed;

    return "${timePassed.inHours} hours, ${timePassed.inMinutes % 60} minutes, ${timePassed.inSeconds % 60} seconds";
  }

  String _history(ParsedCommand command) {
    if (command.args.isNotEmpty) {
      throw CommandParseException(message: "history command doesn't take any arguments");
    }
    return history.join("\n");
  }

  String execute(String raw) {
    ParsedCommand command = parser.parse(raw);

    history.add(raw);
    switch (command.command) {
      case "exit":
        throw ExitCommandException();
      case "ls":
        return _ls(command);
      case "cd":
        return _cd(command);
      case "uptime":
        return _uptime(command);
      case "history":
        return _history(command);
      default:
        throw CommandParseException(message: "command not found");
    }
  }
}

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

  String _resolvePath(String argument) {
    final argumentParts = argument.split("/").where((part) => part.isNotEmpty).toList();
    final newPath = argument.startsWith("/") ? argumentParts : [...currentPath, ...argumentParts];

    return "/${newPath.join("/")}";
  }

  String _ls(ParsedCommand command) {
    if (command.args.isNotEmpty) {
      throw CommandParseException(message: "ls command doesn't take any arguments");
    }

    final path = "/${currentPath.join("/")}";
    final vfsObject = vfs.getObject(path);

    return vfsObject.children!.entries
        .map((e) => e.value.type == VfsObjectType.directory ? "${e.key}/    ${e.value.owner}" : "${e.key}    ${e.value.owner}")
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

    final path = _resolvePath(command.args[0]);

    if (vfs.getObject(path).type == VfsObjectType.file) {
      throw CommandParseException(message: "${command.args[0]} is not a directory");
    }

    currentPath
      ..clear()
      ..addAll(path.split("/").where((part) => part.isNotEmpty));

    return "/${currentPath.join("/")}";
  }

  String _rm(ParsedCommand command) {
    if (command.args.length != 1) {
      throw CommandParseException(message: "rm command takes only 1 argument");
    }

    vfs.removeObject(_resolvePath(command.args[0]));

    return "Removed ${command.args[0]}";
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

  String _chown(ParsedCommand command) {
    if (command.args.length != 2) {
      throw CommandParseException(message: "chown command takes only 2 arguments");
    }

    vfs.changeOwner(_resolvePath(command.args[1]), command.args[0]);

    return "Owner of ${command.args[1]} changed to ${command.args[0]}";
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
      case "rm":
        return _rm(command);
      case "uptime":
        return _uptime(command);
      case "history":
        return _history(command);
      case "chown":
        return _chown(command);
      default:
        throw CommandParseException(message: "command not found");
    }
  }
}

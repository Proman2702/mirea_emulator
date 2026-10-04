import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirea_emulator/app.dart';

void main(List<String> args) {
  if (args.length != 2) {
    print("Arguments are not found");
    exit(1);
  }

  final vfsPath = args[0];
  final scriptPath = args[1];

  final vfsFile = File(vfsPath);
  final scriptFile = File(scriptPath);

  if (!scriptFile.existsSync()) {
    print("Script file does not exist");
    exit(1);
  }

  if (!vfsFile.existsSync()) {
    print("VFS file does not exist");
    exit(1);
  }
  runApp(App(vfsPath: vfsPath, scriptPath: scriptPath));
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mirea_emulator/app.dart';
import 'package:mirea_emulator/vfs/vfs.dart';

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

  late final Vfs vfs;

  try {
    vfs = Vfs.fromZip(vfsPath);
  } catch (e) {
    print("Failed to load VFS file");
    exit(1);
  }

  runApp(App(vfs: vfs, scriptPath: scriptPath));
}

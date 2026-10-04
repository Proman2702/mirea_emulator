import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirea_emulator/shell/shell.dart';
import 'package:mirea_emulator/terminal/cubit/terminal_cubit.dart';
import 'package:mirea_emulator/terminal/ui/vfs_screen.dart';

class App extends StatelessWidget {
  final String vfsPath;
  final String scriptPath;

  const App({super.key, required this.vfsPath, required this.scriptPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => TerminalCubit(Shell(), vfsPath: vfsPath, scriptPath: scriptPath)..executeScript(),
        child: VFSScreen(),
      ),
    );
  }
}

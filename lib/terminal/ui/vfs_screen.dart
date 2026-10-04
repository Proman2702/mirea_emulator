import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mirea_emulator/shell/exceptions.dart';
import 'package:mirea_emulator/shell/shell.dart';
import 'package:mirea_emulator/terminal/models/terminal_entry.dart';
import 'package:mirea_emulator/terminal/ui/terminal_entry_widget.dart';





class VFSScreen extends StatefulWidget {
  const VFSScreen({super.key});

  @override
  State<VFSScreen> createState() => _VFSScreenState();
}

class _VFSScreenState extends State<VFSScreen> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final List<TerminalEntry> entries = [];

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  TerminalEntry parseCommand(String command) {
    Shell shell = Shell();
    try {
      return TerminalEntry(text: shell.execute(textEditingController.text).toString(), type: TerminalEntryType.output);
    } on CommandParseException catch (e) {
      return TerminalEntry(text: "Error: ${e.message}", type: TerminalEntryType.error);
    } on ExitCommandException {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Expanded(
                child: Container(
                  color: Colors.black12,
                  child: ListView.builder(
                    itemBuilder: (context, id) => TerminalEntryWidget(entry: entries[id]),
                    itemCount: entries.length,
                    controller: scrollController,
                  ),
                ),
              ),

              TextField(
                decoration: InputDecoration(label: Text("Type a command:")),
                controller: textEditingController,
                onSubmitted: (String command) {
                  setState(() {
                    entries.add(TerminalEntry(text: command, type: TerminalEntryType.command));
                    entries.add(parseCommand(command));
                    textEditingController.clear();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollController.jumpTo(scrollController.position.maxScrollExtent);
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

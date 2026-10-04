import 'package:flutter/material.dart';
import 'package:mirea_emulator/cmd_parser.dart';

enum TerminalEntryType { command, output, error }

class TerminalEntry {
  final String text;
  final TerminalEntryType type;
  TerminalEntry({required this.text, required this.type});
}

class TerminalEntryWidget extends StatelessWidget {
  final TerminalEntry entry;
  const TerminalEntryWidget({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.all(4), child: Text(entry.text));
  }
}

class VFSScreen extends StatefulWidget {
  const VFSScreen({super.key});

  @override
  State<VFSScreen> createState() => _VFSScreenState();
}

class _VFSScreenState extends State<VFSScreen> {
  TextEditingController controller = TextEditingController();
  final List<TerminalEntry> entries = [];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                  ),
                ),
              ),

              TextField(
                controller: controller,
                onSubmitted: (String command) {
                  setState(() {
                    entries.add(TerminalEntry(text: command, type: TerminalEntryType.command));
                    entries.add(
                      TerminalEntry(text: CmdParser.parse(command).toString(), type: TerminalEntryType.output),
                    );
                    controller.clear();
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

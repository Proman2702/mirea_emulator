import 'package:flutter/material.dart';
import 'package:mirea_emulator/terminal/models/terminal_entry.dart';

class TerminalEntryWidget extends StatelessWidget {
  final TerminalEntry entry;
  const TerminalEntryWidget({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: switch (entry.type) {
          TerminalEntryType.command => Colors.blue,
          TerminalEntryType.output => Colors.green,
          TerminalEntryType.error => Colors.red,
        },
      ),
      child: Text(entry.text),
    );
  }
}  
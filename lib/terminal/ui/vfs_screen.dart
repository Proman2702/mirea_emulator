import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mirea_emulator/terminal/cubit/terminal_cubit.dart';
import 'package:mirea_emulator/terminal/cubit/terminal_state.dart';
import 'package:mirea_emulator/terminal/ui/terminal_entry_widget.dart';

class VFSScreen extends StatefulWidget {
  const VFSScreen({super.key});

  @override
  State<VFSScreen> createState() => _VFSScreenState();
}

class _VFSScreenState extends State<VFSScreen> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: BlocBuilder<TerminalCubit, TerminalState>(
                  builder: (context, state) {
                    return ListView.builder(
                      itemBuilder: (context, id) => TerminalEntryWidget(entry: state.entries[id]),
                      itemCount: state.entries.length,
                      controller: scrollController,
                    );
                  },
                ),
              ),
            ),

            TextField(
              decoration: InputDecoration(label: Text("Type a command:")),
              controller: textEditingController,
              onSubmitted: (String command) {
                context.read<TerminalCubit>().executeCommand(command);
                textEditingController.clear();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollController.jumpTo(scrollController.position.maxScrollExtent);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mirea_emulator/exceptions.dart';
import 'package:mirea_emulator/shell/cmd_parser.dart';
import 'package:mirea_emulator/shell/shell.dart';
import 'package:mirea_emulator/terminal/cubit/terminal_cubit.dart';
import 'package:mirea_emulator/terminal/models/terminal_entry.dart';
import 'package:mirea_emulator/vfs/vfs.dart';
import 'package:mirea_emulator/vfs/vfs_object.dart';

void main() {
  test('parser reads quoted arguments and reports an unclosed quote', () {
    final parser = CmdParser();

    final command = parser.parse('chown "new owner" "folder1/file3.txt"');
    expect(command.command, 'chown');
    expect(command.args, ['new owner', 'folder1/file3.txt']);
    expect(
      () => parser.parse('cd "folder1'),
      throwsA(isA<CommandParseException>()),
    );
  });

  test('VFS loads files and nested directories from ZIP', () {
    final vfs = Vfs.fromZip('custom/vfs.zip');

    expect(Shell(Vfs()).execute('ls'), isEmpty);
    expect(vfs.getObject('/file1.txt').type, VfsObjectType.file);
    expect(vfs.getObject('/folder1/folder3').type, VfsObjectType.directory);
    expect(
      vfs.getObject('/folder1/folder3/file5.txt').type,
      VfsObjectType.file,
    );
    expect(() => vfs.getObject('/missing'), throwsA(isA<VfsException>()));
  });

  test('ls and cd work with relative and absolute paths', () {
    final shell = Shell(Vfs.fromZip('custom/vfs.zip'));

    expect(shell.execute('ls'), contains('folder1/'));
    expect(shell.execute('cd folder1/folder3'), '/folder1/folder3');
    expect(shell.execute('ls'), contains('file5.txt'));
    expect(shell.execute('cd ..'), '/folder1');
    expect(shell.execute('cd /'), '/');
    expect(
      () => shell.execute('cd file1.txt'),
      throwsA(isA<CommandParseException>()),
    );
  });

  test('rm deletes a file and a directory in memory', () {
    final vfs = Vfs.fromZip('custom/vfs.zip');
    final shell = Shell(vfs);

    expect(shell.execute('rm file1.txt'), 'Removed file1.txt');
    expect(() => vfs.getObject('/file1.txt'), throwsA(isA<VfsException>()));
    expect(shell.execute('cd folder1/folder3'), '/folder1/folder3');
    expect(shell.execute('rm /folder1/folder3'), 'Removed /folder1/folder3');
    expect(shell.currentPath, ['folder1']);
    expect(shell.execute('ls'), contains('file3.txt'));
    expect(
      () => vfs.getObject('/folder1/folder3/file5.txt'),
      throwsA(isA<VfsException>()),
    );
    expect(
      Vfs.fromZip('custom/vfs.zip').getObject('/file1.txt').type,
      VfsObjectType.file,
    );
    expect(() => shell.execute('rm /'), throwsA(isA<VfsException>()));
  });

  test('chown changes the owner shown by ls', () {
    final shell = Shell(Vfs.fromZip('custom/vfs.zip'));

    expect(
      shell.execute('chown student file1.txt'),
      'Owner of file1.txt changed to student',
    );
    expect(shell.execute('ls'), contains('file1.txt    student'));
  });

  test('history, uptime and command errors work', () {
    final shell = Shell(Vfs.fromZip('custom/vfs.zip'));

    expect(shell.execute('uptime'), contains('seconds'));
    expect(
      () => shell.execute('ls extra'),
      throwsA(isA<CommandParseException>()),
    );
    expect(shell.execute('history').split('\n'), [
      'uptime',
      'ls extra',
      'history',
    ]);
    expect(() => shell.execute('exit'), throwsA(isA<ExitCommandException>()));
  });

  test('startup script records commands, outputs and errors', () async {
    final terminal = TerminalCubit(
      Shell(Vfs.fromZip('custom/vfs.zip')),
      scriptPath: 'custom/script.txt',
    );

    terminal.executeScript();

    expect(terminal.state.entries.first.text, 'ls');
    expect(
      terminal.state.entries.any(
        (entry) => entry.type == TerminalEntryType.output,
      ),
      isTrue,
    );
    expect(
      terminal.state.entries.any(
        (entry) => entry.type == TerminalEntryType.error,
      ),
      isTrue,
    );
    await terminal.close();
  });
}

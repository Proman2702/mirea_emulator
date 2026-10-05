import 'dart:io';
import 'package:archive/archive.dart';
import 'package:mirea_emulator/exceptions.dart';

import 'package:mirea_emulator/vfs/vfs_object.dart';

class Vfs {
  final VfsObject root = VfsObject.directory(name: "/");

  Vfs();

  VfsObject getObject(String path) {
    final directory = path.split("/").where((part) => part.isNotEmpty).toList();
    VfsObject current = root;
    for (int i = 0; i < directory.length; i++) {
      if (current.type == VfsObjectType.file) {
        throw VfsException(message: "File is not a directory");
      }

      if (!current.children!.containsKey(directory[i])) {
        throw VfsException(message: "No such file or directory");
      }

      current = current.children![directory[i]]!;
    }

    return current;
  }

  factory Vfs.fromZip(String path) {
    final bytes = File(path).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    final vfs = Vfs();

    for (final file in archive) {
      final directory = file.name.split("/").where((part) => part.isNotEmpty).toList();
      VfsObject current = vfs.root;
      for (int i = 0; i < directory.length; i++) {
        if (i != directory.length - 1) {
          if (!current.children!.containsKey(directory[i])) {
            current.children![directory[i]] = VfsObject.directory(name: directory[i]);
          }

          current = current.children![directory[i]]!;
        } else {
          if (file.isDirectory) {
            current.children![directory[i]] = VfsObject.directory(name: directory[i]);
          } else {
            current.children![directory[i]] = VfsObject.file(data: file.readBytes(), name: directory[i]);
          }
        }
      }
    }

    return vfs;
  }
}

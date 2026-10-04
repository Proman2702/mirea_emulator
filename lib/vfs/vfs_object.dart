import 'dart:typed_data';

enum VfsObjectType { file, directory }

class VfsObject {
  final Uint8List? data;
  final String name;
  String owner;
  final Map<String, VfsObject>? children;
  final VfsObjectType type;

  VfsObject.file({required this.name, required this.data, this.owner = "root"})
    : type = VfsObjectType.file,
      children = null;

  VfsObject.directory({required this.name, this.owner = "root"})
    : type = VfsObjectType.directory,
      data = null,
      children = {};
}

import 'package:hive/hive.dart';

part 'folder.g.dart';

@HiveType(typeId: 0)
class Folder extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int> subFolderKeys;

  @HiveField(2)
  List<int> taskKeys;

  Folder({
    required this.name,
    this.subFolderKeys = const [],
    this.taskKeys = const [],
  });

  Folder copyWith({
    String? name,
    List<int>? subFolderKeys,
    List<int>? taskKeys,
  }) {
    return Folder(
      name: name ?? this.name,
      subFolderKeys: subFolderKeys ?? this.subFolderKeys,
      taskKeys: taskKeys ?? this.taskKeys,
    );
  }
}

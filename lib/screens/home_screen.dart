import 'package:flutter/material.dart';
import '../const/Colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/folder.dart';
import 'folder_screen.dart';

class HomeScreen extends StatelessWidget {
  final Box<Folder> folderBox = Hive.box<Folder>('folders');

  void _createFolder(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Folder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Folder Name',
                      labelStyle: TextStyle(color: AppColors.placeholderText),
                      prefixIcon: Icon(Icons.folder, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.placeholderText),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_nameController.text.isNotEmpty) {
                            final folder = Folder(name: _nameController.text);
                            folderBox.add(folder);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Create',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _deleteFolder(int key) async {
    final folder = folderBox.get(key);
    if (folder != null) {
      for (final subKey in folder.subFolderKeys) {
        await _deleteFolder(subKey);
      }
      await folderBox.delete(key);
    }
  }

  // Recursive function to count all items in folder hierarchy
  int _countItems(Folder folder) {
    int count = folder.taskKeys.length;
    for (final subKey in folder.subFolderKeys) {
      final subFolder = folderBox.get(subKey);
      if (subFolder != null) {
        count += _countItems(subFolder);
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Folders',
          style: TextStyle(color: AppColors.secondary),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
      body: ValueListenableBuilder(
        valueListenable: folderBox.listenable(),
        builder: (context, Box<Folder> box, _) {
          // Get all root folders (those not in any other folder's subFolderKeys)
          final rootFolders =
              box.values.where((folder) {
                return !box.values.any(
                  (f) => f.subFolderKeys.contains(folder.key),
                );
              }).toList();

          if (rootFolders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: AppColors.placeholderIcon,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No folders yet!',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.placeholderText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create a new folder',
                    style: TextStyle(
                      color: AppColors.placeholderIcon,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: rootFolders.length,
              itemBuilder: (context, index) {
                final folder = rootFolders[index];
                final itemCount = _countItems(folder);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FolderScreen(folderKey: folder.key),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 8,
                            top: 8,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.placeholderIcon,
                              ),
                              onPressed: () => _deleteFolder(folder.key),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.folder,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  folder.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  '$itemCount items',
                                  style: TextStyle(
                                    color: AppColors.placeholderText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.secondary,
        heroTag: 'createFolder',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _createFolder(context),
        child: const Icon(Icons.create_new_folder, size: 28),
      ),
    );
  }
}

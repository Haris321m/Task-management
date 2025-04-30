import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/folder.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';
import '../const/colors.dart';

class FolderScreen extends StatefulWidget {
  final int folderKey;
  const FolderScreen({required this.folderKey, Key? key}) : super(key: key);

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen>
    with SingleTickerProviderStateMixin {
  final folderBox = Hive.box<Folder>('folders');
  final taskBox = Hive.box<Task>('tasks');
  late AnimationController _fabController;
  bool _isFabOpen = false;

  Folder get folder => folderBox.get(widget.folderKey)!;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    if (_isFabOpen) {
      _fabController.reverse();
    } else {
      _fabController.forward();
    }
    _isFabOpen = !_isFabOpen;
  }

  void _createSubFolder() async {
    final TextEditingController _nameController = TextEditingController();

    await showDialog(
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
                        onPressed: () async {
                          if (_nameController.text.isEmpty) return;

                          final subFolder = Folder(name: _nameController.text);
                          final subFolderKey = await folderBox.add(subFolder);

                          final parentFolder = folderBox.get(widget.folderKey)!;
                          final updatedSubFolders = List<int>.from(
                            parentFolder.subFolderKeys,
                          )..add(subFolderKey);

                          await folderBox.put(
                            widget.folderKey,
                            parentFolder.copyWith(
                              subFolderKeys: updatedSubFolders,
                            ),
                          );

                          setState(() {});
                          Navigator.pop(context);
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

  void _createTask() async {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();

    await showDialog(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: AppColors.placeholderText),
                      prefixIcon: Icon(Icons.title, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: AppColors.placeholderText),
                      alignLabelWithHint: true,
                      prefixIcon: Icon(
                        Icons.description,
                        color: AppColors.primary,
                      ),
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
                        onPressed: () async {
                          if (_titleController.text.isEmpty) return;

                          final task = Task(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            createdAt: DateTime.now(),
                          );

                          final taskKey = await taskBox.add(task);
                          final currentFolder =
                              folderBox.get(widget.folderKey)!;
                          final updatedTasks = List<int>.from(
                            currentFolder.taskKeys,
                          )..add(taskKey);

                          await folderBox.put(
                            widget.folderKey,
                            currentFolder.copyWith(taskKeys: updatedTasks),
                          );

                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Create Task',
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

  Future<void> _deleteSubfolder(int key) async {
    final subFolder = folderBox.get(key);
    if (subFolder != null) {
      // Delete all tasks in this subfolder
      for (final taskKey in subFolder.taskKeys) {
        await taskBox.delete(taskKey);
      }

      // Recursively delete all subfolders
      for (final subKey in subFolder.subFolderKeys) {
        await _deleteSubfolder(subKey);
      }

      // Remove from parent folder's subFolderKeys
      final parentFolder = folderBox.get(widget.folderKey)!;
      final updatedSubFolders = List<int>.from(parentFolder.subFolderKeys)
        ..remove(key);

      await folderBox.put(
        widget.folderKey,
        parentFolder.copyWith(subFolderKeys: updatedSubFolders),
      );

      // Finally delete the subfolder itself
      await folderBox.delete(key);
      setState(() {});
    }
  }

  Future<void> _deleteTask(int key) async {
    await taskBox.delete(key);

    final currentFolder = folderBox.get(widget.folderKey)!;
    final updatedTasks = List<int>.from(currentFolder.taskKeys)..remove(key);

    await folderBox.put(
      widget.folderKey,
      currentFolder.copyWith(taskKeys: updatedTasks),
    );

    setState(() {});
  }

  Widget _buildFolderGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: folder.subFolderKeys.length,
        itemBuilder: (context, index) {
          final key = folder.subFolderKeys[index];
          final subFolder = folderBox.get(key);
          if (subFolder == null) return const SizedBox.shrink();

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FolderScreen(folderKey: key),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.red.shade400,
                            ),
                            onPressed: () => _deleteSubfolder(key),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.folder,
                              size: 42,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              subFolder.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              '${subFolder.taskKeys.length + subFolder.subFolderKeys.length} items',
                              style: TextStyle(
                                color: AppColors.placeholderText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    return ValueListenableBuilder(
      valueListenable: taskBox.listenable(),
      builder: (context, Box<Task> box, _) {
        // Filter tasks that still exist in the box
        final validTaskKeys =
            folder.taskKeys.where((key) => box.containsKey(key)).toList();

        // Update folder's taskKeys if needed
        if (validTaskKeys.length != folder.taskKeys.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            folderBox.put(
              widget.folderKey,
              folder.copyWith(taskKeys: validTaskKeys),
            );
          });
        }

        return AnimationLimiter(
          child: Column(
            children: [
              ...validTaskKeys.map((key) {
                final task = box.get(key);
                if (task == null) return const SizedBox.shrink();

                return AnimationConfiguration.staggeredList(
                  position: validTaskKeys.indexOf(key),
                  duration: const Duration(milliseconds: 500),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Dismissible(
                        key: Key(key.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.delete_forever,
                            color: Colors.red.shade600,
                          ),
                        ),
                        onDismissed: (_) => _deleteTask(key),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            subtitle:
                                task.description.isNotEmpty
                                    ? Text(
                                      task.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.placeholderText,
                                        fontSize: 14,
                                      ),
                                    )
                                    : null,
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.placeholderIcon,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => TaskDetailScreen(taskKey: key),
                                ),
                              ).then((_) {
                                setState(() {}); // Refresh after returning
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          folder.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 4,
        iconTheme: IconThemeData(color: AppColors.secondary),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, size: 26),
            onPressed: () {
              // Show folder info
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (folder.subFolderKeys.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Subfolders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            _buildFolderGrid(),
            if (folder.taskKeys.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _buildTaskList(),
            ],
            if (folder.subFolderKeys.isEmpty && folder.taskKeys.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.create_new_folder,
                      size: 100,
                      color: AppColors.placeholderIcon,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No items yet!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.placeholderText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button below to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.placeholderText.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabController,
              curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
            ),
            child: FloatingActionButton(
              heroTag: 'folder',
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              elevation: 4,
              child: Icon(Icons.create_new_folder, size: 28),
              onPressed: _createSubFolder,
            ),
          ),
          const SizedBox(height: 12),
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabController,
              curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
            ),
            child: FloatingActionButton(
              heroTag: 'task',
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
              elevation: 4,
              child: Icon(Icons.add_task, size: 28),
              onPressed: _createTask,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'main',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.secondary,
            elevation: 4,
            onPressed: _toggleFab,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _fabController,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

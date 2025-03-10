import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../main.dart'; 

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onDelete;
  final Function(bool) onToggleComplete; 

  const TaskCard({super.key, required this.task, this.onDelete, required this.onToggleComplete, });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ListTile(
        onTap: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        tileColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_box_outlined : Icons.check_box_outline_blank,
            color: Colors.black,
          ),
          onPressed: () => onToggleComplete(!task.isCompleted), // เปลี่ยนสถานะ
        ),
        title: ExpansionTile(
            tilePadding: EdgeInsets.all(0),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null, // Strikethrough effect
                  ),
                ),
                Text(
                  task.tag,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft, // จัดเนื้อหาให้อยู่ด้านซ้าย
                  child: Text(
                    task.note,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            iconColor: Colors.black),
        trailing: PopupMenuButton<String>(
          color: Colors.white,
          icon: Icon(Icons.more_horiz, color: Colors.black),
          onSelected: (String value) {
            if (value == 'delete') {
              // Handle delete action
              onDelete?.call();
              print("Task Deleted");
            } else if (value == 'edit') {
              _showEditTaskDialog(context);
              print('edit');
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.mode_edit_outline_rounded, color: Colors.black),
                  // SizedBox(width: 10),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  // SizedBox(width: 10),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context) {
    final titleController = TextEditingController(text: task.title);
    final noteController = TextEditingController(text: task.note);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Task Title')),
              TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: noteController,
                  decoration: InputDecoration(labelText: 'Task Note')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    noteController.text.isNotEmpty) {
                  context.read<MyAppState>().editTask(
                        task,
                        titleController.text,
                        noteController.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

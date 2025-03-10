import 'package:hive/hive.dart';
part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String title;
  @HiveField(1)
  String note;
  @HiveField(2)
  final String tag;
  @HiveField(3)
  bool isCompleted;

  Task({
    required this.title,
    required this.note,
    this.isCompleted = false,
    required this.tag,
  });

  static List<Task> todoList(){
    return [
        Task(title: 'todo 1', note: 'something', tag: 'Category1'),
        Task(title: 'todo 2', note: 'something special',tag: 'Category1', isCompleted: true ),
        Task(title: 'todo 3', note: 'hellow----------------------', tag: 'Category2'),
    ];
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'isCompleted': isCompleted ? 1 : 0, // Store as 1 (true) or 0 (false)
      'tag': tag ?? '',
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      note: map['note'],
      isCompleted: map['isCompleted'] == 1, // Convert from 1 or 0
      tag: map['tag'] ?? '',
    );
  }
}
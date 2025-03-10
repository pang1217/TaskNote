import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:task_note/widgets/task_card.dart';
import './models/task.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('task');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Task Manager',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final _taskBox = Hive.box('task');
  List<Task> taskList = [];
  List<Task> get tasks => taskList;

  void fetchTasks() {
    final taskMapList = _taskBox.values.toList();
    taskList = taskMapList.map((taskMap) {
      return Task.fromMap(Map<String, dynamic>.from(taskMap));
    }).toList();
    notifyListeners();
  }

  void addTask(String title, String note, String tag) {
    final task = Task(title: title, note: note, tag: tag.isEmpty ? 'Etc' : tag);
    _taskBox.add(task.toMap());
    fetchTasks();
  }

  void deleteTask(int index) {
    _taskBox.deleteAt(index); // ลบ task ออกจาก Hive
    fetchTasks(); // โหลด task ใหม่เพื่ออัปเดต UI
    notifyListeners();
  }

  void toggleTaskCompletion(int index, bool isCompleted) {
    tasks[index].isCompleted = isCompleted;
    notifyListeners();
  }

  void editTask(Task task, String newTitle, String newNote) {
    print('Editing task: ${task.title}, ${task.note}');
    print(newNote);
    var taskListFromHive = _taskBox.values.toList().map((taskMap) {
      return Task.fromMap(Map<String, dynamic>.from(taskMap));
    }).toList();
    int index = taskListFromHive.indexOf(task);
    print(index);
    if (index != -1) {
      Task updatedTask = Task(
        title: newTitle,
        note: newNote,
        tag: task.tag,
        isCompleted: task.isCompleted,
      );
      print('Task updated');
      _taskBox.putAt(index, updatedTask.toMap()); // Update Hive
      taskList[index] = updatedTask; // Ensure taskList is updated
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchQuery = ""; // 🔍 Stores the search query

  @override
  void initState() {
    super.initState();
    context.read<MyAppState>().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const App_bar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan[200]),
              child: Text('Categories',
                  style: TextStyle(color: Colors.black, fontSize: 24)),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            SearchBox(onSearch: (query) {
              setState(() {
                searchQuery = query; // 🔍 Update search query
              });
            }),
            Expanded(
              child: Consumer<MyAppState>(
                builder: (context, appState, child) {
                  var filteredTasks = appState.tasks
                      .where((task) =>
                          task.title
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          task.note
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          task.tag
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                      .toList(); // 🔍 Filter tasks

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: filteredTasks[index],
                        onDelete: () {
                          appState.deleteTask(index);
                        },
                        onToggleComplete: (isCompleted) {
                          appState.toggleTaskCompletion(index, isCompleted);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan[100],
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  style: TextStyle(color: Colors.black),
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Task Title')),
              TextField(
                  style: TextStyle(color: Colors.black),
                  minLines: 1,
                  maxLines: 5,
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Task Note',
                  )),
              TextField(
                  style: TextStyle(color: Colors.black),
                  controller: tagController,
                  decoration: InputDecoration(labelText: 'Task Tag')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.black))),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    noteController.text.isNotEmpty) {
                  context.read<MyAppState>().addTask(
                        titleController.text,
                        noteController.text,
                        tagController.text,
                      );
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Add Task',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget SearchBox({required Function(String) onSearch}) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: TextField(
      onChanged: onSearch, // 🔍 Calls onSearch when text changes
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        prefixIcon: Icon(Icons.search, color: Colors.black, size: 30),
        border: InputBorder.none,
        hintText: 'Search',
      ),
    ),
  );
}

class App_bar extends StatelessWidget implements PreferredSizeWidget {
  const App_bar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.cyan[200],
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.black, size: 30),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Text('Todo List',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

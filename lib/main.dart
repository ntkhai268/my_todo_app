import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'To-Do App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Task> tasks = [];
  List<Task> get visibleTasks =>
      (isSearchClicked && searchText.isNotEmpty)
          ? tasks.where((t) => t._title.toLowerCase().contains(searchText.toLowerCase())).toList()
          : tasks;

  @override
  void initState(){
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? jsonString = prefs.getString('tasks');
      if (jsonString != null) {
        List<dynamic> decoded = jsonDecode(jsonString);
        tasks = decoded.map((task) => Task.fromJson(task)).toList();
      }
    });
  }

  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tasks.map((task) => task.toJson()).toList();
    String jsonString = jsonEncode(jsonList);
    await prefs.setString('tasks',jsonString);
  }

  void _createTask() {
    setState(() {
      tasks.add(Task("Task_${tasks.length + 1}", false));
    });
    _savePreference();
  }

  bool isSearchClicked = false;
  String searchText = '';
  final TextEditingController searchController = TextEditingController();

  void onSearchChanged(String value) {
    setState(() {
      searchText = value;
    });
  }

  @override
  void dispose() {
    searchController.dispose(); // giải phóng khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final activeTasks = visibleTasks.where((t) => !t._isDone).toList();
    final doneTasks   = visibleTasks.where((t) =>  t._isDone).toList();

    final hasDivider = doneTasks.isNotEmpty;
    final itemCountt = activeTasks.length + (hasDivider ? 1 : 0) + doneTasks.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: isSearchClicked ?
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  hintText: 'Search...'
                ),
              ),
            )
        : Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value){
              if (value == "done"){
                for (var task in tasks){
                  setState(() {
                    task._isDone = true;
                  });
                }
              }
              else{
                for (var task in tasks){
                  setState(() {
                    task._isDone = false;
                  });
                }
              }
              _savePreference();
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: "done",
                  child: Text("Mark all as done"),
                ),
                PopupMenuItem<String>(
                  value: "undone",
                  child: Text("Uncheck all"),
                ),
              ];
            },
          ),
          IconButton(onPressed: () {
            setState(() {
              isSearchClicked = !isSearchClicked;
              print(isSearchClicked);
              if(!isSearchClicked){
                searchController.clear();
              }

            });
          }, icon: Icon(isSearchClicked ? Icons.close : Icons.search)),
        ],

      ),
      body: ListView.builder(
          itemCount: itemCountt,
          itemBuilder: (context, index){
            Task task;
            if (index <  activeTasks.length){
              task = activeTasks[index];
            } else if (hasDivider && index == activeTasks.length){
              return Divider();
            } else {
              task = doneTasks[index - activeTasks.length - (hasDivider ? 1 : 0)];
            }

            return Dismissible(
                background: Container(color: Colors.red),
                key: ValueKey(task._title),
                onDismissed: (DismissDirection direction) {
                  final removed = task;
                  setState(() {
                    tasks.remove(task);
                  });
                  _savePreference();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Đã xóa: ${removed._title}"),
                      action: SnackBarAction(
                        label: 'Hoàn tác',
                        onPressed: () {
                          setState(() {
                            tasks.insert(index, removed);
                          });
                          _savePreference();
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                    title: Text(
                        task._title,
                        style: TextStyle(
                            decoration: task._isDone ? TextDecoration.lineThrough : TextDecoration.none
                        )
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // để Row không chiếm hết ngang màn hình
                      children: [
                        Checkbox(
                          value: task._isDone,
                          onChanged: (val) {
                            setState(() {
                              task._isDone = val!;
                            });
                            _savePreference();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final controller = TextEditingController(text: visibleTasks[index]._title);
                            final newTitle = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("My title"),
                                  content: TextField(
                                    controller: controller,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      hintText: "Nhập tiêu đề mới",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text("Hủy"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, controller.text);
                                      },
                                      child: Text("Lưu"),

                                    )
                                  ],
                                );
                              },
                            );
                            setState(() {
                              tasks[index]._title = newTitle!;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              tasks.remove(task);
                            });
                            _savePreference();
                          },
                        ),
                      ],
                    )
                )
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask, // The action to perform when the button is pressed
        tooltip: 'Increment Counter', // Text displayed on long-press
        child: const Icon(Icons.add), // The icon displayed inside the button
      ),
    );
  }
}

class Task {
  String _title = "";
  bool _isDone = false;
  
  Task(this._title, this._isDone);

  Map<String, dynamic> toJson(){
    return {
      'title': _title,
      'isDone': _isDone,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json){
    return Task(json['title'],json['isDone']);
  }

  void editTitle(String newTitle){
    _title = newTitle;
  }


}

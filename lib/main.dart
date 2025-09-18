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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index){
            final task = tasks[index];
            return Dismissible(
                background: Container(color: Colors.red),
                key: ValueKey(task._title),
                onDismissed: (DismissDirection direction) {
                  final removed = task;
                  setState(() {
                    tasks.removeAt(index);
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
                            final controller = TextEditingController(text: tasks[index]._title);
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
                              tasks.removeAt(index);
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

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
  int _counter = 0;

  // @override
  // void initState(){
  //   super.initState();
  // }
  //
  // Future<void> _loadPreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     tasks = prefs.getStringList(key)
  //
  //   })
  // }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _createTask() {
    setState(() {
      tasks.add(Task("Task_${tasks.length + 1}", false));
    });
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
            return ListTile(
              title: Text(task._title),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    tasks.removeAt(index);
                  });
                }
            ),
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
}

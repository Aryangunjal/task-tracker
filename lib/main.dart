import 'package:flutter/material.dart';

void main() {
  runApp(TaskTrackerApp());
}

class TaskTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
      home: TaskTrackerHomePage(),
    );
  }
}

class Task {
  String name;
  DateTime dueDate;

  Task(this.name, this.dueDate);
}

class TaskTrackerHomePage extends StatefulWidget {
  @override
  _TaskTrackerHomePageState createState() => _TaskTrackerHomePageState();
}

class _TaskTrackerHomePageState extends State<TaskTrackerHomePage> {
  List<Task> _tasks = [];

  void _addTask(String task, DateTime dueDate) {
    setState(() {
      _tasks.add(Task(task, dueDate));
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index] = Task(_tasks[index].name.startsWith('✓ ') ? _tasks[index].name.substring(2) : '✓ ' + _tasks[index].name, _tasks[index].dueDate);
    });
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _completeAllTasks(BuildContext context) {
    setState(() {
      for (int i = 0; i < _tasks.length; i++) {
        _tasks[i] = Task('✓ ' + _tasks[i].name, _tasks[i].dueDate);
      }
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('All tasks completed'),
          content: Text('Congratulations! You have completed all tasks.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _editTask(int index) {
    Task task = _tasks[index];
    TextEditingController nameController = TextEditingController(text: task.name);
    DateTime selectedDate = task.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Enter task'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final newDate = await showDatePicker(
                    context: context,
                    initialDate: task.dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (newDate != null) {
                    setState(() {
                      selectedDate = newDate;
                    });
                  }
                },
                child: Text('Select Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _tasks[index] = Task(nameController.text, selectedDate);
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _sortTasks(bool ascending) {
    setState(() {
      _tasks.sort((a, b) => ascending ? a.dueDate.compareTo(b.dueDate) : b.dueDate.compareTo(a.dueDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task Tracker',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Sort Tasks'),
                    content: Text('Sort tasks by:'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          _sortTasks(true);
                          Navigator.of(context).pop();
                        },
                        child: Text('Ascending'),
                      ),
                      TextButton(
                        onPressed: () {
                          _sortTasks(false);
                          Navigator.of(context).pop();
                        },
                        child: Text('Descending'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_tasks[index].name),
            onDismissed: (direction) {
              _deleteTask(index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(
                  _tasks[index].name,
                  style: TextStyle(
                    decoration: _tasks[index].name.startsWith('✓ ') ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                subtitle: Text('Due: ${_tasks[index].dueDate.toString()}'),
                onTap: () => _toggleTaskCompletion(index),
                onLongPress: () => _editTask(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _promptUserForTask(context);
            },
            tooltip: 'Add Task',
            child: Icon(Icons.add),
            heroTag: null,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _completeAllTasks(context);
            },
            tooltip: 'Mark All Done',
            child: Icon(Icons.done_all),
            heroTag: null,
          ),
        ],
      ),
    );
  }

  Future<void> _promptUserForTask(BuildContext context) async {
    TextEditingController textController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(hintText: 'Enter task'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    _addTask(textController.text, selectedDate);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Select Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  _addTask(textController.text, DateTime.now());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
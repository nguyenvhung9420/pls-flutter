import 'package:flutter/material.dart';
import 'package:pls_flutter/presentation/home/home_screen.dart';
import 'package:pls_flutter/presentation/models/pls_task_view.dart';

class TaskChooserScreen extends StatefulWidget {
  final Function(String taskSelected) onTaskSelected;
  const TaskChooserScreen({super.key, required this.onTaskSelected});

  @override
  State<TaskChooserScreen> createState() => _TaskChooserScreenState();
}

class TaskGroup {
  final String name;
  final List<PlsTask> tasks;

  TaskGroup(this.name, this.tasks);
}

class _TaskChooserScreenState extends State<TaskChooserScreen> {
  final List<TaskGroup> taskGroups = [
    // TaskGroup('Group 1', ['Task 1.1', 'Task 1.2', 'Task 1.3', 'Task 1.4']),
    // TaskGroup('Group 2', ['Task 2.1', 'Task 2.2', 'Task 2.3']),
  ];

  final Set<String> selectedTasks = {};

  void _onTaskSelected(String groupName, String task) {
    setState(() {
      TaskGroup group = taskGroups.firstWhere((g) => g.name == groupName);
      // int taskIndex = group.tasks.indexOf(task);
      // selectedTasks.add(group.tasks[taskIndex]);
    });
  }

  void _onTaskDeselected(String groupName, String task) {
    setState(() {
      TaskGroup group = taskGroups.firstWhere((g) => g.name == groupName);
      // int taskIndex = group.tasks.indexOf(task);
      // selectedTasks.remove(group.tasks[taskIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Chooser'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onTaskSelected(selectedTasks.join(', '));
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: taskGroups.length,
        itemBuilder: (context, index) {
          final group = taskGroups[index];
          return ExpansionTile(
            title: Text(group.name),
            children: group.tasks.map((task) {
              return CheckboxListTile(
                title: Text("Hung"),
                value: selectedTasks.contains(task),
                onChanged: (bool? value) {
                  if (value == null) return;
                  if (value == true) {
                    _onTaskSelected(group.name, "hung");
                    return;
                  }
                  _onTaskDeselected(group.name, "hung");
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

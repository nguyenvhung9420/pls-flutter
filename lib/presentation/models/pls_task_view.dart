class PlsTask {
  String taskCode;
  String name;
  String description;
  PlsTask(
      {required this.taskCode, required this.name, required this.description});
}

class TaskGroup {
  final String name;
  final List<PlsTask> tasks;

  TaskGroup(this.name, this.tasks);
}

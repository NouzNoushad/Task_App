import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_rishal/models/add_task_model.dart';
import 'package:todo_rishal/services/add_task_service.dart';

class TaskHomeProvider extends ChangeNotifier {
  AddTaskService addTaskService = AddTaskService();
  int selectedIndex = 0;
  bool switchState = false;

  String changeTaskState(String taskState) {
    if (taskState == 'upcoming') return 'past';
    if (taskState == 'past') return 'expired';
    if (taskState == 'expired') return '';
    return '';
  }

  onChangedSwitchState(int index, bool value,
      QueryDocumentSnapshot<Map<String, dynamic>> task, String taskState) {
    print('///// index $index, $value');

    selectedIndex = index;
    switchState = value;
    var newTaskState = changeTaskState(taskState);
    print('//// taskStateON.: $newTaskState');
    Map<String, dynamic> taskMap = task.data();
    AddTaskModel taskModel = addTaskModelFromJson(taskMap);
    addTaskService.updateTask(taskModel, newTaskState);

    notifyListeners();
  }
}

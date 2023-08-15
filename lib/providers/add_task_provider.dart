import 'package:flutter/material.dart';
import 'package:todo_rishal/core/constants.dart';
import 'package:todo_rishal/services/add_task_service.dart';

class AddTaskProvider extends ChangeNotifier {
  TextEditingController titleController = TextEditingController();
  AddTaskService addTaskService = AddTaskService();
  bool isTenMinutesChecked = false;
  bool isOneDayBeforeChecked = false;
  DateTime startInitialDate = DateTime.now();
  DateTime expiredInitialDate = DateTime.now();
  TaskState initialTaskState = TaskState.upcoming;

  selectStartDate(DateTime value) {
    startInitialDate = value;
    notifyListeners();
  }

  selectExpiredDate(DateTime value) {
    expiredInitialDate = value;
    notifyListeners();
  }

  onCheckedTenMinutes(value) {
    isTenMinutesChecked = value;
    notifyListeners();
  }

  onCheckedOneDayBefore(value) {
    isOneDayBeforeChecked = value;
    notifyListeners();
  }

  String checkTaskState(TaskState state) {
    String taskState = switch (state) {
      TaskState.upcoming => "upcoming",
      TaskState.renewed => "renewed",
      TaskState.expired => "expired"
    };
    return taskState;
  }

  addTask() async {
    String title = titleController.text.trim();
    DateTime startDate = startInitialDate;
    DateTime expiredDate = expiredInitialDate;
    String tenMinutes = isTenMinutesChecked ? "true" : "false";
    String oneDayBefore = isOneDayBeforeChecked ? "true" : "false";
    String taskState = checkTaskState(initialTaskState);

    print('///////// title : $title');
    print('///////// startDate : $startDate');
    print('///////// expiredDate : $expiredDate');
    print('///////// tenMinutes : $tenMinutes');
    print('///////// oneDay : $oneDayBefore');
    print('///////// taskState : $taskState');

    await addTaskService.addTask(
        title: title,
        startDate: startDate,
        expiredDate: expiredDate,
        tenMinutes: tenMinutes,
        oneDayBefore: oneDayBefore,
        taskState: taskState);

    titleController.text = '';
    startInitialDate = DateTime.now();
    expiredInitialDate = DateTime.now();
    isTenMinutesChecked = false;
    isOneDayBeforeChecked = false;
  }
}

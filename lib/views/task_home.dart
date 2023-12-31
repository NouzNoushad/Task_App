import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_rishal/core/constants.dart';
import 'package:todo_rishal/providers/task_home_provider.dart';
import 'package:todo_rishal/views/add_task.dart';

class TaskHome extends StatefulWidget {
  const TaskHome({super.key});

  @override
  State<TaskHome> createState() => _TaskHomeState();
}

class _TaskHomeState extends State<TaskHome>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late TaskHomeProvider taskHomeProvider;
  List taskList = [];
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    taskHomeProvider = Provider.of<TaskHomeProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.purple.shade100,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const AddTask()));
        },
        backgroundColor: Colors.purple.shade100,
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        TabBar(
          controller: tabController,
          labelColor: Colors.purple,
          unselectedLabelColor: Colors.purple.shade200,
          indicatorColor: Colors.purple,
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: const EdgeInsets.symmetric(vertical: 8),
          tabs: const [Text('Upcoming'), Text('Renewed'), Text('Expired')],
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            taskTabContainer('upcoming', TaskState.upcoming),
            taskTabContainer('renewed', TaskState.renewed),
            taskTabContainer('upcoming', TaskState.expired)
          ]),
        ),
      ]),
    );
  }

  Widget taskTabContainer(String state, TaskState taskState) =>
      Consumer<TaskHomeProvider>(builder: (context, provider, child) {
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(taskDb)
                .where("task_state", isEqualTo: state)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                taskHomeProvider.checkTaskConditions(
                    snapshot.data!.docs, taskState);
                return ListView.builder(
                    itemCount: taskHomeProvider.taskList.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot<Map<String, dynamic>> task =
                          taskHomeProvider.taskList[index];
                      return SizedBox(
                        height: 80,
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      task['title'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Expired on: ${DateFormat.yMMMd().format(task['expired_date'].toDate())}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                taskState != TaskState.expired
                                    ? Switch(
                                        value: taskHomeProvider.selectedIndex ==
                                                index
                                            ? taskHomeProvider.switchState
                                            : false,
                                        onChanged: (value) {
                                          taskHomeProvider.onChangedSwitchState(
                                              index, value, task, state);
                                        })
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
      });
}

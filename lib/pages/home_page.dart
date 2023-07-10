import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracking_goals/utils/dailies.dart';
import 'package:tracking_goals/utils/dialog_box.dart';
import 'package:tracking_goals/utils/home_page_app_bar.dart';
import 'package:tracking_goals/utils/home_page_bottom_app_bar.dart';
import 'package:tracking_goals/utils/progress_card.dart';
import 'package:tracking_goals/utils/todo_tile.dart';
import 'package:tracking_goals/utils/edit_dailies_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  int dailiesId = 0;
  Dailies selectedDailiesToEdit =
      Dailies(taskName: '', isCompleted: false, isTop: true);
  bool isPressed = false;

  final taskNameController = TextEditingController();
  final taskDescriptionController = TextEditingController();

  Future<void> saveDailies() async {
    await DatabaseHelper.instance.addDailies(Dailies(
        taskName: taskNameController.text,
        taskDescription: taskDescriptionController.text,
        isCompleted: false,
        isTop: true));

    taskNameController.clear();
    taskDescriptionController.clear();

    setState(() {});

    Navigator.of(context).pop();
  }

  void deleteDailies(int index) {
    setState(() {});
  }

  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            taskNameController: taskNameController,
            taskDescriptionController: taskDescriptionController,
            onSave: saveDailies,
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  void openEditPage(Dailies dailies) {
    setState(() {
      selectedIndex = 1;
      selectedDailiesToEdit = dailies;
    });
  }

  Future<void> updateIsCompletedDailies(
      bool isCompleted, int id, bool isTop) async {
    if (isTop == true) {
      if (isCompleted == true) {
        await DatabaseHelper.instance
            .updateIsCompletedForTopDailies("true", id);
      }
      if (isCompleted == false) {
        await DatabaseHelper.instance
            .updateIsCompletedForTopDailies("false", id);
      }
    }

    if (isTop == false) {
      if (isCompleted == true) {
        await DatabaseHelper.instance.updateIsCompleted("true", id);
      }
      if (isCompleted == false) {
        await DatabaseHelper.instance.updateIsCompleted("false", id);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // List<Map> progress = [
    //   {"isCompleted": true, "noOfCompletedTasks": 2},
    //   {"isCompleted": false, "noOfCompletedTasks": 3},
    //   {"isCompleted": false, "noOfCompletedTasks": 5},
    //   {"isCompleted": true, "noOfCompletedTasks": 5},
    //   {"isCompleted": false, "noOfCompletedTasks": 1}
    // ];

    return Scaffold(
      appBar: HomePageAppBar(
        selectedIndex: selectedIndex,
        deleteFunction: () async {
          await DatabaseHelper.instance
              .removeTopDailies(selectedDailiesToEdit.id ?? 0);
          setState(() {
            selectedIndex = 0;
          });
        },
        backFunction: () {
          setState(() {
            selectedIndex = 0;
          });
        },
      ),
      body: <Widget>[
        SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(children: [
            SizedBox(
              height: 5,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(70, 0, 60, 0),
              child: Text(
                "Tasks",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
              alignment: Alignment.centerLeft,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: FutureBuilder<List<Dailies>>(
                  // future: DatabaseHelper.instance.getDailies(),
                  future: DatabaseHelper.instance.getAllDailies(),
                  // future: DatabaseHelper.instance.test(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Dailies>> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: Text(''));
                    }
                    if (snapshot.data!.isEmpty) {
                      return Center(
                          child: Container(
                        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Text(
                          "No tasks to finish",
                          style: TextStyle(fontSize: 22),
                        ),
                      ));
                    }
                    return ListView(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: snapshot.data!.map((dailies) {
                          return GestureDetector(
                            onTap: () {
                              openEditPage(dailies);
                            },
                            child: TodoTile(
                              callback: () {
                                setState(() {});
                              },
                              openEditPage: openEditPage,
                              id: dailies.id ?? 0,
                              taskName: dailies.taskName,
                              isCompleted: dailies.isCompleted,
                              taskDescription: dailies.taskDescription,
                              subDailies: dailies.subDailies,
                              isTop: dailies.isTop,
                            ),
                          );
                        }).toList());
                  }),
            ),
            SizedBox(
              height: 20,
            ),
          ]),
        ),
        EditDailiesBody(dailies: selectedDailiesToEdit)
      ][selectedIndex],
      floatingActionButton: [
        FloatingActionButton(
          onPressed: createNewTask,
          child: const Icon(Icons.add),
        ),
        TextButton(
          onPressed: () {
            updateIsCompletedDailies(!selectedDailiesToEdit.isCompleted,
                selectedDailiesToEdit.id ?? 0, selectedDailiesToEdit.isTop);
            setState(() {
              selectedDailiesToEdit.isCompleted =
                  !selectedDailiesToEdit.isCompleted;
            });
          },
          child: !selectedDailiesToEdit.isCompleted
              ? Text("Mark completed")
              : Text("Mark uncompleted"),
          style: ButtonStyle(
              shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.zero))),
        )
      ][selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: HomePageBottomAppBar(
        selectedIndex: selectedIndex,
        // function: () {
        //   final snackBar = SnackBar(
        //     backgroundColor: Colors.white,
        //     duration: Duration(days: 365),
        //     content: Container(
        //       height: 180,
        //       margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        //       child: ListView.separated(
        //           scrollDirection: Axis.horizontal,
        //           itemCount: progress.length,
        //           itemBuilder: (context, index) {
        //             return ProgressCard(
        //               isCompleted: progress[index]["isCompleted"],
        //               noOfCompletedTasks: progress[index]["noOfCompletedTasks"],
        //               noOfDay: index + 1,
        //             );
        //           },
        //           separatorBuilder: (context, index) => SizedBox(
        //                 width: 10,
        //               )),
        //     ),
        //   );

        //   if (!isPressed) {
        //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
        //   } else if (isPressed) {
        //     ScaffoldMessenger.of(context).removeCurrentSnackBar();
        //   }

        //   setState(() {
        //     isPressed = !isPressed;
        //     print(isPressed);
        //   });
        // },
      ),
    );
  }
}

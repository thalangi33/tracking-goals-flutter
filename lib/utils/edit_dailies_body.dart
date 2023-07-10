import 'package:flutter/material.dart';
import 'package:tracking_goals/utils/dailies.dart';

class EditDailiesBody extends StatefulWidget {
  const EditDailiesBody({super.key, required this.dailies});
  final Dailies dailies;

  @override
  State<EditDailiesBody> createState() => _EditDailiesBodyState();
}

class _EditDailiesBodyState extends State<EditDailiesBody> {
  bool isSubDailiesCreatedPressed = false;
  List subDailies = [];

  Future<Dailies> getCurrentDailies(int id) async {
    return await DatabaseHelper.instance.getSingleDailies(id);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addSubDailies(Dailies dailies) async {
      print("hello");
      await DatabaseHelper.instance.addSubDailies(dailies);
      setState(() {});
    }

    Future<void> editDailies(
        String taskName, String taskDescription, int id) async {
      await DatabaseHelper.instance
          .updateDailies(taskName, taskDescription, id);
    }

    Future<void> removeSubDailies(int subId, int topId) async {
      await DatabaseHelper.instance.removeSubDailies(subId, topId);
      setState(() {});
    }

    return FutureBuilder(
        future: getCurrentDailies(widget.dailies.id ?? 0),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final taskNameController =
                TextEditingController(text: snapshot.data!.taskName);
            final taskDescriptionController =
                TextEditingController(text: snapshot.data!.taskDescription);
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              // reverse: true,
              child: Column(children: [
                Container(
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {}
                      editDailies(
                          taskNameController.text,
                          taskDescriptionController.text,
                          snapshot.data!.id ?? 0);
                    },
                    child: TextFormField(
                      controller: taskNameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              onPressed: null, icon: Icon(Icons.library_books)),
                          Flexible(
                              child: Focus(
                            onFocusChange: (hasFocus) {
                              editDailies(
                                  taskNameController.text,
                                  taskDescriptionController.text,
                                  snapshot.data!.id ?? 0);
                            },
                            child: TextFormField(
                              controller: taskDescriptionController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: "Add description",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 20,
                                    color: Colors.black),
                              ),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  color: Colors.black),
                            ),
                          ))
                        ],
                      ),
                      snapshot.data!.isTop
                          ? GestureDetector(
                              onTap: snapshot.data!.subDailies?.length == 0
                                  ? () {
                                      addSubDailies(snapshot.data!);
                                      setState(() {});
                                      print("ds");
                                    }
                                  : null,
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: 0,
                                      left: 0,
                                      child: IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                              Icons.subdirectory_arrow_right))),
                                  Column(
                                    children: [
                                      snapshot.data!.subDailies != null
                                          ? ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: snapshot
                                                  .data!.subDailies.length,
                                              itemBuilder: (context, index) {
                                                return SubDailiesTile(
                                                  subDailies: snapshot
                                                      .data!.subDailies![index],
                                                  removeSubDailies: () {
                                                    removeSubDailies(
                                                        snapshot
                                                                .data!
                                                                .subDailies![
                                                                    index]
                                                                .id ??
                                                            0,
                                                        snapshot.data!.id ?? 0);
                                                  },
                                                );
                                              })
                                          : SizedBox(),
                                      Row(
                                        children: [
                                          Visibility(
                                              visible: false,
                                              maintainSize: true,
                                              maintainAnimation: true,
                                              maintainState: true,
                                              child: IconButton(
                                                  onPressed: null,
                                                  icon: Icon(Icons
                                                      .subdirectory_arrow_right))),
                                          Visibility(
                                              visible: false,
                                              maintainSize: snapshot.data!
                                                          .subDailies?.length !=
                                                      0
                                                  ? true
                                                  : false,
                                              maintainAnimation: snapshot.data!
                                                          .subDailies?.length !=
                                                      0
                                                  ? true
                                                  : false,
                                              maintainState: snapshot.data!
                                                          .subDailies?.length !=
                                                      0
                                                  ? true
                                                  : false,
                                              child: Checkbox(
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                value: false,
                                                shape: CircleBorder(),
                                                onChanged: (bool? value) {},
                                              )),
                                          GestureDetector(
                                            onTap: snapshot.data!.subDailies
                                                        ?.length !=
                                                    0
                                                ? () {
                                                    addSubDailies(
                                                        snapshot.data!);
                                                    setState(() {});
                                                    print("re");
                                                  }
                                                : null,
                                            child: Flexible(
                                                child: Text(
                                              "Add subdailies",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            )),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                )
              ]),
            );
            ;
          } else if (snapshot.hasError) {
            return Text("Error");
          } else {
            return SizedBox();
          }
        });

    // return Column(children: [
    //   Container(
    //     margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
    //     child: Focus(
    //       onFocusChange: (hasFocus) {
    //         if (!hasFocus) {}
    //         editDailies(taskNameController.text, taskDescriptionController.text,
    //             snapshot.data!.id ?? 0);
    //       },
    //       child: TextFormField(
    //         controller: taskNameController,
    //         decoration: InputDecoration(
    //           border: InputBorder.none,
    //         ),
    //         style: TextStyle(fontSize: 30),
    //       ),
    //     ),
    //   ),
    //   Container(
    //     margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     child: Column(
    //       children: [
    //         Row(
    //           children: [
    //             IconButton(onPressed: null, icon: Icon(Icons.library_books)),
    //             Flexible(
    //                 child: Focus(
    //               onFocusChange: (hasFocus) {
    //                 editDailies(taskNameController.text,
    //                     taskDescriptionController.text, widget.dailies.id ?? 0);
    //               },
    //               child: TextFormField(
    //                 controller: taskDescriptionController,
    //                 decoration: InputDecoration(
    //                   contentPadding: EdgeInsets.zero,
    //                   hintText: "Add description",
    //                   border: InputBorder.none,
    //                   hintStyle: TextStyle(
    //                       fontWeight: FontWeight.w400,
    //                       fontSize: 20,
    //                       color: Colors.black),
    //                 ),
    //                 style: TextStyle(
    //                     fontWeight: FontWeight.w400,
    //                     fontSize: 20,
    //                     color: Colors.black),
    //               ),
    //             ))
    //           ],
    //         ),
    //         widget.dailies.isTop
    //             ? GestureDetector(
    //                 onTap: widget.dailies.subDailies?.length == 0
    //                     ? () => addSubDailies(widget.dailies)
    //                     : null,
    //                 child: Stack(
    //                   children: [
    //                     Positioned(
    //                         top: 0,
    //                         left: 0,
    //                         child: IconButton(
    //                             onPressed: null,
    //                             icon: Icon(Icons.subdirectory_arrow_right))),
    //                     Column(
    //                       children: [
    //                         widget.dailies.subDailies != null
    //                             ? ListView.builder(
    //                                 shrinkWrap: true,
    //                                 itemCount:
    //                                     widget.dailies.subDailies?.length,
    //                                 itemBuilder: (context, index) {
    //                                   return SubDailiesTile(
    //                                     subDailies:
    //                                         widget.dailies.subDailies![index],
    //                                     removeSubDailies: () {
    //                                       removeSubDailies(index);
    //                                     },
    //                                   );
    //                                 })
    //                             : SizedBox(),
    //                         Row(
    //                           children: [
    //                             Visibility(
    //                                 visible: false,
    //                                 maintainSize: true,
    //                                 maintainAnimation: true,
    //                                 maintainState: true,
    //                                 child: IconButton(
    //                                     onPressed: null,
    //                                     icon: Icon(
    //                                         Icons.subdirectory_arrow_right))),
    //                             Visibility(
    //                                 visible: false,
    //                                 maintainSize:
    //                                     widget.dailies.subDailies?.length != 0
    //                                         ? true
    //                                         : false,
    //                                 maintainAnimation:
    //                                     widget.dailies.subDailies?.length != 0
    //                                         ? true
    //                                         : false,
    //                                 maintainState:
    //                                     widget.dailies.subDailies?.length != 0
    //                                         ? true
    //                                         : false,
    //                                 child: Checkbox(
    //                                   materialTapTargetSize:
    //                                       MaterialTapTargetSize.shrinkWrap,
    //                                   value: false,
    //                                   shape: CircleBorder(),
    //                                   onChanged: (bool? value) {},
    //                                 )),
    //                             GestureDetector(
    //                               onTap: widget.dailies.subDailies?.length != 0
    //                                   ? () => addSubDailies(widget.dailies)
    //                                   : null,
    //                               child: Flexible(
    //                                   child: Text(
    //                                 "Add subdailies",
    //                                 style: TextStyle(
    //                                     fontWeight: FontWeight.w400,
    //                                     fontSize: 20,
    //                                     color: Colors.black),
    //                               )),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     )
    //                   ],
    //                 ),
    //               )
    //             : SizedBox()
    //       ],
    //     ),
    //   )
    // ]);
  }
}

class SubDailiesTile extends StatefulWidget {
  const SubDailiesTile(
      {super.key, required this.removeSubDailies, required this.subDailies});

  final Function() removeSubDailies;
  final Dailies subDailies;

  @override
  State<SubDailiesTile> createState() => _SubDailiesTileState();
}

class _SubDailiesTileState extends State<SubDailiesTile> {
  @override
  Widget build(BuildContext context) {
    final taskNameController =
        TextEditingController(text: widget.subDailies.taskName);

    Future<void> editDailies(String taskName, int id) async {
      await DatabaseHelper.instance.updateSubDailies(taskName, id);
    }

    Future<void> updateIsCompletedDailies(bool isCompleted, int id) async {
      if (isCompleted == true) {
        await DatabaseHelper.instance.updateIsCompleted("true", id);
      }
      if (isCompleted == false) {
        await DatabaseHelper.instance.updateIsCompleted("false", id);
      }

      setState(() {
        widget.subDailies.isCompleted = !widget.subDailies.isCompleted;
      });
    }

    return Row(
      children: [
        Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
                onPressed: null, icon: Icon(Icons.subdirectory_arrow_right))),
        Transform.scale(
          scale: 1,
          child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: widget.subDailies.isCompleted,
              shape: CircleBorder(),
              onChanged: (bool? value) => updateIsCompletedDailies(
                  !widget.subDailies.isCompleted, widget.subDailies.id ?? 0)),
        ),
        Flexible(
          flex: 3,
          child: Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {}
              editDailies(taskNameController.text, widget.subDailies.id ?? 0);
            },
            child: TextFormField(
              controller: taskNameController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "Enter title",
                  hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.black)),
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Colors.black),
            ),
          ),
        ),
        SizedBox(
          width: 30,
          height: 30,
          child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: widget.removeSubDailies,
              icon: Icon(
                Icons.close,
              )),
        ),
        Spacer(
          flex: 1,
        ),
      ],
    );
  }
}

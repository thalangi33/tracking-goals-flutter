import 'package:flutter/material.dart';
import 'package:tracking_goals/utils/dailies.dart';

class TodoTile extends StatefulWidget {
  final int id;
  final String taskName;
  final bool isCompleted;
  final String? taskDescription;
  final VoidCallback callback;
  final void Function(Dailies dailies) openEditPage;
  final List<Dailies>? subDailies;
  final bool isTop;

  const TodoTile(
      {super.key,
      required this.id,
      required this.taskName,
      required this.isCompleted,
      this.taskDescription,
      required this.callback,
      required this.openEditPage,
      this.subDailies,
      required this.isTop});

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  @override
  Widget build(BuildContext context) {
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

      widget.callback();
    }

    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.5,
                child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: widget.isCompleted,
                    shape: CircleBorder(),
                    onChanged: (bool? value) => updateIsCompletedDailies(
                        !widget.isCompleted, widget.id, widget.isTop)),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.taskName,
                      style: TextStyle(fontSize: 24),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    widget.taskDescription != ""
                        ? Text(
                            widget.taskDescription!,
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[700]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          ),
          widget.subDailies != null
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.subDailies!.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                      child: GestureDetector(
                        onTap: () {
                          widget.openEditPage(widget.subDailies![index]);
                        },
                        child: TodoTile(
                            callback: widget.callback,
                            openEditPage: widget.openEditPage,
                            id: widget.subDailies![index].id ?? 0,
                            taskName: widget.subDailies![index].taskName,
                            isCompleted: widget.subDailies![index].isCompleted,
                            taskDescription:
                                widget.subDailies![index].taskDescription,
                            subDailies: widget.subDailies![index].subDailies,
                            isTop: widget.subDailies![index].isTop),
                      ),
                    );
                  },
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

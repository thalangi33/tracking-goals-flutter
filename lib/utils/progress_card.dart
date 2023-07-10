import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final bool isCompleted;
  final int noOfCompletedTasks;
  final int noOfDay;
  const ProgressCard(
      {super.key,
      required this.isCompleted,
      required this.noOfCompletedTasks,
      required this.noOfDay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Day $noOfDay",
          style: TextStyle(
              fontWeight: isCompleted ? FontWeight.w900 : FontWeight.w600,
              fontSize: 20,
              color: isCompleted ? Colors.green : Colors.black),
        ),
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
              border: Border.all(
                  width: isCompleted ? 5 : 3,
                  color: isCompleted ? Colors.green : Colors.black)),
          child: isCompleted
              ? Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color: Colors.green,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 38,
                          color: noOfCompletedTasks >= 1
                              ? Colors.green
                              : Colors.black,
                        ),
                        Icon(
                          Icons.check_circle_outline,
                          size: 38,
                          color: noOfCompletedTasks >= 2
                              ? Colors.green
                              : Colors.black,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 38,
                          color: noOfCompletedTasks >= 3
                              ? Colors.green
                              : Colors.black,
                        ),
                        Icon(
                          Icons.check_circle_outline,
                          size: 38,
                          color: noOfCompletedTasks >= 4
                              ? Colors.green
                              : Colors.black,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 38,
                          color: noOfCompletedTasks >= 5
                              ? Colors.green
                              : Colors.black,
                        ),
                        Icon(Icons.more_horiz_rounded, size: 38),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

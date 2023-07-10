import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracking_goals/utils/dailies.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar(
      {super.key,
      required this.backFunction,
      required this.deleteFunction,
      required this.selectedIndex});

  final VoidCallback backFunction;
  final VoidCallback deleteFunction;
  final int selectedIndex;

  Future<void> deleteDailies(int id) async {}

  @override
  Widget build(BuildContext context) {
    return [
      AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              "${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
              style: TextStyle(fontSize: 22),
            )),
            SizedBox(
              width: 10,
            ),
            Center(
                child: Text(
              "${DateFormat('E').format(DateTime.now())}",
              style: TextStyle(fontSize: 22),
            ))
          ],
        ),
      ),
      AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: backFunction,
        ),
        actions: [
          PopupMenuButton(
              itemBuilder: ((context) => [
                    PopupMenuItem(
                        onTap: deleteFunction,
                        child: SizedBox(
                          width: 90,
                          child: Text(
                            "Delete",
                            style: TextStyle(fontSize: 16),
                          ),
                        ))
                  ]))
        ],
      )
    ][selectedIndex];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

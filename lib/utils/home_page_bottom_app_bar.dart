import 'package:flutter/material.dart';
import 'package:tracking_goals/utils/progress_card.dart';

class HomePageBottomAppBar extends StatefulWidget {
  const HomePageBottomAppBar({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<HomePageBottomAppBar> createState() => _HomePageBottomAppBarState();
}

class _HomePageBottomAppBarState extends State<HomePageBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return [
      BottomAppBar(
          child: Row(
        children: [],
      )),
      BottomAppBar()
    ][widget.selectedIndex];
  }
}

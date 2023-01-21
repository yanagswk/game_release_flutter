import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:release/main.dart';

class MyAppBar extends StatefulWidget with PreferredSizeWidget {

  // AppBarタイトル
  String title;

  // appBarアクション
  List<Widget>? actions;

  // int size

  @override
  // Size get preferredSize => Size.fromHeight(kToolbarHeight);
  Size get preferredSize => Size.fromHeight(45.0);

  MyAppBar({
    super.key,
    required this.title,
    this.actions
  });

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white
          ),
        ),
        actions: widget.actions
      );
  }
}
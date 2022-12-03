import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

  /// アラートダイアログ表示
CupertinoAlertDialog alertBuilderForCupertino(
  BuildContext context, // 見出し
  String title, // 見出し
  String message      // メッセージ
) {
  return CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      CupertinoDialogAction(child: const Text('閉じる'), onPressed: () {
        Navigator.pop(context);
      },)
    ],
  );
}
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:release/models/notice.dart';
import 'package:release/widget/common/my_app_bar.dart';

class NoticeDetail extends StatefulWidget {

  NoticeModel notice;

  NoticeDetail({
    super.key,
    required this.notice
  });

  @override
  State<NoticeDetail> createState() => _NoticeDetailState();
}

class _NoticeDetailState extends State<NoticeDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "お知らせ"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // TODO: ペアフルパクる
          // Text(
          //   widget.notice.noticeDate,
          //   style: TextStyle(
          //     color: Colors.grey,
          //   )
          // ),
          // Text(
          //   widget.notice.title,
          //   style: TextStyle(
          //     // fontWeight: FontWeight.bold,
          //     // fontSize: 20,
          //   )
          // ),
          // Text(
          //   widget.notice.title,
          //   // style: TextStyle(
          //   //   // fontWeight: FontWeight.bold,
          //   //   // fontSize: 20,
          //   // )
          // ),
          // // const SizedBox(height: 20),
          // Text(
          //   widget.notice.contents
          // ),
          const SizedBox(height: 20),
          Text("リリース"),
          Text("リリースss"),
          const SizedBox(width: 50),
          // Text("リリースしたいお！！!!!!"),
          Text(
            widget.notice.title,
            // style: TextStyle(
            //   // fontWeight: FontWeight.bold,
            //   // fontSize: 20,
            // )
          ),
        ],
      ),
    );
  }
}
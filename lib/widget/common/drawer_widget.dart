import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:release/notice_page.dart';
import 'package:release/question_page.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  var _city = '';

  // プライバシーポリシー遷移
  Future _launchUrl() async {
    var url = "https://massu-engineer.com/privacy_policy_release/";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Unable to launch url $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
          child: ListView(
            children: [
              // const DrawerHeader(
              //   child: Text(
              //     'My App',
              //     style: TextStyle(
              //       fontSize: 24,
              //       color: Colors.white,
              //     ),
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.blue,
              //   ),
              // ),
              // ListTile(
              //   title: Text('お知らせ'),
              //   onTap: () {
              //     // Navigator.pop(context);
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (BuildContext context) => const NoticePage(),
              //       ),
              //     );
              //   },
              // ),
              ListTile(
                title: Text('お問い合わせ'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => const QuestionPage(),
                    ),
                  );
                },
              ),
              // ListTile(
              //   title: Text('このアプリをレビューする'),
              //   onTap: () {
              //     // TODO: アプリできてから？？
              //     LaunchReview.launch();
              //   },
              // ),
              // ListTile(
              //   title: Text('シェアする'),
              //   onTap: () {
              //     // Navigator.pop(context);
              //     Share.share('このアプリをシェアしたいんだお');
              //   },
              // ),
              ListTile(
                title: Text('プライバシーポリシー'),
                onTap: () {
                  // setState(() => _city = 'Dallas, TX');
                  // Navigator.pop(context);
                  _launchUrl();
                },
              ),
            ],
          ),
        );
  }
}
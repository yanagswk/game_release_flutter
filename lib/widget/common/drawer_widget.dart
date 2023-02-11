import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:release/getx/game_getx.dart';
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

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  // プライバシーポリシー遷移
  Future _launchUrl() async {
    var url = "https://massu-engineer.com/privacy_policy_game_release/";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Unable to launch url $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
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
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text('お問い合わせ'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => const QuestionPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.ios_share),
                  title: Text('アプリを教える'),
                  onTap: () {
                    // SNS共有
                    final share_msg = 'げーむりり - 最新ゲームソフトの発売日がわかる！ \n https://apps.apple.com/jp/app/%E3%81%92%E3%83%BC%E3%82%80%E3%82%8A%E3%82%8A/id6444914435';
                    Share.share(share_msg);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_border),
                  title: Text('アプリをレビューする'),
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://apps.apple.com/jp/app/%E3%81%92%E3%83%BC%E3%82%80%E3%82%8A%E3%82%8A/id6444914435?action=write-review"),
                      mode: LaunchMode.externalApplication,   // デフォルトのブラウザで開く(参考: https://zenn.dev/tsuruo/articles/56f3abbb132f90)
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text('プライバシーポリシー'),
                  onTap: () {
                    _launchUrl();
                  },
                ),
              ],
            ),
          ),
          Text("バージョン: ${_gameGetx.appVersion}"),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
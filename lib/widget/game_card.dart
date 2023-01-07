import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:release/common/device_info.dart';
import 'package:release/game_detail.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/item_chip.dart';
import 'package:get/get.dart';

/// ゲームカードwidget
class GameCard extends StatefulWidget {
  // ゲーム情報
  GameInfoModel game;
  // 日付フラグ
  bool isDisplayDate;

  GameCard({
    super.key,
    required this.game,
    required this.isDisplayDate,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {

  // ゲーム情報
  late GameInfoModel game;
  // 日付フラグ
  late bool isDisplayDate;

    // Getx読み込み
  final gameGetx = Get.put(GameGetx());

    @override
  void initState() {
    super.initState();

    // 受け取った値をを変数に設定
    game = widget.game;
    isDisplayDate = widget.isDisplayDate;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      child: Container(
        child: ListTile(
          leading: Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(.5),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                image: NetworkImage(
                  game.imageList[0],
                ),
              ),
            ),
          ),
          title: Text(
            game.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemChip(hardware: game.hardware, width: 70),
              Text('(税込) ${game.price}円'),
              isDisplayDate ? Text(game.salesDate): const SizedBox.shrink(),  // フラグがfalseの時は、何も表示しない
            ]
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () async => {
            // ゲーム詳細画面へ遷移
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => GameDetail(game: game),
              ),
            ).then((value) {
              // お気に入り画面に、戻るとき
              if (isDisplayDate) {
                gameGetx.trueFavorite();
              }
            }),
          },
        ),
      ),
    );
  }
}
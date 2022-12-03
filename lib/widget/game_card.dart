import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:release/common/device_info.dart';
import 'package:release/game_detail.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/hardware_chip.dart';
import 'package:get/get.dart';

/// ゲームカードwidget
class GameCard extends StatefulWidget {
  // ゲーム情報
  GameInfoModel game;
  // 日付フラグ
  bool isFavoritePage;

  GameCard({
    super.key,
    required this.game,
    required this.isFavoritePage,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {

  // ゲーム情報
  late GameInfoModel game;
  // 日付フラグ
  late bool isFavoritePage;

    // Getx読み込み
  final gameGetx = Get.put(GameGetx());

    @override
  void initState() {
    super.initState();

    // 受け取った値をを変数に設定
    game = widget.game;
    isFavoritePage = widget.isFavoritePage;

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
                  game.largeImageUrl,
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
              HardwareChip(hardware: game.hardware),
              Text('(税込) ${game.price}円'),
              isFavoritePage ? Text(game.salesDate): const SizedBox.shrink(),  // フラグがfalseの時は、何も表示しない
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
              // 前の画面から戻った時
              if (isFavoritePage) {
                gameGetx.trueFavorite();
              }
            }),
          },
        ),
      ),
    );
  }
}
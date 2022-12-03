import 'package:flutter/material.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/game_card.dart';
import 'package:grouped_list/grouped_list.dart';

class GameReleaseGroup extends StatefulWidget {

  // ゲーム一覧
  List<GameInfoModel> games;

  GameReleaseGroup({
    super.key,
    required this.games
  });

  @override
  State<GameReleaseGroup> createState() => _GameReleaseGroupState();
}

class _GameReleaseGroupState extends State<GameReleaseGroup> {

  // ゲーム情報
  List<GameInfoModel> games = [];

  @override
  void initState() {
    super.initState();

    // 受け取ったgameを変数に設定
    games = widget.games;

    // 再描画
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView<dynamic, String>( // 日付ごとにグループ化
        elements: games,
        groupBy: (game) => game.salesDate,
        useStickyGroupSeparators: true,
        order: GroupedListOrder.ASC,
        groupSeparatorBuilder: (String value) => Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 3.0),
            child: Container(
              color: Colors.grey[350],
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        itemBuilder: (context, element) {
          var game = element as GameInfoModel;
        
          return GameCard(
            game: game, 
            isFavoritePage: true,
          );
        }
      );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/common/drawer_widget.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/game_card.dart';
import 'package:get/get.dart';


class GameFavoritePage extends StatefulWidget {
  const GameFavoritePage({Key? key}) : super(key: key);

  @override
  State<GameFavoritePage> createState() => _GameFavoritePageState();
}

class _GameFavoritePageState extends State<GameFavoritePage> {
  // お気に入りゲーム一覧
  List<GameInfoModel> favoriteGames = [];

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  String text = "";

  Future<void> getFavoriteGame() async {
    _gameGetx.setLoading(true);

    await SharedPrefe.init();

    favoriteGames = [];
    favoriteGames = await ApiClient().getFavoriteGameList();
    setState(() {
      if (favoriteGames.length == 0) {
        text = "";
      }
    });
    _gameGetx.setLoading(false);
  }

  @override
  void initState() {
    // 詳細画面からお気に入り一覧に戻ったとき、お気に入り一覧を更新し直す
    ever(_gameGetx.isFavorite, (_) => {
      if (mounted) {
        _gameGetx.falseFavorite(),
        setState(() {
          favoriteGames;
        }),
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getFavoriteGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "お気に入り一覧"),
      drawer: const DrawerWidget(), // サイドバー
      body:
      Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child:
        favoriteGames.length == 0
        ?
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text(text)),
              ),
            ),
            // バナー広告
            AdModBanner(adModHight: 50)
          ],
        )
        :
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: favoriteGames.length,
                  itemBuilder: (context, index) {
                    if (favoriteGames[index].isDisplay!) {
                      return Column(
                        children: [
                          index % 7 == 0 && index != 0
                            ? AdModBanner(adModHight: 50)
                            : const SizedBox(),
                          GameCard(
                            game: favoriteGames[index],
                            isDisplayDate: true
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
            // バナー広告
            AdModBanner(adModHight: 50),
          ],
        ),
      )
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
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
    favoriteGames = [];
    favoriteGames = await ApiClient().getFavoriteGameList();
    setState(() {
      if (favoriteGames.length == 0) {
        text = "お気に入り登録しているゲームはありません";
      }
    });
    _gameGetx.setLoading(false);
  }

  @override
  void initState() {
    // 詳細画面からお気に入り一覧に戻ったとき、お気に入り一覧を取得し直す
    ever(_gameGetx.isFavorite, (_) => {
      if (mounted) {
        _gameGetx.falseFavorite(),
        setState(() {
          getFavoriteGame();
        })
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
      body: 
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
            AdModBanner()
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
                    return GameCard(
                      game: favoriteGames[index], 
                      isFavoritePage: true
                    );
                  },
                ),
              ),
            ),
            // バナー広告
            AdModBanner()
          ],
        ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:release/api/api.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:url_launcher/link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:release/models/game_info.dart';
import 'package:release/common/device_info.dart';

import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';


class GameDetail extends StatefulWidget {

  // ゲームid
  // int gameId;
  GameInfoModel game;

  GameDetail({
    super.key,
    required this.game
  });

  @override
  State<GameDetail> createState() => _GameDetailState();
}

class _GameDetailState extends State<GameDetail> {
  // ゲームid
  // late int gameId;

  // ゲーム詳細情報
  late GameInfoModel game;

  var loading = false;

  final _gameGetx = Get.put(GameGetx());

  // var isFavorite = false;

  /// api叩く
  // Future getApiData(int gameId) async {
  //   game = await ApiClient().getGameDetail(gameId);
  // }

  @override
  void initState() {
    super.initState();
    // 受け取ったgameを変数に設定
    game = widget.game;
  }


  /// ゲームをお気に入り登録する/解除する
  /// https://qiita.com/mamoru_takami/items/2d930ee927c048060741
  Future<void> favoriteGame(int gameId, bool doFavorite) async {
    _gameGetx.setLoading(true);

    final deviceInfo = DeviceInfo();
    var result = false;

    if (doFavorite) {
      // お気に入り状態だから、解除する
      result = await ApiClient().removeFavoriteGameApi(gameId);
    } else {
      // 登録する
      result = await ApiClient().addFavoriteGameApi(gameId);
    }
    loading = false;

    if (result) {
      setState((){
        game.isFavorite = !game.isFavorite;
        loading = false;
      });
    }
    _gameGetx.setLoading(false);
  }


  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
        Scaffold(
          // 画面上部のタイトル
          appBar: MyAppBar(title: "ゲーム詳細画面"),
          body: Center(
            child: SingleChildScrollView(   // SingleChildScrollViewの中でFlexible・Expandedを使うときは、Containerで囲って、heightを指定する
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ゲームタイトル
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  game.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  game.label,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(
                      game.largeImageUrl,
                      errorBuilder: (c, o, s) {
                        return const Icon(
                          Icons.downloading,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
      
                  // 値段、評価点
                  Container(
                    margin: const EdgeInsets.all(30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '(税込) ${game.price} 円',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0
                            ),
                          ),
                        ),
                        Text('発売日 ${game.salesDate}'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // 星評価
                                RatingBar.builder(
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    // 評価更新時
                                  },
                                  itemCount: 5,           // 星の数
                                  initialRating: game.reviewAverage,     // 初期値
                                  allowHalfRating: true,  // 小数点有効
                                  ignoreGestures: true    // クリックしても反応しないように
                                ),
                                // 評価値
                                Text("(平均: ${game.reviewAverage})"),
                              ]
                            ),
                            // お気に入り
                            // loading
                            // ?
                            // const SizedBox(
                            //   height: 25,
                            //   width: 25,
                            //   child: CircularProgressIndicator(),
                            // ) // ローディング
                            // :
                            IconButton( // お気に入りアイコン
                              icon: SizedBox(
                                height: 25,
                                width: 25,
                                child: Icon(
                                  game.isFavorite ? Icons.favorite : Icons.favorite_border,//追加
                                  color: game.isFavorite ? Colors.red : null,//追
                                  // size: 25
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                // お気に入りapiを叩く
                                favoriteGame(game.id, game.isFavorite);
                              }
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 商品説明
                  Container(
                    margin: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
                    child: Text(game.itemCaption),
                  ),
                  Link(
                    uri: Uri.parse(game.itemUrl),
                    target: LinkTarget.self,
                    builder: (BuildContext ctx, FollowLink? openLink) {
                      return TextButton(
                        onPressed: openLink,
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '出典: Rakutenブックス',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          ),
        ),
        Obx( // getxで検知するように
          // 全画面ローディング
          () => OverlayLoadingMolecules(
            visible: _gameGetx.isLoading.value
          )
        ),
      ]
      ),
    );
  }
}
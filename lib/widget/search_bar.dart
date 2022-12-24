import 'package:flutter/material.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/game_card.dart';
import 'package:get/get.dart';
import 'package:release/widget/hardware_select.dart';
import 'package:release/widget/search_select.dart.dart';

/// AppBar用のクラス
class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  // 検索ワード
  String _searchWord = "";

  int targetCount = 0;

  List games = [];

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

    /// ゲーム検索
  Future searchGames() async {

    _gameGetx.setLoading(true);

    // 総数よりも大きくなったらreturnする
    // if (targetCount != 0 && targetCount < gameOffset) {
    //   SharedPrefe.setIsPaging(false);
    //   return ;
    // }

    // _choiceIndex = SharedPrefe.getString('targetHardware');

    setState(() {
      games = [];
    });

    final gameTest = await ApiClient().getSearchGames(
        searchWord: _searchWord,
        limit: 40,
        offset: 0,
    );

    print("やあ");
    print(gameTest);

    if (gameTest['game'].isEmpty) {
      _gameGetx.setLoading(false);
      return;
    }

    targetCount = gameTest['game_count'];

    games.addAll(gameTest['game']);

    // print("検索ゲーム取得");
    // print(games);

    // -----------TODO: のちに修正したい ここから-----------
    // 例えばPS4のゲーム一覧で、画面がスクロール状態の時に、PS5を選択すると、
    // 初回APIが2回叩かれてしまう事があるので、重複したものを省いている
    // final gameIdList = games.map((e) => e.id);
    // gameTest['game'].forEach((element) {
    //   if (!gameIdList.contains(element.id)) {
    //     // 含んでいなかったら追加する
    //     games.add(element);
    //   }
    // });
    // -----------TODO: ここまで-----------

    // final gameGroupTest = groupBy(games, (obj) => obj.salesDate);

    // groupGames.addAll(gameGroupTest);
    // gameOffset += gameLimit;

    // 参考: https://teratail.com/questions/286406
    setState(() {});
    // if (chageHardware) 
    _gameGetx.setLoading(false);
  }

  // 検索用の入力widget
  Widget _searchTextField() {
    return TextField(
      onSubmitted: (value) {
        _searchWord = value;
        searchGames();
      },
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      cursorColor: Colors.white, //カーソルの色
      style: const TextStyle( //テキストのスタイル
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search, //キーボードのアクションボタンを指定
      decoration: const InputDecoration( //TextFiledのスタイル
        enabledBorder: UnderlineInputBorder( //デフォルトのTextFieldの枠線
          borderSide: BorderSide(color: Colors.white)
        ),
        focusedBorder: UnderlineInputBorder( //TextFieldにフォーカス時の枠線
          borderSide: BorderSide(color: Colors.white)
        ),
        hintText: 'ゲームを検索', //何も入力してないときに表示されるテキスト
        hintStyle: TextStyle( //hintTextのスタイル
          color: Colors.white60,
          fontSize: 20,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[800],
            title: _searchTextField(),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  Navigator.pop(context);
                }
              )
            ]
          ),
          body: games.length == 0
            ?
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("")),
                  ),
                ),
                // バナー広告
                AdModBanner()
              ],
            )
            :
            Column(
              children: [
                // const SearchSelect(),
                const HardwareSelect(),
                Expanded(
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        return GameCard(
                          game: games[index],
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
        ),
        Obx( // getxで検知するように
            // 全画面ローディング
            () => OverlayLoadingMolecules(
              visible: _gameGetx.isLoading.value
            )
          ),
      ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/game_card.dart';
import 'package:get/get.dart';
import 'package:release/widget/hardware_select.dart';
import 'package:release/widget/released_year_select.dart';
import 'package:release/widget/search_result.dart';
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

  // ゲーム一覧
  List<GameInfoModel> games = [];

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  int targetCount = 0;
  // 取得するゲーム数
  int gameLimit = 40;
  // 取得するゲームの開始位置
  int gameOffset = 0;

  // 入力欄のフォーカス
  FocusNode _focus = new FocusNode();
  bool _isFocus = false;


  final List<int> _yearList = [2023, 2022, 2021, 2020];

    @override
  void initState() {
    super.initState();
    // _gameGetx.setSearchHardware('All');

    // _focus.addListener(_onFocusChange);

    // // everでハードウェアの値を監視して、更新されたらapiを叩くために再描画する
    // ever(_gameGetx.searchHardware, (_) => {
    //   if (mounted) {
    //     // if (_gameGetx.isInitHardware.value) {
    //       setState(() {
    //         searchGames(true);
    //       }),
    //     // } else {
    //       // 初回の空っぽのgameGetx.hardwareから、値がセットされた場合は、
    //       // 再描画(setState)してほしくないから、フラグを立てる
    //       // TODO: パワーコードだから修正したい
    //       // _gameGetx.isInitHardware.value = true
    //     // }
    //   }
    // });
  }

  // void _onFocusChange() {
  //   print("Focus: " + _focus.hasFocus.toString());
  //   setState(() {
  //     _isFocus = _focus.hasFocus;

  //     // 入力欄がフォーカス状態なら、画面を覆う
  //     if (_isFocus) {
  //       _gameGetx.setSearchLoading(true);
  //     } else {
  //       _gameGetx.setSearchLoading(false);
  //     }
  //   });
  // }


  // 検索用の入力widget
  Widget _searchTextField() {
    return SizedBox(
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Container(
            width: 340,
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: TextField(
              autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
              decoration: const InputDecoration(
                hintText: 'ゲームを検索',
                contentPadding: EdgeInsets.only(left: 8.0),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (value) {
                _searchWord = value;
                // searchGames(true);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => SearchResult(searchWord: value),
                  ),
                );
              },
              focusNode: _focus,
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: AppBar(
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
          ),
          body: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Text("発売した年から探す"),
                    // ReleasedYearSelect(),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            children: _yearList.map((int year) =>
                              ActionChip(
                                label: Text(
                                  "${year}年",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                                backgroundColor: Colors.grey[500],
                                onPressed:() {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => SearchResult(year: year),
                                    ),
                                  );
                                }
                              ),
                            ).toList(),
                          )
                        ],
                      ),
                    ),

                    // games.length != 0
                    //   ?
                    //   SearchGameInfinityView(
                    //     contents: games,
                    //     getContents: searchGames,
                    //   )
                    //   :
                      // Expanded(child: Text("")),
                      Expanded(child: Text("")),

                      // バナー広告
                      AdModBanner(),
                  ]
                ),
                // Obx( // getxで検知するように
                //   // 入力欄以外を覆う
                //   () => OverlayLoadingMolecules(
                //     visible: _gameGetx.isSearchLoading.value,
                //     isLoading: false
                //   )
                // ),
              ],
            ),
          )
        ),
        // Obx( // getxで検知するように
        //   // 全画面ローディング
        //   () => OverlayLoadingMolecules(
        //     visible: _gameGetx.isLoading.value,
        //     isLoading: true
        //   )
        // ),
      ],
      ),
    );
  }
}


// --------
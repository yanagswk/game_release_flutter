import 'package:flutter/material.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/common/constants.dart';
import 'package:release/widget/common/drawer_widget.dart';
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

  // 発売した年一覧
  final List<int> _yearList = [2023, 2022, 2021, 2020];

  // ジャンルー一覧
  final List<String> _genreList = [
    "シューティング",
    "格闘・アクション",
    "アドベンチャー",
    "シミュレーション",
    "スポーツ・レース",
    "RPG",
    "周辺機器",
  ];

    @override
  void initState() {
    super.initState();
  }

  // 検索用の入力widget
  Widget _searchTextField() {
    return SizedBox(
      height: 40,
      child: Container(
        margin: EdgeInsets.only(left: 5.0, right: 20.0),
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
              autofocus: false, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
              decoration: const InputDecoration(
                hintText: 'ゲームを検索',
                contentPadding: EdgeInsets.only(left: 8.0),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (value) {
                _searchWord = value;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => SearchResult(
                      displayType: DisplayType.SEARCH,
                      searchWord: value
                    ),
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
    return Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(48.0),
      child: AppBar(
        backgroundColor: Colors.blue[900],
        title: _searchTextField(),
        centerTitle: true,
      ),
    ),
    drawer: const DrawerWidget(), // サイドバー
    body: Container(
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Column(
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
                            builder: (BuildContext context) => SearchResult(
                              displayType: DisplayType.RELEASE_DATE,
                              year: year
                            ),
                          ),
                        );
                      }
                    ),
                  ).toList(),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text("ジャンルから探す"),

          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  children: _genreList.map((String genre) =>
                    ActionChip(
                      label: Text(
                        genre,
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => SearchResult(
                              displayType: DisplayType.GENRE,
                              genre: genre
                            ),
                          ),
                        );
                      }
                    ),
                  ).toList(),
                )
              ],
            ),
          ),
          Expanded(child: Text("")),
          // バナー広告
          AdModBanner(adModHight: 50),
        ]
      ),
    )
      );
  }
}


// --------
import 'package:flutter/material.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/common/constants.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/game_card.dart';
import 'package:get/get.dart';
import 'package:release/widget/hardware_select.dart';
import 'package:release/widget/released_year_select.dart';
import 'package:release/widget/search_select.dart.dart';

/// AppBar用のクラス
class SearchResult extends StatefulWidget {

  String displayType;
  int? year;
  String? searchWord;
  String? genre;

  SearchResult({
    super.key,
    required this.displayType,
    this.year,
    this.searchWord,
    this.genre
  });

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

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

  String selectMonth = "01";
  String kariSelectMonth = "01";
  final List<String> _yearMonth = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];

  String _selectHardware = "All";
  String _kariSelectHardware = "All";
  final List<String> _hardwareList = ["All", "Switch", "PS5", "PS4"];

  int _kariSelectReleasedType = 1;
  int _selectReleasedType = 1;

  String _sort = "asc";
  String _kariSelectSort = "asc";
  final List _sortList = [
    {
      "name": "古い順",
      "target": "asc",
    },
    {
      "name": "新しい順",
      "target": "desc",
    },
  ];

  // 入力欄のフォーカス
  FocusNode _focus = new FocusNode();
  bool _isFocus = false;

  String _appTitle = "";

  @override
  void initState() {
    super.initState();
    _gameGetx.setSearchHardware('All');
    _focus.addListener(_onFocusChange);

    // everでハードウェアの値を監視して、更新されたらapiを叩くために再描画する
    ever(_gameGetx.searchHardware, (_) => {
      if (mounted) {
        // if (_gameGetx.isInitHardware.value) {
          setState(() {
            searchGames(true);
          }),
        // } else {
          // 初回の空っぽのgameGetx.hardwareから、値がセットされた場合は、
          // 再描画(setState)してほしくないから、フラグを立てる
          // TODO: パワーコードだから修正したい
          // _gameGetx.isInitHardware.value = true
        // }
      }
    });

    // Widgetのビルドが終わったタイミングで呼ばれる
    // https://zuma-lab.com/posts/flutter-troubleshooting-called-during-build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      searchGames(true);
      _getAppBarTitle();
    });
  }

  void _onFocusChange() {
    print("Focus: " + _focus.hasFocus.toString());
    setState(() {
      _isFocus = _focus.hasFocus;

      // 入力欄がフォーカス状態なら、画面を覆う
      if (_isFocus) {
        _gameGetx.setSearchLoading(true);
      } else {
        _gameGetx.setSearchLoading(false);
      }
    });
  }

  /// AppBarのタイトル
  void _getAppBarTitle() {
    if (widget.displayType == DisplayType.RELEASE_DATE) {
      _appTitle = '${widget.year}年${selectMonth}月発売';
    } else if (widget.displayType == DisplayType.SEARCH) {
      _appTitle = '${widget.searchWord}';
    } else if (widget.displayType == DisplayType.GENRE) {
      _appTitle = '${widget.genre}';
    }
  }


  Future test() async {
    if (widget.year != null) {
      return await ApiClient().getSearchGames(
          hardware: _selectHardware,
          searchWord: _searchWord,
          limit: gameLimit,
          offset: gameOffset,
          year: widget.year,
          month: selectMonth,
          sort: _sort
      );
    } else if (widget.searchWord != null) {
      return await ApiClient().getSearchWordGames(
          hardware: _selectHardware,
          searchWord: widget.searchWord!,
          limit: gameLimit,
          offset: gameOffset,
          sort: _sort
      );
    } else if (widget.genre != null) {
      return await ApiClient().getGenreGames(
          hardware: _selectHardware,
          genre: widget.genre!,
          isReleased: _selectReleasedType,
          limit: gameLimit,
          offset: gameOffset,
          sort: _sort
      );
    } else {
      _gameGetx.setLoading(false);
      return;
    }
  }

    /// ゲーム検索
  Future searchGames(bool isReset) async {

    if (isReset) {
      setState(() {
        games = [];
        selectMonth;
        _selectHardware;
        _selectReleasedType;
        _sort;
      });
      gameOffset = 0;
      targetCount = 0;
      SharedPrefe.setIsPaging(true);
      _selectReleasedType = _kariSelectReleasedType;
      _selectHardware = _kariSelectHardware;
      selectMonth = kariSelectMonth;
      _sort = _kariSelectSort;
    }

    _getAppBarTitle();

    // 総数よりも大きくなったらreturnする
    if (targetCount != 0 && targetCount < gameOffset) {
      SharedPrefe.setIsPaging(false);
      return ;
    }

    _gameGetx.setLoading(true);

    final gameTest = await test();

    if (gameTest['game'].isEmpty) {
      _gameGetx.setLoading(false);
      return;
    }

    targetCount = gameTest['game_count'];

    games.addAll(gameTest['game']);
    gameOffset += gameLimit;

    // 参考: https://teratail.com/questions/286406
    setState(() {});
    _gameGetx.setLoading(false);
  }

    /// ハードウェアによって色を返却
  Color getHardwareColor(String target) {
    if (target == 'Switch') {
      return Colors.red;
    } else if (target == 'PS4') {
      return Colors.cyan;
    } else if (target == 'PS5') {
      return Colors.blue;
    } else {
      return Colors.black;
    }
  }

  String getHardWareName(hardware) {
    return hardware == "All" ? "全機種" : hardware;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Scaffold(
          appBar: MyAppBar(title: _appTitle),
          body: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    games.length != 0
                      ?
                      SearchGameInfinityView(
                        contents: games,
                        getContents: searchGames,
                      )
                      :
                      Expanded(child: Text("")),
                      // バナー広告
                      AdModBanner(adModHight: 50),
                  ]
                ),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              child: const Icon(Icons.sort),
              backgroundColor: Colors.blue[800],
              onPressed: () {
                showModalBottomSheet(
                  //モーダルの背景の色、透過
                  backgroundColor: Colors.transparent,
                  //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, StateSetter setState) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          margin: EdgeInsets.only(top: 64),
                          decoration: BoxDecoration(
                            //モーダル自体の色
                            color: Colors.white,
                            //角丸にする
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),

                                // ジャンルを選択した場合
                                widget.displayType == DisplayType.RELEASE_DATE ?
                                Row(
                                  children: [
                                    Icon(Icons.article_outlined),
                                    Text(
                                      '発売月',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ) : const SizedBox(),

                                // 発売年を選択した場合
                                widget.displayType == DisplayType.RELEASE_DATE ?
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                                    child: Row(
                                      children:
                                        _yearMonth.map((String month) =>
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3.0,bottom: 3.0, left: 5.0, right: 5.0),
                                            child: ChoiceChip(
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                                              // labelPadding: EdgeInsets.symmetric(horizontal: 1), // 追加：文字左右の多すぎるpaddingを調整
                                              visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                                              label: Text(
                                                "${month}月",
                                                style: TextStyle(
                                                  color: Colors.white
                                                ),
                                              ),
                                              backgroundColor: Colors.grey[500],
                                              selected: kariSelectMonth == month,
                                              selectedColor: Colors.black,
                                              onSelected:(value) {
                                                setState(() {
                                                  kariSelectMonth = month;
                                                });
                                              },
                                            ),
                                          ),
                                        ).toList(),
                                    ),
                                  ),
                                ): const SizedBox(),

                                // ジャンルを選択した場合
                                widget.displayType == DisplayType.GENRE ?
                                Row(
                                  children: [
                                    Icon(Icons.article_outlined),
                                    const SizedBox(width: 5),
                                    Text(
                                      '期間',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ) : const SizedBox(),

                                // ジャンルを選択した場合
                                widget.displayType == DisplayType.GENRE ?
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3.0,bottom: 3.0, left: 5.0, right: 5.0),
                                            child: ChoiceChip(
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                                              // labelPadding: EdgeInsets.symmetric(horizontal: 1), // 追加：文字左右の多すぎるpaddingを調整
                                              visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                                              label: const Text(
                                                "これから発売",
                                                style: TextStyle(
                                                  color: Colors.white
                                                ),
                                              ),
                                              backgroundColor: Colors.grey[500],
                                              selected: _kariSelectReleasedType == 2,
                                              selectedColor: Colors.black,
                                              onSelected:(value) {
                                                setState(() {
                                                  _kariSelectReleasedType = 2;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 3.0,bottom: 3.0, left: 5.0, right: 5.0),
                                            child: ChoiceChip(
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                                              // labelPadding: EdgeInsets.symmetric(horizontal: 1), // 追加：文字左右の多すぎるpaddingを調整
                                              visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                                              label: const Text(
                                                "発売済み",
                                                style: TextStyle(
                                                  color: Colors.white
                                                ),
                                              ),
                                              backgroundColor: Colors.grey[500],
                                              selected: _kariSelectReleasedType == 1,
                                              selectedColor: Colors.black,
                                              onSelected:(value) {
                                                setState(() => {
                                                  _kariSelectReleasedType = 1,
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]): const SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.videogame_asset_outlined),
                                      const SizedBox(width: 5),
                                      Text(
                                        '機種',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                // ハードウェア
                                Row(
                                  children: _hardwareList.map((String hardware) =>
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0, bottom: 10.0, left: 5.0, right: 5.0),
                                        child: ChoiceChip(
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                                          // labelPadding: EdgeInsets.symmetric(horizontal: 1), // 追加：文字左右の多すぎるpaddingを調整
                                          visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                                          label: Text(
                                            "${getHardWareName(hardware)}",
                                            style: TextStyle(
                                              color: Colors.white
                                            ),
                                          ),
                                          backgroundColor: Colors.grey[500],
                                          selected: _kariSelectHardware == hardware,
                                          selectedColor: getHardwareColor(hardware),
                                          onSelected:(value) {
                                            setState(() {
                                              _kariSelectHardware = hardware;
                                            });
                                          },
                                        ),
                                      ),
                                    ).toList(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.sort),
                                      const SizedBox(width: 5),
                                      Text(
                                        '順番',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: _sortList.map((sort) =>
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0, bottom: 10.0, left: 5.0, right: 5.0),
                                        child: ChoiceChip(
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                                          // labelPadding: EdgeInsets.symmetric(horizontal: 1), // 追加：文字左右の多すぎるpaddingを調整
                                          visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                                          label: Text(
                                            sort["name"],
                                            style: TextStyle(
                                              color: Colors.white
                                            ),
                                          ),
                                          backgroundColor: Colors.grey[500],
                                          selected: _kariSelectSort == sort["target"],
                                          selectedColor: Colors.black,
                                          onSelected:(value) {
                                            setState(() {
                                              print(sort["target"]);
                                              _kariSelectSort = sort["target"];
                                            });
                                          },
                                        ),
                                      ),
                                    ).toList(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[800], //ボタンの背景色
                                      ),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                        searchGames(true);
                                      },
                                      child: Text(
                                        'この条件で検索する',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        );
                      },
                    );
                  });
              }
            ),
          )
        ),
        Obx( // getxで検知するように
          // 全画面ローディング
          () => OverlayLoadingMolecules(
            visible: _gameGetx.isLoading.value,
            isLoading: true
          )
        ),
      ],
      ),
    );
  }
}


// -------------インフィニティスクロール-------------
class SearchGameInfinityView extends StatefulWidget {
  // ゲーム一覧
  final List<GameInfoModel> contents;
  // ゲームを取得する関数
  final Future<dynamic> Function(bool) getContents;

  const SearchGameInfinityView({
    Key? key,
    required this.contents,
    required this.getContents,
  }) : super(key: key);

  @override
  State<SearchGameInfinityView> createState() => _SearchGameInfinityViewState();
}

class _SearchGameInfinityViewState extends State<SearchGameInfinityView> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  bool isPaging = true;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {

        isPaging = SharedPrefe.getIsPaging();
        if (!isPaging) {
          setState (() {});
          return;
        }

        _isLoading = true;
        await widget.getContents(false);
        setState (() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Flexible(  // https://rayt-log.com/%E3%80%90flutter%E3%80%91column%E3%81%AE%E4%B8%AD%E3%81%A7listview-builder%E3%82%92%E8%A1%A8%E7%A4%BA%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95/
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.contents.length,
          itemBuilder: (context, gameIndex) {
            return Column(
              children: [
                gameIndex % 7 == 0 && gameIndex != 0
                  ? AdModBanner(adModHight: 50)
                  : const SizedBox(),
                GameCard(
                  game: widget.contents[gameIndex],
                  isDisplayDate: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
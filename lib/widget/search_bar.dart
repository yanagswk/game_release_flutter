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

    /// ゲーム検索
  Future searchGames(bool isReset) async {

    if (isReset) {
      setState(() {
        games = [];
      });
      gameOffset = 0;
      targetCount = 0;
      SharedPrefe.setIsPaging(true);
    }


    // 総数よりも大きくなったらreturnする
    if (targetCount != 0 && targetCount < gameOffset) {
      SharedPrefe.setIsPaging(false);
      return ;
    }

    _gameGetx.setLoading(true);

    final gameTest = await ApiClient().getSearchGames(
        hardware: _gameGetx.searchHardware.value,
        searchWord: _searchWord,
        limit: gameLimit,
        offset: gameOffset,
    );

    if (gameTest['game'].isEmpty) {
      _gameGetx.setLoading(false);
      return;
    }

    targetCount = gameTest['game_count'];

    print("全部で");
    print(targetCount);

    games.addAll(gameTest['game']);
    gameOffset += gameLimit;

    // 参考: https://teratail.com/questions/286406
    setState(() {});
    _gameGetx.setLoading(false);
  }

  // 検索用の入力widget
  Widget _searchTextField() {
    return TextField(
      focusNode: _focus,
      onSubmitted: (value) {
        _searchWord = value;
        searchGames(true);
      },
      autofocus: true, //TextFieldが表示されるときにフォーカスする（キーボードを表示する）
      // focusNode:
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
          body: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    HardwareSelect(displayName: 'search'),
                    games.length != 0
                      ?
                      SearchGameInfinityView(
                        contents: games,
                        getContents: searchGames,
                      )
                      :
                      Expanded(child: Text("")),
                      // バナー広告
                      AdModBanner(),
                  ]
                ),
                Obx( // getxで検知するように
                  // 入力欄以外を覆う
                  () => OverlayLoadingMolecules(
                    visible: _gameGetx.isSearchLoading.value,
                    isLoading: false
                  )
                ),
              ],
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
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.contents.length,
        itemBuilder: (context, gameIndex) {
          return GameCard(
            game: widget.contents[gameIndex],
            isDisplayDate: true,
          );
        },
      ),
    );
  }
}
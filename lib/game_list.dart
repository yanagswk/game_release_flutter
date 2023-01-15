import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.Dart";
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/device_info.dart';
import 'package:release/common/shared_preferences.dart';

import 'package:release/api/api.dart';
import 'package:release/main.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/common/system_widget.dart';
import 'package:release/widget/game_card.dart';
import 'package:release/widget/hardware_select.dart';

import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';


// -------------ゲーム一覧-------------
class GameList extends StatefulWidget {
  // 発売日フラグ
  // true:発売済み, false:これから発売
  int isReleased;

  GameList({
    super.key,
    required this.isReleased,
  });

  @override
  State<GameList> createState() => _GameListState();
}

// AutomaticKeepAliveClientMixinでStateの状態を保持する
class _GameListState extends State<GameList> with AutomaticKeepAliveClientMixin {
    // スクロールクラス
  final ScrollController _scrollController = ScrollController();
  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  // 発売日フラグ
  int isReleased = 2;

  // 選択されたハードウェア
  String _choiceIndex = '';

  // 検索バー表示判定
  bool wasTapped = false;

  // 楽天apiから取得したゲーム情報
  List<GameInfoModel> games = [];
  // ゲーム情報を日付ごとにグループ化したもの
  Map<String, List<GameInfoModel>> groupGames = {};

  // アクティブなメニューid
  int activeMenuId = 0;

  // 取得するゲーム数
  int gameLimit = 40;
  // 取得するゲームの開始位置
  int gameOffset = 0;
  // 対象の総数
  int targetCount = 0;
  bool isPaging = true;

  //ローディング表示の状態
  bool visibleLoading = true;

  /// ハードウェア設定
  Future setHardware(String hardware) async {
    SharedPrefe.setTargetHardware(hardware);
  }

  void init() async {
    //  Widgetのビルドが終わったタイミングで呼ばれる
    // https://zuma-lab.com/posts/flutter-troubleshooting-called-during-build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _gameGetx.setLoading(true);

      // デバイスチェック
      var result = await DeviceInfo().getDeviceInfo();
      if (result) {
        await getGameList(true, false);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => alertBuilderForCupertino(
            context,
            '通信エラー',
            '通信エラーが起きました。時間を置いて接続してください。'
          )
        );
      }
      _gameGetx.setLoading(false);
    });
  }

  @override
  void initState() {
    super.initState();
    isReleased = widget.isReleased;
    init();

    // everでハードウェアの値を監視して、更新されたらapiを叩くために再描画する
    ever(_gameGetx.hardware, (_) => {
      if (mounted) {
        if (_gameGetx.isInitHardware.value) {
          setState(() {
            getGameList(true, true);
          }),
        } else {
          // 初回の空っぽのgameGetx.hardwareから、値がセットされた場合は、
          // 再描画(setState)してほしくないから、フラグを立てる
          // TODO: パワーコードだから修正したい
          _gameGetx.isInitHardware.value = true
        }
      }
    });
  }

  @override
  bool get wantKeepAlive => true;


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// これから発売するゲーム情報取得
  Future getGameList(bool isReset, bool chageHardware) async {
    _gameGetx.setLoading(true);

    await SharedPrefe.init();

    if (isReset) {
      games = [];
      groupGames = {};
      gameOffset = 0;
      isPaging = true;
      SharedPrefe.setIsPaging(true);
    }

    // 総数よりも大きくなったらreturnする
    if (targetCount != 0 && targetCount < gameOffset) {
      SharedPrefe.setIsPaging(false);
      _gameGetx.setLoading(false);
      return ;
    }

    _choiceIndex = SharedPrefe.getString('targetHardware');

    final gameTest = await ApiClient().getGameInfo(
        hardware: _gameGetx.hardware.value,
        limit: gameLimit,
        offset: gameOffset,
        isReleased: isReleased
    );

    if (!gameTest['game'].isEmpty) {
      targetCount = gameTest['game_count'];

      // games.addAll(gameTest['game']);

      // -----------TODO: のちに修正したい ここから-----------
      // 例えばPS4のゲーム一覧で、画面がスクロール状態の時に、PS5を選択すると、
      // 初回APIが2回叩かれてしまう事があるので、重複したものを省いている
      final gameIdList = games.map((e) => e.id);
      gameTest['game'].forEach((element) {
        if (!gameIdList.contains(element.id)) {
          // 含んでいなかったら追加する
          games.add(element);
        }
      });
      // -----------TODO: ここまで-----------

      final gameGroupTest = groupBy(games, (obj) => obj.salesDate);

      groupGames.addAll(gameGroupTest);
      gameOffset += gameLimit;

      // 参考: https://teratail.com/questions/286406
      setState(() {});
    }
    _gameGetx.setLoading(false);
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
        children: [
          // ハードウェア選択
          HardwareSelect(displayName: 'list'),
          // ゲーム一覧
          GameListInfinityView(
                contents: groupGames,
                getContents: getGameList,
          ),
          // バナー広告
          AdModBanner()
        ],
      );
  }
}


// -------------インフィニティスクロール-------------
class GameListInfinityView extends StatefulWidget {
  // ゲーム一覧
  final Map<String, List<GameInfoModel>> contents;
  // ゲームを取得する関数
  final Future<dynamic> Function(bool, bool) getContents;

  const GameListInfinityView({
    Key? key,
    required this.contents,
    required this.getContents,
  }) : super(key: key);

  @override
  State<GameListInfinityView> createState() => _GameListInfinityViewState();
}

class _GameListInfinityViewState extends State<GameListInfinityView> {
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
        await widget.getContents(false, false);
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
        itemBuilder: (context, groupIndex) {
          final salesDate = widget.contents.keys.elementAt(groupIndex);
          return Column(
            children: [
              Container(
                width: double.infinity,
                child: Card(
                  color: Colors.grey.shade300, // Card自体の色
                  margin: const EdgeInsets.all(3),
                  elevation: 2.0, // 影の離れ具合
                  child: Text(
                    salesDate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true, // ListView.builderをネストする時に指定 https://www.choge-blog.com/programming/flutterlistview-nest/
                physics: const NeverScrollableScrollPhysics(), // ListView.builderをネストする時に指定
                itemCount: widget.contents[salesDate]?.length,
                itemBuilder: (context, gameIndex) {
                  return GameCard(
                    game: widget.contents[salesDate]![gameIndex],
                    isDisplayDate: false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
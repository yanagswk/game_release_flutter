import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/common/system_widget.dart';
import 'package:share/share.dart';
import 'package:url_launcher/link.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:release/models/game_info.dart';
import 'package:release/common/device_info.dart';

import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


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
  // ゲーム詳細情報
  late GameInfoModel game;

  var loading = false;

  final _gameGetx = Get.put(GameGetx());

  String? _calenderId = "";
  String _calenderTitle = "";

  String _calenderYear = "2022";
  List<String> yearList = ["2022", "2023"];
  String _calenderMonth = "1";
  List<String> monthList = [];
  String _calenderDay = "1";
  List<String> dayList = [];

  String _calenderStartHour = "0";
  String _calenderEndHour = "0";
  List<String> hourList = [];

  String _calenderStartMinutes = "0";
  String _calenderEndMinutes = "0";
  List<String> minutesList = [];

  @override
  void initState() {
    super.initState();
    // 受け取ったgameを変数に設定
    game = widget.game;
    _calenderTitle = game.title;

    makeCalenderDataList();
    var salesDateSplit = game.salesDate.split(RegExp(r'[年月日]'));
    _calenderYear = salesDateSplit[0];
    _calenderMonth = salesDateSplit[1];
    _calenderDay = salesDateSplit[2];
  }

  void makeCalenderDataList() {
    for(int i = 0; i<=23; i++) {
      hourList.add(i.toString());
    }
    for(int i = 0; i<=59; i++) {
      minutesList.add(i.toString());
    }
    for(int i = 1; i<=12; i++) {
      monthList.add(i.toString());
    }
    for(int i = 1; i<=31; i++) {
      dayList.add(i.toString());
    }
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

  /// カレンダーにアクセスする (https://qiita.com/MLLB/items/984f1a5eed5d1c08d7ef)
  Future _calenderAccess() async {
    var _deviceCalendarPlugin = new DeviceCalendarPlugin();
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    // カレンダーアクセス許可
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        throw Exception("Not granted access to your calendar");
      }
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult?.data;
    if(calendars == null || calendars.isEmpty) {
      throw Exception("Can not get calendars");
    }

    var _defaultCalendar = calendars!
      .firstWhere((element) => element.isDefault ?? false);

    _calenderId = _defaultCalendar.id;

    if (_calenderId != null) {
      showModalBottomSheet(
        //モーダルの背景の色、透過
        backgroundColor: Colors.transparent,
        //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder:(context, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  //モーダル自体の色
                  color: Colors.white,
                  //角丸にする
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                            ),
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('戻る')
                          ),
                          Text(
                            'カレンダーに追加',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                            ),
                            onPressed: (){
                              addCalender();
                              Navigator.of(context).pop();
                            },
                            child: Text('追加'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('タイトル'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: TextEditingController(
                          text: _calenderTitle
                        )
                      ),
                    ),
                    Text('買う場所・説明・補足'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(controller: TextEditingController()),
                    ),
                    Text('日付選択'),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // 年
                            DropdownButton(
                              value: _calenderYear,
                              items: yearList.map((String year) =>
                                  DropdownMenuItem(
                                    value: year,
                                    child: Text('${year}年')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderYear = value!;
                                });
                              },
                            ),
                            // 月
                            DropdownButton(
                              value: _calenderMonth,
                              items: monthList.map((String month) =>
                                  DropdownMenuItem(
                                    value: month,
                                    child: Text('${month}月')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderMonth = value!;
                                });
                              },
                            ),
                            // 日
                            DropdownButton(
                              value: _calenderDay,
                              items: dayList.map((String day) =>
                                  DropdownMenuItem(
                                    value: day,
                                    child: Text('${day}日')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderDay = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // 時間
                            DropdownButton(
                              value: _calenderStartHour,
                              items: hourList.map((String hour) =>
                                  DropdownMenuItem(
                                    value: hour,
                                    child: Text('${hour}時')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderStartHour = value!;
                                });
                              },
                            ),
                            // 分
                            DropdownButton(
                              value: _calenderStartMinutes,
                              items: minutesList.map((String minutes) =>
                                  DropdownMenuItem(
                                    value: minutes,
                                    child: Text('${minutes}分')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderStartMinutes = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // 時間
                            DropdownButton(
                              value: _calenderEndHour,
                              items: hourList.map((String hour) =>
                                  DropdownMenuItem(
                                    value: hour,
                                    child: Text('${hour}時')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderEndHour = value!;
                                });
                              },
                            ),
                            // 分
                            DropdownButton(
                              value: _calenderEndMinutes,
                              items: minutesList.map((String minutes) =>
                                  DropdownMenuItem(
                                    value: minutes,
                                    child: Text('${minutes}分')
                                  )).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _calenderEndHour = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              );
            }
          );
        });
    }
  }

  ///カレンダーに追加する
  void addCalender() async {
    // ローカルロケーションのタイムゾーンを東京に設定
    setLocalLocation(getLocation("Asia/Tokyo")); 
    final event = Event(
      _calenderId,
      title: _calenderTitle,
      start: TZDateTime.local(
        int.parse(_calenderYear),
        int.parse(_calenderMonth),
        int.parse(_calenderDay),
        int.parse(_calenderStartHour),
        int.parse(_calenderStartMinutes),
      ),
      end: TZDateTime.local(
        int.parse(_calenderYear),
        int.parse(_calenderMonth),
        int.parse(_calenderDay),
        int.parse(_calenderEndHour),
        int.parse(_calenderEndMinutes),
      ),
    );
    final result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
    if(result == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'カレンダー追加失敗',
          'カレンダーの追加に失敗しました'
        )
      );
      return;
    }
    if(result.isSuccess){
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'カレンダー追加完了',
          'カレンダーに追加しました'
        )
      );
      return;
    }
    if(!result.hasErrors){
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'カレンダー追加失敗',
          'カレンダーの追加に失敗しました'
        )
      );
      return;
    }
    throw Exception(result.errors.join());
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
            child: Column(
              children: [
                Expanded(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: (){
                                _calenderAccess();
                              },
                              icon: Icon(Icons.calendar_today),
                              label: Text('カレンダー追加'),
                            ),
                            ElevatedButton.icon(
                              onPressed: (){
                              },
                              icon: Icon(Icons.notifications_active),
                              label: Text('通知を設定'),
                            ),
                            ElevatedButton.icon(
                              onPressed: (){
                                final share_msg = '${game.salesDate}に「${game.title}」が発売するよ！';
                                Share.share(share_msg);
                              },
                              icon: Icon(Icons.ios_share),
                              label: Text('SNS共有'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 内容紹介 TODO: デザイン
                        Text("内容紹介"),
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
                  ),
                ),
                // バナー広告
                AdModBanner()
              ],
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
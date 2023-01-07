import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get_navigation/src/routes/default_transitions.dart';
import 'package:release/api/api.dart';
import 'package:release/common/AdModBanner.dart';
import 'package:release/common/local_notification.dart';
import 'package:release/getx/game_getx.dart';
import 'package:release/models/notification.dart';
import 'package:release/widget/common/my_app_bar.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/common/system_widget.dart';
import 'package:release/widget/hardware_chip.dart';
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
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';



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

  // カレンダー用変数
  String? _calenderId = "";
  String _calenderTitle = "";
  String _calenderDescription = "";
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

  List<String> salesDateSplit = [];

  String tuuchiText = "";

  late DateTime sale_day;

  late DateTime startTime;
  late DateTime endTime;

  // 日付エラー
  bool isDateError = false;

  // 発売日が現在から見て将来の日付か
  bool isFuture = false;

  @override
  void initState() {
    super.initState();
    // 受け取ったgameを変数に設定
    game = widget.game;
    _calenderTitle = game.title;

    // 発売日が日付ではなく「11月中」とかの場合は、通知ボタンは表示しない
    if (!game.salesDate.contains("中")) {
      salesDateSplit = game.salesDate.split(RegExp(r'[年月日]'));
      _calenderYear = salesDateSplit[0];
      _calenderDay = salesDateSplit[2];
      // 月が"01"の場合は"1"のする
      if (salesDateSplit[1].contains("0")) {
        _calenderMonth = salesDateSplit[1].replaceAll("0", "");
      } else {
        _calenderMonth = salesDateSplit[1];
      }

      tuuchiText = game.isNotification ? "通知設定済" : "通知を設定";

      final now = DateTime.now(); // 現在の日付
      sale_day = DateTime(int.parse(_calenderYear), int.parse(_calenderMonth), int.parse(_calenderDay)); // 発売日

      startTime = DateTime(
        int.parse(_calenderYear),
        int.parse(_calenderMonth),
        int.parse(_calenderDay),
        0,
        0
      );
      endTime = DateTime(
        int.parse(_calenderYear),
        int.parse(_calenderMonth),
        int.parse(_calenderDay),
        0,
        0
      );

      setState(() {
        isFuture = now.isBefore(sale_day) ? true : false;
      });

    } else {
      // 「11月中」とかの場合
      sale_day = DateTime.now();
      _calenderYear = sale_day.year.toString();
      _calenderMonth = sale_day.month.toString();
      _calenderDay = sale_day.day.toString();
    }
  }

  // StatefulBuilderのsetState
  late void Function(void Function()) testSetState;

  ///カレンダーに追加する
  void addCalender() async {
    final start_date = TZDateTime.local(
        int.parse(_calenderYear),
        int.parse(_calenderMonth),
        int.parse(_calenderDay),
        int.parse(_calenderStartHour),
        int.parse(_calenderStartMinutes),
    );
    final end_date = TZDateTime.local(
        int.parse(_calenderYear),
        int.parse(_calenderMonth),
        int.parse(_calenderDay),
        int.parse(_calenderEndHour),
        int.parse(_calenderEndMinutes),
    );

    // 日付比較
    final dateCheck = start_date.compareTo(end_date);
    // 1の場合は、終了時間が開始時間よりも早い場合
    if (dateCheck == 1) {
      // ここでsetStateしても、StatefulBuilderだから？検知してくれない。testSetStateにStatefulBuilderで使っているsetStateを代入する。
      // setState(() {
      //   isDateError = true;
      // });
      testSetState(() {
        isDateError = true;
      });
      return;
    }
    testSetState(() {
      isDateError = false;
    });

    Navigator.of(context).pop();

    // ローカルロケーションのタイムゾーンを東京に設定
    setLocalLocation(getLocation("Asia/Tokyo"));
    final event = Event(
      _calenderId,
      title: _calenderTitle,
      description: _calenderDescription,
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
    if(result.hasErrors){
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'カレンダー追加失敗',
          'カレンダーの追加に失敗しました'
        )
      );
      print(result.errors[0].errorMessage);
      throw Exception();
      // return;
    }
    throw Exception(result.errors.join());
  }

  /// ゲームをお気に入り登録する/解除する
  /// https://qiita.com/mamoru_takami/items/2d930ee927c048060741
  Future<void> favoriteGame(int gameId, bool doFavorite) async {
    // _gameGetx.setLoading(true);

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

        if (game.isDisplay != null && game.isDisplay!) {
          game.isDisplay = !game.isDisplay!;
        }
      });
    }
    // _gameGetx.setLoading(false);
  }

  /// カレンダーにアクセスする (https://qiita.com/MLLB/items/984f1a5eed5d1c08d7ef)
  Future _calenderAccess() async {
    var _deviceCalendarPlugin = new DeviceCalendarPlugin();
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();

    // カレンダーアクセス許可
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();

      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        // throw Exception("Not granted access to your calendar");
        // カレンダーへのアクセスを拒否したとき
        print("カレンダーへのアクセスが拒否されてます");
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) => alertBuilderForCupertino(
        //     context,
        //     'カレンダーのアクセス許可してください',
        //     'カレンダーのアクセスがオフになっています。\n設定アプリからカレンダーのアクセスを許可してください。'
        //   )
        // );
        return;
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
                child: Padding(
                  // padding: const EdgeInsets.all(2.0),
                  padding: const EdgeInsets.symmetric(horizontal:20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
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
                                // addCalender()内で、setStateできないから、
                                // StatefulBuilderのsetStateを使うために、変数に代入する
                                testSetState = setState;
                                addCalender();
                              },
                              child: Text('追加'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'タイトル',
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextField(
                        controller: TextEditingController(text: _calenderTitle),  //ここに初期値
                        onChanged: (value) {
                          _calenderTitle = value;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'メモ',
                        style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      TextFormField(
                        controller: TextEditingController(text: _calenderDescription),
                        onChanged: (value) {
                          _calenderDescription = value;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '日付',
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextButton(
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(2022, 1, 1,11,22),
                                maxTime: DateTime(2023, 12, 31, 11, 22),
                                onChanged: (date) {
                                  // ドラムスクロールで日付を変更した場合に検知。完了ボタンを押してなくても検知する。
                                  print('change $date');
                                },
                                onConfirm: (date) {
                                  // 日付を変更して完了ボタンを押したら検知
                                  setState(() {
                                    _calenderYear = date.year.toString();
                                    _calenderMonth = date.month.toString();
                                    _calenderDay = date.day.toString();
                                    sale_day = DateTime(date.year, date.month, date.day);
                                  });
                                },
                                currentTime: sale_day,
                                locale: LocaleType.jp
                              );
                            },
                            child: const Text(
                              '選択する',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      Text("${_calenderYear}年${_calenderMonth}月${_calenderDay}日"),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '開始時間',
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextButton(
                            onPressed: () {
                                DatePicker.showTimePicker(context,
                                showTitleActions: true,
                                showSecondsColumn: false, // 「秒」を表示するか 初期値true
                                onConfirm: (date) {
                                  // 時間を変更して完了ボタンを押したら検知
                                  setState(() {
                                    _calenderStartHour = date.hour.toString();
                                    _calenderStartMinutes = date.minute.toString();
                                    startTime = DateTime(date.year, date.month, date.day, date.hour, date.minute);
                                  });
                                },
                                currentTime: startTime,
                                locale: LocaleType.jp
                              );
                            },
                            child: const Text(
                              '選択する',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      Text("${_calenderStartHour}時${_calenderStartMinutes}分"),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '終了時間',
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextButton(
                            onPressed: () {
                                DatePicker.showTimePicker(context,
                                showTitleActions: true,
                                showSecondsColumn: false, // 「秒」を表示するか 初期値true
                                onConfirm: (date) {
                                  // 時間を変更して完了ボタンを押したら検知
                                  setState(() {
                                    _calenderEndHour = date.hour.toString();
                                    _calenderEndMinutes = date.minute.toString();
                                    endTime = DateTime(date.year, date.month, date.day, date.hour, date.minute);
                                  });
                                },
                                currentTime: endTime,
                                locale: LocaleType.jp
                              );
                            },
                            child: const Text(
                              '選択する',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      Text("${_calenderEndHour}時${_calenderEndMinutes}分"),
                      isDateError
                        ? Text(
                          "開始時間は、終了時間よりも前に設定してください。",
                          style: TextStyle(
                            color: Colors.red
                          ),
                        )
                        : const SizedBox(),
                    ],
                  ),
                )
              );
            }
          );
        });
    }
  }




  // ローカルの通知を設定
  void _settingLocalNotification() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('通知設定'),
          content: Text('発売日「${game.salesDate} 0時」に通知しますか？'),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('設定する'),
              onPressed: () {
                //  通知
                _setNotification();
              },
            ),
          ],
        );
      }
    );
  }

  late NotificationModel notification;

  // 通知設定
  Future _setNotification() async {
    // 通知登録api叩く
    notification = await ApiClient().notificationRegister(game.id);

    LocalNotification().requestIOSPermission();
    LocalNotification().initializePlatformSpecifics();
    LocalNotification().scheduleNotification(
      salesDateSplit,
      game.title,
      notification.notificationId
    );

    LocalNotification().getPendingNotificationCount().then((value) =>
      print('getPendingNotificationCount:' + value.toString())
    );

    setState(() {
      tuuchiText = "通知設定済";
      game.isNotification = true;
      game.notificationId = notification.notificationId;
    });

    Navigator.pop(context);
  }


  /// 通知チェック
  void _notificationRegister() async {

    // 通知設定チェック
    var isNotification = await LocalNotification().checkNotification();

    if (!isNotification) {
      showDialog(
        context: context,
        builder: (BuildContext context) => alertBuilderForCupertino(
          context,
          'アプリの通知を許可してください',
          'アプリの通知がオフになっています。\n設定アプリからこのアプリの通知を許可してください。'
        )
      );
      return;
    }
    _settingLocalNotification();
  }


  /// 通知キャンセル
  void _notificationCancel() async {
    if (game.notificationId == null) {
      print("通知idありませぬ");
      return;
    }
    await ApiClient().notificationCancel(game.id, game.notificationId!);

    setState(() {
      tuuchiText = "通知を設定";
      game.isNotification = false;
    });
    // 通知キャンセル
    LocalNotification().cancelNotification(game.notificationId!);
    print("通知キャンセルしやした 通知id: ${game.notificationId}");
  }

  int activeIndex = 0;

  /// 画像スライドショーのインジケーター
  Widget buildIndicator() => AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: game.imageList.length,
    effect: const JumpingDotEffect(
      dotHeight: 10,
      dotWidth: 10,
      activeDotColor: Colors.blue,
      dotColor: Colors.black12),
  );

  /// 画像表示部分
  Widget buildImage(path, index) => Container(
    //画像間の隙間
    margin: EdgeInsets.symmetric(horizontal: 13),
    color: Colors.white,
    child: Image.network(
      game.imageList[index],
      errorBuilder: (c, o, s) {
        return const Icon(
          Icons.downloading,
          color: Colors.grey,
        );
      },
    ),
  );

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
                                    HardwareChip(hardware: game.hardware),
                                    const SizedBox(height: 5),
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CarouselSlider.builder(
                              options: CarouselOptions(
                                height: 350,
                                initialPage: 0,
                                viewportFraction: 1,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) => setState(() {
                                  activeIndex = index;
                                }),
                              ),
                              itemCount: game.imageList.length,
                              itemBuilder: (context, index, realIndex) {
                                final path = game.imageList[index];
                                return buildImage(path, index);
                              },
                            ),
                            SizedBox(height: 20),
                            buildIndicator()
                          ],
                        ),
                        // 値段、評価点
                        Container(
                          margin: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
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
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton( // お気に入りアイコン
                                    icon: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Icon(
                                        game.isFavorite ? Icons.favorite : Icons.favorite_border,//追加
                                        color: game.isFavorite ? Colors.red : null,//追
                                      ),
                                    ),
                                    onPressed: () {
                                      // お気に入りapiを叩く
                                      favoriteGame(game.id, game.isFavorite);
                                    }
                                  ),
                                  isFuture ?
                                  IconButton( // 通知アイコン
                                    icon: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Icon(
                                        game.isNotification ? Icons.notifications_active : Icons.notifications_none,//追加
                                        color: game.isNotification ? Colors.red : null,//追
                                      ),
                                    ),
                                    onPressed: () {
                                      // 通知設定or通知キャンセル
                                      // game.isNotification ? _notificationCancel() : _settingLocalNotification();
                                      game.isNotification ? _notificationCancel() : _notificationRegister();
                                    }
                                  ) : const SizedBox(),

                                  IconButton( // カレンダー追加
                                    icon: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Icon(Icons.calendar_today),
                                    ),
                                    onPressed: () {
                                      // カレンダー追加
                                      _calenderAccess();
                                    }
                                  ),
                                  IconButton( // SNS共有
                                    icon: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Icon(Icons.ios_share),
                                    ),
                                    onPressed: () {
                                      // SNS共有
                                      final share_msg = '${game.title} \n ${game.affiliateUrl}';
                                      Share.share(share_msg);
                                    }
                                  ),
                                ],
                              ),
                              Center(
                                child: SizedBox(
                                  width: 350,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white
                                    ),
                                    onPressed: () {
                                      final url = Uri.parse(game.affiliateUrl);
                                      launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,   // デフォルトのブラウザで開く(参考: https://zenn.dev/tsuruo/articles/56f3abbb132f90)
                                      );
                                    },
                                    child: Text(
                                      'Rakutenで購入',
                                      style: TextStyle(fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "内容紹介",
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(game.itemCaption),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // バナー広告
                AdModBanner()

                // onPressed: openLink,
              ],
            )
          ),
        ),
        Obx( // getxで検知するように
          // 全画面ローディング
          () => OverlayLoadingMolecules(
            visible: _gameGetx.isLoading.value,
            isLoading: true
          )
        ),
      ]
      ),
    );
  }
}
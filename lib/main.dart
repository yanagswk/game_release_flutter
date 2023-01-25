import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:release/common/local_notification.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/game_article.dart';
import 'package:release/game_article_site.dart';
import 'package:release/game_detail.dart';
import 'package:release/game_favorite.dart';
import 'package:release/game_list.dart';
import 'package:release/game_release_group.dart';
import 'package:release/home_page.dart';
import 'package:release/widget/common/overlay_loading_molecules.dart';
import 'package:release/widget/game_card.dart';
import 'package:release/widget/hardware_select.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import "package:collection/collection.Dart";

import 'package:release/models/game_info.dart';
import 'package:release/api/api.dart';
import 'package:release/common/device_info.dart';

import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:release/widget/search_bar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InitWidget(),
    );
  }
}

class InitWidget extends StatefulWidget {
  const InitWidget({
    super.key,
  });

  @override
  State<InitWidget> createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {

  final controller = PageController();

  // ローカル通知用
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  // アクティブ画面id
  int _activeMenuId = 0;

    //ローディング表示の状態
  bool visibleLoading = true;

  // ボトムナビゲーション遷移画面一覧
  final _screens = [
    // ホーム画面
    const HomePage(),
    // 検索画面
    const SearchBar(),
    // お気に入り画面
    const GameFavoritePage(),
    // ニュース記事画面
    // const GameArticle(),
    const GameArticleSite(),
  ];

  Future init() async {
    await SharedPrefe.init();
    setState(() {
      // ハードウェア初期値をGetxに保存
      _gameGetx.hardware.value = SharedPrefe.getTargetHardware();
      // _gameGetx.searchHardware.value = SharedPrefe.getSearchTargetHardware();
    });
  }

  // トラッキング表示
  Future<void> initPlugin() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  @override
    // 最初に一度だけ呼ばれる
  void initState() {
    super.initState();

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));

    LocalNotification().requestIOSPermission();
    init();
    initPlugin();
  }
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack( // ウェジェットを重ねる事ができる
        fit: StackFit.expand,
        children: [
          Scaffold(
            body: PageView(
              controller: controller,
              children: _screens,
              onPageChanged: (index) {
                setState(() {
                  _activeMenuId = index;
                });
              },
            ),
            // ボトムナビゲーション
            bottomNavigationBar: SizedBox(
              child: Container(
                height:  MediaQuery.of(context).size.height * 0.085,
                child: Wrap(
                  children: [
                    BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      onTap: (index) => {
                        controller.jumpToPage(index),
                        setState(() => _activeMenuId = index)
                      },
                      currentIndex: _activeMenuId,
                      selectedItemColor: Colors.blue[800],
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.gamepad),
                          label: 'ゲーム',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.search),
                          label: '探す',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: 'お気に入り',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.article),
                          label: 'ニュース',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
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
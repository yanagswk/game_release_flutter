import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:release/common/local_notification.dart';
import 'package:release/common/shared_preferences.dart';
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
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


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
    // お気に入り画面
    const GameFavoritePage(),
  ];

  Future init() async {
    await SharedPrefe.init();
    setState(() {
      // ハードウェア初期値をGetxに保存
      _gameGetx.hardware.value = SharedPrefe.getTargetHardware();
    });
  }


  @override
    // 最初に一度だけ呼ばれる
  void initState() {
    super.initState();
    
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));
    init();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack( // ウェジェットを重ねる事ができる
        fit: StackFit.expand,
        children: [
          Scaffold(
            body: _screens[_activeMenuId],
            // ボトムナビゲーション
            bottomNavigationBar: BottomNavigationBar(
              onTap: (index) => {
                // 画面更新
                setState(() => _activeMenuId = index)
              },
              currentIndex: _activeMenuId,
              selectedItemColor: Colors.blue[800],
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'お気に入り',
                ),
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
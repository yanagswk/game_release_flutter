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

  // ?????????????????????
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Getx????????????
  final _gameGetx = Get.put(GameGetx());

  // ?????????????????????id
  int _activeMenuId = 0;

    //?????????????????????????????????
  bool visibleLoading = true;

  // ????????????????????????????????????????????????
  final _screens = [
    // ???????????????
    const HomePage(),
    // ????????????
    const SearchBar(),
    // ?????????????????????
    const GameFavoritePage(),
    // ????????????????????????
    // const GameArticle(),
    const GameArticleSite(),
  ];

  Future init() async {
    await SharedPrefe.init();
    setState(() {
      // ??????????????????????????????Getx?????????
      _gameGetx.hardware.value = SharedPrefe.getTargetHardware();
      // _gameGetx.searchHardware.value = SharedPrefe.getSearchTargetHardware();
    });
  }

  // ????????????????????????
  Future<void> initPlugin() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  @override
    // ?????????????????????????????????
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
      child: Stack( // ?????????????????????????????????????????????
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
            // ??????????????????????????????
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
                          label: '?????????',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.search),
                          label: '??????',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: '???????????????',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.article),
                          label: '????????????',
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Obx( // getx????????????????????????
            // ???????????????????????????
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
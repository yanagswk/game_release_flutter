import 'package:flutter/material.dart';
import "package:collection/collection.Dart";
import 'package:release/common/shared_preferences.dart';

import 'package:release/api/api.dart';
import 'package:release/game_list.dart';
import 'package:release/main.dart';
import 'package:release/models/game_info.dart';
import 'package:release/widget/common/drawer_widget.dart';
import 'package:release/widget/game_card.dart';
import 'package:release/widget/hardware_select.dart';

import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';
import 'package:release/widget/search_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  var _tabIndex = 0;
  TabController? _tabController;

  // 検索画面判定
  bool _isSearchMood = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(() {
      // TabBar変更時の処理

      // addListenerが2回呼ばれるやつ
      // https://github.com/flutter/flutter/issues/13848
      // https://stackoverflow.com/questions/60252355/tabcontroller-listener-called-multiple-times-how-does-indexischanging-work
      if(!_tabController!.indexIsChanging) {
        setState(() {
          _tabIndex = _tabController!.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(95.0),
        child: AppBar(
          backgroundColor: Colors.blue[800],
          title: const Text(
            "ゲーム発売日",
            style: TextStyle(
              color: Colors.white
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: ColoredBox(
              color: Colors.white,
              child: TabBar(
                controller: _tabController ,
                tabs: [
                  Tab(
                    child: Text(
                      "これから発売",
                      style: TextStyle(
                        color: _tabIndex == 0 ? Colors.blue[800] : Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "発売済み",
                      style: TextStyle(
                        color: _tabIndex == 1 ? Colors.blue[800] : Colors.grey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      drawer: const DrawerWidget(), // サイドバー
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: TabBarView( // タブによって表示を切り替える
            controller: _tabController,
            children: [
              // これから発売
              GameList(isReleased: 2),
              // 発売済み
              GameList(isReleased: 1),
          ],
        ),
      )
    );
  }
}

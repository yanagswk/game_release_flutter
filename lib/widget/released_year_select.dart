import 'package:flutter/material.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';

/// ハードウェア選択用のウェジェット
class ReleasedYearSelect extends StatefulWidget {

  // 画面名
  // String displayName;

  ReleasedYearSelect({
    super.key,
    // required this.displayName
  });
  @override
  State<ReleasedYearSelect> createState() => _ReleasedYearSelectState();
}

class _ReleasedYearSelectState extends State<ReleasedYearSelect> {

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  String _hardware = "";

  ///初期処理
  // Future init() async {
  //   await SharedPrefe.init();
  //   setState(() {
  //     if (widget.displayName == "search") {
  //       _hardware = _gameGetx.searchHardware.value;
  //     } else {
  //       // ハードウェア初期値をGetxに保存
  //       _hardware = _gameGetx.hardware.value;
  //     }
  //   });
  // }

  void setHardWare(hardware) {
    // if (widget.displayName == "search") {
    //   _gameGetx.setSearchHardware(hardware);
    //   _hardware = hardware;
    // } else {
    //   _gameGetx.setHardware(hardware);
    //   _hardware = hardware;
    // }
  }

  @override
  void initState() {
    super.initState();
    // init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  children: [
                    ActionChip(
                      label: Text(
                        "2023年",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        print("クリック");
                      }
                    ),
                    ActionChip(
                      label: Text(
                        "2022年",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        print("クリック");
                      }
                    ),
                    ActionChip(
                      label: Text(
                        "2021年",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        print("クリック");
                      }
                    ),
                    ActionChip(
                      label: Text(
                        "2020年",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        print("クリック");
                      }
                    ),
                    ActionChip(
                      label: Text(
                        "2019年",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        print("クリック");
                      }
                    ),
                    ActionChip(
                      label: Text(
                        "2018年",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                      backgroundColor: Colors.grey[500],
                      onPressed:() {
                        print("クリック");
                      }
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
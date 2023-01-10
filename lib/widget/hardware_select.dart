import 'package:flutter/material.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';

/// ハードウェア選択用のウェジェット
class HardwareSelect extends StatefulWidget {

  // 画面名
  String displayName;

  HardwareSelect({
    super.key,
    required this.displayName
  });
  @override
  State<HardwareSelect> createState() => _HardwareSelectState();
}

class _HardwareSelectState extends State<HardwareSelect> {

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  String _hardware = "";

  ///初期処理
  Future init() async {
    await SharedPrefe.init();
    setState(() {
      if (widget.displayName == "search") {
        _hardware = _gameGetx.searchHardware.value;
      } else {
        // ハードウェア初期値をGetxに保存
        _hardware = _gameGetx.hardware.value;
      }
    });
  }

  void setHardWare(hardware) {
    if (widget.displayName == "search") {
      _gameGetx.setSearchHardware(hardware);
      _hardware = hardware;
    } else {
      _gameGetx.setHardware(hardware);
      _hardware = hardware;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(3.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                  child: Wrap(
                    spacing: 10,
                    children: [
                      // TODO: ListView.Builder使う
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                        visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                        label: const Text(
                          "全機種",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        selected: _hardware == 'All',
                        backgroundColor: Colors.grey[500],
                        selectedColor: Colors.black,
                        onSelected: (_) {
                          setState(() {
                            setHardWare('All');
                          });
                        },
                      ),
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                        visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                        label: const Text(
                          "Switch",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        selected: _hardware == "Switch",
                        backgroundColor: Colors.grey[500],
                        selectedColor: Colors.red,
                        onSelected: (_) {
                          setState(() {
                            setHardWare('Switch');
                          });
                        },
                      ),
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                        visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                        label: const Text(
                          "PS5",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        selected: _hardware == "PS5",
                        backgroundColor: Colors.grey[500],
                        selectedColor: Colors.blue,
                        onSelected: (_) {
                          setState(() {
                            setHardWare('PS5');
                          });
                        },
                      ),
                      ChoiceChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 追加：上下の余計なmarginを削除
                        visualDensity: VisualDensity(horizontal: 0.0, vertical: -1), // 追加：文字上下の多すぎるpaddingを調整
                        label: const Text(
                          "PS4",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        selected: _hardware == 'PS4',
                        backgroundColor: Colors.grey[500],
                        selectedColor: Colors.cyan,
                        onSelected: (_) {
                          setState(() {
                            setHardWare('PS4');
                          });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
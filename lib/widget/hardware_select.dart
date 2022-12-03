import 'package:flutter/material.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';

/// ハードウェア選択用のウェジェット
class HardwareSelect extends StatefulWidget {
  const HardwareSelect({super.key});
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
      // ハードウェア初期値をGetxに保存
      _hardware = _gameGetx.hardware.value;
    });
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
                    // TODO: ListView.Builder使う
                    ChoiceChip(
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
                          _gameGetx.setHardware('All');
                          _hardware = 'All';
                        });
                      },
                    ),
                    ChoiceChip(
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
                          _gameGetx.setHardware('Switch');
                          _hardware = 'Switch';
                        });
                      },
                    ),
                    ChoiceChip(
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
                          _gameGetx.setHardware('PS5');
                          _hardware = 'PS5';
                        });
                      },
                    ),
                    ChoiceChip(
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
                          _gameGetx.setHardware('PS4');
                          _hardware = 'PS4';
                        });
                      },
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
import 'dart:ffi';
import 'package:flutter/material.dart';

class HardwareChip extends StatefulWidget {

  // ハードウェア
  String hardware;
  
  HardwareChip({
    super.key,
    required this.hardware
  });

  @override
  State<HardwareChip> createState() => _HardwareChipState();
}

class _HardwareChipState extends State<HardwareChip> {

  // ハードウェア
  late String hardware;

    @override
  void initState() {
    super.initState();

    hardware = widget.hardware;
  }

  /// ハードウェアによって色を返却
  Color getHardwareColor(String target) {
    if (target == 'Switch') {
      return Colors.red;
    } else if (target == 'PS4') {
      return Colors.cyan;
    } else if (target == 'PS5') {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:25,
      width:50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getHardwareColor(hardware),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
          hardware,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        )
      
    );
  }
}
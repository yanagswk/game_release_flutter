import 'dart:ffi';
import 'package:flutter/material.dart';

class ItemChip extends StatefulWidget {

  // ハードウェア
  String hardware;
  bool? isShadow;
  double? width;

  ItemChip({
    super.key,
    required this.hardware,
    this.isShadow,
    this.width
  });

  @override
  State<ItemChip> createState() => _ItemChipState();
}

class _ItemChipState extends State<ItemChip> {

  late bool isShadow;

    @override
  void initState() {
    super.initState();

    isShadow = widget.isShadow ?? false;
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
      height:30,
      width: widget.width,
      padding: const EdgeInsets.only(top: 5, right: 10, bottom: 5, left: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getHardwareColor(widget.hardware),
        borderRadius: BorderRadius.circular(30),
        
        boxShadow: isShadow ? [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1.0,
            blurRadius: 15.0,
            offset: Offset(10, 10),
          ),
        ] : []
      ),
      child: Text(
          widget.hardware,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500
          ),
        )
    );
  }
}
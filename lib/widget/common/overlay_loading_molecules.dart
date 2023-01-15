import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//
// 全面表示のローディング
//
class OverlayLoadingMolecules extends StatelessWidget {

  late bool isLoading;

  OverlayLoadingMolecules({
    required this.visible,
    required this.isLoading,
  });

  //表示状態
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return visible
        ? Container(
            decoration: new BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                ?
                CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)
                )
                :
                const SizedBox()
              ],
            ),
          )
        : Container();
  }
}
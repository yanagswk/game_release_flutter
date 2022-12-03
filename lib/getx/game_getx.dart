import 'dart:ffi';

import 'package:release/common/shared_preferences.dart';
import 'package:get/get.dart';

class GameGetx extends GetxController {

  // 選択されたハードウェア
  RxString hardware = ''.obs;

  // お気に入り検知
  RxBool isFavorite = false.obs;

  // 初回ハードウェア設定フラグ
  RxBool isInitHardware = false.obs;

  // ローディングフラグ
  RxBool isLoading = false.obs;
  // RxBool isLoading = true.obs;

  // デバイスチェックフラグ
  RxBool isDeviceCheck = false.obs;



  /// ハードウェア更新
  void setHardware(String target) async {
    hardware.value = target;
    SharedPrefe.setTargetHardware(target);
  }

  void trueFavorite() async {
    isFavorite.value = true;
  }
  void falseFavorite() async {
    isFavorite.value = false;
  }

  void setLoading(bool status) async {
    isLoading.value = status;
  }
  // void falseFavorite() async {
  //   isFavorite.value = false;
  // }


}
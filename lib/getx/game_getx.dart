import 'dart:ffi';

import 'package:release/common/shared_preferences.dart';
import 'package:get/get.dart';

class GameGetx extends GetxController {

  // 選択されたハードウェア(一覧画面)
  RxString hardware = ''.obs;
  // 選択されたハードウェア(検索画面)
  RxString searchHardware = ''.obs;

  // お気に入り検知
  RxBool isFavorite = false.obs;

  // 初回ハードウェア設定フラグ
  RxBool isInitHardware = false.obs;

  // ローディングフラグ
  RxBool isLoading = false.obs;

  RxBool isSearchLoading = false.obs;

  // デバイスチェックフラグ
  RxBool isDeviceCheck = false.obs;

  // アプリバージョン
  String appVersion = "";



  /// ハードウェア更新
  void setHardware(String target) async {
    hardware.value = target;
    SharedPrefe.setTargetHardware(target);
  }
  /// ハードウェア更新
  void setSearchHardware(String target) async {
    searchHardware.value = target;
    // SharedPrefe.setSearchTargetHardware(target);
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
  void setSearchLoading(bool status) async {
    isSearchLoading.value = status;
  }
  // void falseFavorite() async {
  //   isFavorite.value = false;
  // }


}
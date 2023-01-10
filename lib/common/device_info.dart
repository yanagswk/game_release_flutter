import 'package:device_info/device_info.dart';
import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:release/api/api.dart';
import 'package:release/common/shared_preferences.dart';
import 'package:release/getx/game_getx.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


// final deviceIdProvider = StateProvider((ref) => '');

class DeviceInfo {

  // // デバイスID
  // String deviceId = "";

  // Getx読み込み
  final _gameGetx = Get.put(GameGetx());

  /// デバイスID取得して、登録されていない場合は、登録する
  Future getDeviceInfo() async {

    // デバイスチェックしていたら、returnする
    if (_gameGetx.isDeviceCheck.value) {
      return true;
    }

    // デバイスID
    String deviceId = "";
    final deviceInfo = DeviceInfoPlugin();

    if(Platform.isAndroid) {
    // Android のとき
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.androidId;

    } else if(Platform.isIOS) {
    // iOSのとき
      final iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor;

      final packageInfo = await PackageInfo.fromPlatform();
      // print(packageInfo.appName);
      // print(packageInfo.version);
      // print(packageInfo.buildNumber);
      _gameGetx.appVersion = packageInfo.version;
    }

    var result = await ApiClient().registerDeviceInfo(deviceId);

    if (result) {
      // デバイスチェックしたらフラグを立てる
      _gameGetx.isDeviceCheck.value = true;
    }
    return result;
  }
}
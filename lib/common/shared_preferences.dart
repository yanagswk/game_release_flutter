import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefe {
  
  static SharedPreferences? prefs;


  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  } 


  static String getString(String key) {
    return prefs!.getString(key) ?? "";
  } 


  /// ハードウェア設定
  static void setTargetHardware(String hardware) {
    prefs!.setString('targetHardware', hardware);
  }


  /// ハードウェア取得
  static String getTargetHardware() {
    return prefs!.getString('targetHardware') ?? "All";
  }


  /// デバイスid設定
  static void setDeviceId(String id) {
    prefs!.setString('deviceId', id);
  }


  /// デバイスid取得
  static String getDeviceId() {
    return prefs!.getString('deviceId') ?? "";
  }


  /// ページングフラグ設定
  static void setIsPaging(bool isPaging) {
    prefs!.setBool('isPaging', isPaging);
  }


  /// ページングフラグ取得
  static bool getIsPaging() {
    return prefs!.getBool('isPaging') ?? false;
  }



}
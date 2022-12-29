import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 参考
// https://take424.dev/2021/05/22/flutter%E3%81%A7%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E9%80%9A%E7%9F%A5%E3%81%AE%E5%8B%95%E4%BD%9C%E3%82%92%E7%A2%BA%E8%AA%8D%E3%81%99%E3%82%8B%EF%BC%8Fflutter_local_notifications/

class LocalNotification {
    // ローカル通知
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// パーミッション取得ダイアログの表示
  void requestIOSPermission() {
    final iosPermission = _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPermission != null) {
        iosPermission.requestPermissions(
          alert: false,
          badge: true,
          sound: false,
        );

        print("押されたよ！ 1");
    }
  }


  /// 通知OS初期設定
  void initializePlatformSpecifics() {
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // your call back to the UI
      },
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // 通知をタップしたときに発火する
        onDidReceiveNotificationResponse: (NotificationResponse res) {
          // debugPrint('payload:${res.payload}');
          print("押されたよ！ 2");
        });
  }


  /// すぐ通知
  Future<void> showNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifics = DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Test Title', // Notification Title
      'Test Body', // Notification Body, set as null to remove the body
      platformChannelSpecifics,
      payload: 'New Payload', // Notification Payload
    );
  }


  /// 指定時間に通知する
  Future<void> scheduleNotification(List<String> dateList, String title, int number) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      channelDescription: "CHANNEL_DESCRIPTION 1",
      icon: 'app_icon',
      //sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );

    var iosChannelSpecifics = DarwinNotificationDetails(
      //sound: 'my_sound.aiff',
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      number,
      "ゲーム発売日になりました",
      "「${title}」が発売しました",
      tz.TZDateTime.from(
        DateTime(
          int.parse(dateList[0]),
          int.parse(dateList[1]),
          int.parse(dateList[2]),
          0,
          0
        ),
        // DateTime(2022,12,17,14,06),
        tz.local
      ),
      platformChannelSpecifics,
      payload: 'Test Payload',  // 通知をタップした時、onDidReceiveNotificationResponseに送信される値
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// ローカル通知キャンセル
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }


  // 予約済みのローカル通知の数を取得する
  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }
  // 呼び出し方
  // LocalNotification().getPendingNotificationCount().then((value) =>
  //                 print('getPendingNotificationCount:' + value.toString())
  //               );


}

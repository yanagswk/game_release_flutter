import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

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
    }
  }


  /// 通知設定を許可しているか
  /// https://halzoblog.com/error-bug-diary/20220506-2/#:~:text=%E9%80%9A%E7%9F%A5%E8%A8%B1%E5%8F%AF%E7%A2%BA%E8%AA%8D%E3%81%AE%E3%83%80%E3%82%A4%E3%82%A2%E3%83%AD%E3%82%B0,%E8%B5%B7%E5%8B%95%E6%99%82%E3%81%AB%E7%99%BA%E5%8B%95%E3%81%95%E3%82%8C%E3%82%8B%E3%80%82&text=Permission.notification.request()%3B
  Future checkNotification() async {
    // permission_handler で通知に対する許可状態を把握
    var statusForNotificationO = await Permission.notification.status;

    print("statusForNotificationO: $statusForNotificationO");

    // PermissionStatus.granted: 許可している PermissionStatus.denied: 許可していない
    return statusForNotificationO == PermissionStatus.granted ? true : false;
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
          print("bbbbbbbbbb");
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
      "「${title}」の発売日になりました",
      tz.TZDateTime.from(
        DateTime(
          int.parse(dateList[0]),
          int.parse(dateList[1]),
          int.parse(dateList[2]),
          0,
          0
        ),
        // DateTime(2023,1,22,15,40),
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

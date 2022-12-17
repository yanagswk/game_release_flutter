

class NotificationModel {

  /// 通知id
  final int notificationId;

  NotificationModel({
    required this.notificationId,
  });

  // factory NotificationModel.fromMap(Map<String, dynamic> map) {
  //   return NotificationModel(
  //     notificationId: map['notification_id'],
  //   );
  // }
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notification_id'],
    );
  }

}
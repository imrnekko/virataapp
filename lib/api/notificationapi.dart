import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future notificationDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            channelDescription: 'channelDesc',
            priority: Priority.high,
            importance: Importance.max),
        iOS: IOSNotificationDetails());
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await notificationDetails(),
        payload: payload,
      );
}

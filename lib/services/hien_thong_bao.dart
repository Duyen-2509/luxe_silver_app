import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class NotificationService {
  static final Set<int> _notifiedThongBaoIds = {};

  static Future<void> showLocalNotification(
    int idTb,
    String title,
    String body,
  ) async {
    if (_notifiedThongBaoIds.contains(idTb)) return;
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel_id',
          'Thông báo',
          channelDescription: 'Kênh thông báo chung',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      idTb,
      title,
      body,
      platformChannelSpecifics,
    );
    _notifiedThongBaoIds.add(idTb);
  }

  static void clearCache() {
    _notifiedThongBaoIds.clear();
  }
}

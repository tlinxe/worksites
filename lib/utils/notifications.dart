import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:worksites/main.dart';
import 'package:worksites/utils/date_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:worksites/utils/theme.dart';

const String channelId = 'com.fixiply.ucb';

class Notifications {
  static final Notifications _instance = Notifications();

  static Notifications get instance => _instance;

  Future<void> showNotification(int id, String title, {String? body, String? payload, String? scheduled}) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        channelId, 'Notification',
        playSound: true,
        enableLights: true,
        color: primaryColor,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ucb');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    if (scheduled != null && scheduled.length > 0) {
      var date = DateHelper.parse(scheduled);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(date!, tz.local),
        platformChannelSpecifics,
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
      );
    } else {
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload
      );
    }
  }

  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}


import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationServices {
  static Future<void> showNotification(
      {required RemoteMessage remoteMessage}) async {
    Random random = Random();
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: random.nextInt(1000000),
          channelKey: 'high_importance_channel',
          largeIcon: remoteMessage.data["photo"],
          title: remoteMessage.data["name"],
          body: 'Incoming Video Call',
          autoDismissible: false,
          category: NotificationCategory.Call,
          notificationLayout: NotificationLayout.Default,
          locked: true,
          wakeUpScreen: true,
          backgroundColor: Colors.transparent,
          payload: {
            "user": remoteMessage.data["user"],
            "id": remoteMessage.data["id"],
            "name": remoteMessage.data["name"],
            "photo": remoteMessage.data["photo"],
            "email": remoteMessage.data["email"],
            "channel": remoteMessage.data["channel"],
            "caller": remoteMessage.data["caller"],
            "called": remoteMessage.data["called"],
            "active": remoteMessage.data["active"],
            "accepted": remoteMessage.data["accepted"],
            "connected": remoteMessage.data["connected"],
            "rejected": remoteMessage.data["rejected"],
          }),
    );
  }
}

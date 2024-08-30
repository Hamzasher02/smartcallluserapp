import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
// Dart imports:
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Utils {
  static int appId = 458978193; // enter your id
  static String appSignin =
      "972ca61ea7631b4b476eb4b4828c5e131dc0cbb2f52a57a9d5d08a5aaab066e9";
      Future<String> getUniqueUserId() async {
  String? deviceID;
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final iosDeviceInfo = await deviceInfo.iosInfo;
    deviceID = iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    final androidDeviceInfo = await deviceInfo.androidInfo;
    deviceID = androidDeviceInfo.id; // unique ID on Android
  }

  if (deviceID != null && deviceID.length < 4) {
    if (Platform.isAndroid) {
      deviceID += '_android';
    } else if (Platform.isIOS) {
      deviceID += '_ios___';
    }
  }
  if (Platform.isAndroid) {
    deviceID ??= 'flutter_user_id_android';
  } else if (Platform.isIOS) {
    deviceID ??= 'flutter_user_id_ios';
  }

  final userID = md5
      .convert(utf8.encode(deviceID!))
      .toString()
      .replaceAll(RegExp(r'[^0-9]'), '');
  return userID.substring(userID.length - 6);
}

Widget switchDropList<T>(
  ValueNotifier<T> notifier,
  List<T> itemValues,
  Widget Function(T value) widgetBuilder,
) {
  return ValueListenableBuilder<T>(
      valueListenable: notifier,
      builder: (context, value, _) {
        return DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: itemValues.map((T itemValue) {
            return DropdownMenuItem(
              value: itemValue,
              child: widgetBuilder(itemValue),
            );
          }).toList(),
          onChanged: (T? newValue) {
            if (newValue != null) {
              notifier.value = newValue;
            }
          },
        );
      });
}

  
    static Future<void> loginUser(String userId, String userName) async {
    ZegoUser user = ZegoUser(userId, userName);
    await ZegoExpressEngine.instance.loginRoom('your_room_id', user);
  }

  static Future<void> startCall(String roomId) async {
    await ZegoExpressEngine.instance.startPublishingStream(roomId);
    await ZegoExpressEngine.instance.startPreview();
  }

  static Future<void> joinCall(String roomId) async {
    await ZegoExpressEngine.instance.loginRoom(roomId, ZegoUser('user_id', 'user_name'));
    await ZegoExpressEngine.instance.startPlayingStream(roomId);
  }

  static Future<void> endCall(String roomId) async {
    await ZegoExpressEngine.instance.stopPublishingStream();
    await ZegoExpressEngine.instance.logoutRoom(roomId);
  }

  static void onIncomingCall(String roomId, BuildContext context) {
    // Show an alert or a dialog for the incoming call
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Incoming Call"),
        content: Text("You have an incoming call from $roomId"),
        actions: [
          TextButton(
            onPressed: () {
              joinCall(roomId);
              Navigator.of(context).pop();
            },
            child: Text("Answer"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Decline"),
          ),
        ],
      ),
    );
  }
}

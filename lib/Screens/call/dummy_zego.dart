import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_call_app/Util/video_call_utils.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


class DummyZego extends StatefulWidget {
  String userId;
  String userName;
  DummyZego({super.key, required this.userId,required this.userName});

  @override
  State<DummyZego> createState() => _DummyZegoState();
}

class _DummyZegoState extends State<DummyZego> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: Utils.appId,
      appSign: Utils.appSignin,
      callID: "54321",
      userID: widget.userId,
      userName:widget.userName,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..onOnlySelfInRoom = (context) => Navigator.pop(context),
    );
  }
}

 // void initZego() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? storedUserId = prefs.getString('userId');
  //   String? storedUserName = prefs.getString('userName');

  //   if (kDebugMode) {
  //     print("Id of the current user is $storedUserId");
  //     print("Name of the current user is $storedUserName");
  //   }

  //   // Ensure userID and userName are not null before passing them to Zego
  //   await ZegoUIKitPrebuiltCallInvitationService().init(
  //       appID: Utils.appId,
  //       appSign: Utils.appSignin,
  //       userID: storedUserId ?? "defaultUserId",
  //       userName: storedUserName ?? "defaultUserName",
  //       notifyWhenAppRunningInBackgroundOrQuit: true,
  //       androidNotificationConfig: ZegoAndroidNotificationConfig(
  //         channelID: "ZegoUIKit",
  //         channelName: "Call Notifications",
  //         sound: "notification",
  //         icon: "notification_icon",
  //       ),
  //       iOSNotificationConfig: ZegoIOSNotificationConfig(
  //         isSandboxEnvironment: false,
  //         systemCallingIconName: 'CallKitIcon',
  //       ),
  //       plugins: [ZegoUIKitSignalingPlugin()],
  //       requireConfig: (ZegoCallInvitationData data) {
  //         final config = (data.invitees.length > 1)
  //             ? ZegoCallType.videoCall == data.type
  //                 ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
  //                 : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
  //             : ZegoCallType.videoCall == data.type
  //                 ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  //                 : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

  //         config.topMenuBarConfig.isVisible = true;
  //         config.topMenuBarConfig.buttons
  //             .insert(0, ZegoMenuBarButtonName.minimizingButton);
  //         // Handle when the call ends

  //         // Handle when the call ends
  //         // config.onHangUpConfirmation = (context) async {
  //         //   onCallEnd();
  //         //   return Future.value(true);
  //         // };

  //         // // Handle when the call is declined
  //         // config.onHangUp = () {
  //         //   onCallDecline();
  //         // };

  //         return config;
  //       });
  // }

  // void _uninitializeCallInvitationService() {
  //   _callInvitationService.uninit();
  // }
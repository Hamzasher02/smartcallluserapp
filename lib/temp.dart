import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class temp extends StatefulWidget {
  const temp({super.key});

  @override
  State<temp> createState() => _tempState();
}

class _tempState extends State<temp> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.red,);
  }
}
//  void sendVideoCallFCM(String inviteeId, String inviteeName) async {
//   if(kDebugMode){
//     print("Device token of the receiver is ${widget.recieverDeviceToken}");
//   }
//   final String serverKey = await getAccessToken(); // Firebase Access Token
//   final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/smart-call-app/messages:send';

//   final Map<String, dynamic> message = {
//     'message': {
//       'token': widget.recieverDeviceToken, // The FCM token of the recipient
//       'notification': {
//         'title': "Incoming Video Call",
//         'body': "$inviteeName is calling you",
//       },
//       'data': {
//         'type': 'video_call',
//         'navigate': 'video_call',
//         'channelName': widget.name, // Unique Agora channel name
//         'callerId': widget.currentUserId.toString(), // Your ID or caller's ID
//         'callerName': widget.currentUserName.toString(), // The name of the caller
//       },
//     }
//   };

//   final http.Response response = await http.post(
//     Uri.parse(fcmEndpoint),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $serverKey',
//     },
//     body: jsonEncode(message),
//   );

//   if (response.statusCode == 200) {
//     print('FCM message sent successfully.');
//   } else {
//     print('Failed to send FCM message: ${response.body}');
//   }
// }


//  void initZego() async {
//     print(
//         "Initializing Zego with userId: ${widget.currentUserId}, userName: ${widget.currentUserName}");

//     await ZegoUIKitPrebuiltCallInvitationService().init(
//       appID: Utils.appId,
//       appSign: Utils.appSignin,
//       userID: widget.currentUserId,
//       userName: widget.currentUserName,
//       notifyWhenAppRunningInBackgroundOrQuit: true,
//       ringtoneConfig: const ZegoRingtoneConfig(
//         incomingCallPath: "assets/audio/ringtone.mp3",
//         outgoingCallPath: "assets/audio/ringtone.mp3",
//       ),
//       androidNotificationConfig: ZegoAndroidNotificationConfig(
//         channelID: "ZegoUIKit",
//         channelName: "Call Notifications",
//         sound: "ringtone",
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

//         config.onHangUp = () {
//           print('Call ended or declined');
//         };

//         return config;
//       },
//     );
//   }


// 'https://smart-app-1-79e695a86800.herokuapp.com'



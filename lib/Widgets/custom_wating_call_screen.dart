// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class CustomWaitingScreen extends StatelessWidget {
//   final String recipientProfileImage;
//   final String recipientName;

//   CustomWaitingScreen({
//     required this.recipientProfileImage,
//     required this.recipientName,
//   });

//   void _endCall(BuildContext context) async {
//     // Assuming `ZegoUIKitPrebuiltCallInvitationService` is globally accessible
//     await ZegoUIKitPrebuiltCallInvitationService().rejectCall(
//       // You need to pass relevant parameters to end the call
//       // This might include call ID, user ID, etc.
//     );

//     // Navigate back or to another screen
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Waiting for ${recipientName}'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: NetworkImage(recipientProfileImage),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Waiting for ${recipientName}',
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//             SizedBox(height: 50),
//             IconButton(
//               icon: Icon(
//                 Icons.phone_disabled,
//                 color: Colors.white,
//                 size: 40,
//               ),
//               onPressed: () => _endCall(context),
//               padding: EdgeInsets.all(20),
//               constraints: BoxConstraints(),
//               iconSize: 40,
//               color: Colors.red,
//               splashColor: Colors.transparent,
//               highlightColor: Colors.transparent,
//               // Customize the button style as needed
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

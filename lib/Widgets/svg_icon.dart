import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  // Variables
  final String assetName;
  final double width;
  final double height;
  final Color color;

  const SvgIcon(this.assetName, {required this.width, required this.height, required this.color});
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(assetName,
        width: width ?? 23, height: height ?? 23, color: color ?? Colors.grey);
  }
}
// void _handleMessage(RemoteMessage message) async {
//   if (myuser == null && myid.isNotEmpty) {
//     await dataFireBase();  // Ensure user data is loaded
//   }

//   if (myuser != null) {
//     if (message.data['navigate'] == 'chat_screen') {
//       // Fetch the necessary information from the payload
//       String chatId = message.data['chat_id'] ?? '';
//       String otherUserId = message.data['otheruser_id'] ?? '';
//       String myUserId = message.data['myuser_id'] ?? '';
//       String otherUserName = message.data['otheruser_name'] ?? '';

//       // If all necessary fields are present, navigate to the chat screen
//       if (chatId.isNotEmpty && otherUserId.isNotEmpty && myUserId.isNotEmpty) {
//         navigatorKey.currentState?.push(MaterialPageRoute(
//           builder: (context) => MessageScreen(
//             chatId: chatId,
//             myUserId: myUserId,
//             otherUserId: otherUserId,
//             otherUserName: otherUserName,
//             user: myuser!, // Assuming myuser is the current logged-in user
//           ),
//         ));
//       }
//     } else if (message.data['navigate'] == 'status_screen') {
//       // Navigate to the Status screen for newsletter notification
//       navigatorKey.currentState?.push(MaterialPageRoute(
//         builder: (context) => StatusScreen(
//           myuser: myuser!,
//         ),
//       ));
//     } else {
//       // Default navigation if no specific action is provided
//       navigatorKey.currentState?.push(MaterialPageRoute(
//         builder: (context) => const MainPage(tab: 0),
//       ));
//     }
//   }
// }


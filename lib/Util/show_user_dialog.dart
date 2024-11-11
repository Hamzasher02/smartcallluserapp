// import 'package:country_picker/country_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
// import 'package:get/get.dart';
// import 'package:smart_call_app/Screens/call/agora/video_call_screen_1.dart';
// import 'package:smart_call_app/Screens/chat/chat_screen.dart';
// import 'package:smart_call_app/Util/chat_buddy_component.dart';
// import 'package:smart_call_app/Util/video_call_fcm.dart';
// import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';
// import 'package:smart_call_app/db/entity/chat.dart';
// import 'package:smart_call_app/db/entity/message.dart';
// import 'package:smart_call_app/db/entity/utils.dart';
// import 'package:smart_call_app/db/remote/firebase_database_source.dart';

// class ShowUserDialog {
//    void _startCall(String callType, String chatId, String currentUserId,
//       String otherUserId) {
//     if (kDebugMode) {
//       print("The id of the current user is $currentUserId");
//       print("The id of the other user is $otherUserId");
//       print("The chat id is $chatId");
//       print("The call type is $callType");
//     }
//     _databaseSource.storeCallInfo(
//       chatId: chatId,
//       myUserId: currentUserId,
//       otherUserId: otherUserId,
//       callType: callType,
//       callStatus: "Started",
//       isIncoming: false,
//     );
//   }

//   void onCallEnd() {
//     if (_isAdLoaded1 && _interstitialAd != null) {
//       _interstitialAd!.show();
//       _interstitialAd = null; // Clear the current ad
//       _isAdLoaded1 = false;
//       _initializeAd(); // Load a new ad for the next call
//     }
//   }
  

//   void onCallDecline() {
//     if (_isAdLoaded1 && _interstitialAd != null) {
//       _interstitialAd!.show();
//       _interstitialAd = null; // Clear the current ad
//       _isAdLoaded1 = false;
//       _initializeAd(); // Load a new ad for the next call
//     }
//   }
//   static ChatBuddyComponent chatBuddyComponent=ChatBuddyComponent();
//     static FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

//   static  showUserView(String token,BuildContext context, String type, String id, img, name, country,
//       date, age, gender, view, like, myid, myuser, otherId, index, temp1) {
//     int views;
//     bool isFavorite =
//         temp1 == "true"; // Initially set based on the 'temp1' field
//     int likes = like; // Initialize likes counter
//     print(view);
//     bool fvtVisible = false;
//     views = view + 1;
//     print(views);
//     _databaseSource.addView(id, views);
//     showAnimatedDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               contentPadding: EdgeInsets.zero,
//               content: Container(
//                 height: MediaQuery.of(context).size.height * 0.8,
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surface,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                     bottomLeft: Radius.circular(20),
//                     bottomRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                         child: Image.network(
//                           img,
//                           fit: BoxFit.cover,
//                           height: MediaQuery.of(context).size.height * 0.3,
//                           width: MediaQuery.of(context).size.width,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 15, vertical: 10),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             /// Name and Favorite Icon
//                             Expanded(
//                               flex: 2,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: Text(
//                                       name,
//                                       style: const TextStyle(
//                                         fontSize: 26,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Column(
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () async {
//                                             bool newIsFavorite =
//                                                 !isFavorite; // Toggle favorite status
//                                             int newLikes = likes +
//                                                 (newIsFavorite
//                                                     ? 1
//                                                     : -1); // Update like count

//                                             try {
//                                               // Update Firestore with new favorite status and like count
//                                               _databaseSource.addFav(
//                                                   id, newLikes);
//                                               _databaseSource.addFav2(
//                                                   id, newIsFavorite.toString());

//                                               setState(() {
//                                                 isFavorite = newIsFavorite;
//                                                 likes = newLikes;
//                                               });

//                                               if (isFavorite) {
//                                                 await _databaseSource. addF(myid, otherId,
//                                                     "addF", index);
//                                                 player.setAsset(
//                                                     'assets/audio/ting.mp3');
//                                                 player.play();

//                                                 Get.snackbar(
//                                                   backgroundColor:
//                                                       const Color(0xff607d8b),
//                                                   snackPosition:
//                                                       SnackPosition.TOP,
//                                                   duration: const Duration(
//                                                       seconds: 4),
//                                                   "Favourites",
//                                                   "$name is added to favorites.",
//                                                 );
//                                               } else {
//                                                 await _databaseSource. addF(myid, otherId,
//                                                     "removeF", index);

//                                                 Get.snackbar(
//                                                   backgroundColor:
//                                                       const Color(0xff607d8b),
//                                                   snackPosition:
//                                                       SnackPosition.TOP,
//                                                   duration: const Duration(
//                                                       seconds: 4),
//                                                   "Favourites",
//                                                   "$name is removed from favorites.",
//                                                 );
//                                               }

//                                               // Close the dialog
//                                               Navigator.pop(context);

//                                               // Delayed navigation to ensure smooth transition
//                                               // Replace the delayed navigation with:
//                                               // SchedulerBinding.instance
//                                               //     .addPostFrameCallback((_) {
//                                               //   Navigator.of(context)
//                                               //       .pushAndRemoveUntil(
//                                               //     MaterialPageRoute(
//                                               //         builder: (context) =>
//                                               //             MainPage(tab: 0)),
//                                               //     (route) => false,
//                                               //   );
//                                               // });
//                                             } catch (e) {
//                                               print(
//                                                   "Error updating favorites: $e");
//                                             }
//                                           },
//                                           child: Icon(
//                                             isFavorite
//                                                 ? Icons.favorite
//                                                 : Icons.favorite_border,
//                                             color: isFavorite
//                                                 ? Colors.red
//                                                 : Colors.white,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text('$likes'),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             /// Country
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   Text(countryCodeToEmoji(country)),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Text(
//                                     Country.tryParse(country)!.name,
//                                     style: const TextStyle(fontSize: 20),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     date,
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             /// Age
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   const Text(
//                                     "Age: ",
//                                     style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     "$age",
//                                     style: const TextStyle(fontSize: 20),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             /// Gender
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   const Text(
//                                     "Gender: ",
//                                     style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     "$gender",
//                                     style: const TextStyle(fontSize: 20),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             /// Buttons
//                             Expanded(
//                               flex: 2,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceEvenly,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       String chatId = compareAndCombineIds(
//                                         myid,
//                                         id,
//                                       );
//                                         Message1 message = Message1(
//                                       epochTimeMs: DateTime.now().millisecondsSinceEpoch,
//                                       seen: false,
//                                       senderId: myid,
//                                       text: "Say Hello 👋",
//                                       type: "text",
//                                     );
//                                       _databaseSource
//                                           .addChat(Chat(chatId, message));
//                                   chatBuddyComponent.    chatBuddySent(myid, id, "Buddy Sent");
//                                   chatBuddyComponent.    chatBuddyReceived(
//                                           id, myid, "Buddy received");
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (context) => MessageScreen(
//                                             gender: gender,
//                                             userType: type,
//                                             date: date,
//                                             age: age,
//                                             image: img,
//                                             country: country,
//                                             chatId:
//                                                 compareAndCombineIds(myid, id),
//                                             myUserId: myid,
//                                             otherUserId: id,
//                                             otherUserName: name,
//                                             user: myuser,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: CircleAvatar(
//                                       backgroundColor:
//                                           Colors.blue.withOpacity(0.7),
//                                       radius: 30,
//                                       child: const Icon(
//                                         Icons.chat,
//                                         size: 30,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                  type == "live"
//                                       ? GestureDetector(
//                                           onTap: () {
//                                             String chatId =
//                                                 compareAndCombineIds(myid, id);

//                                             _startCall(
//                                                 "video", chatId, myid, id);

//                                             VideoCallFcm.sendCallNotification(
//                                                 FirebaseAuth
//                                                         .instance
//                                                         .currentUser!
//                                                         .displayName ??
//                                                     "",
//                                                 token,
//                                                 "smart_call_app",
//                                                 "007eJxTYDB4tby/x9u89qvalpzLyvNuuM/gXbpGMUHg+IcjQgsnvi5QYDC0SDZJTTaySDExSjFJSUpJtDQ0tTQ0MrEwt0g1S05K6u5QSG8IZGTwuHaCkZEBAkF8Pobi3MSikvjkxJyc+MSCAgYGAPZ4JJs=",
//                                                 name);
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     VideoCallScreen1(
//                                                   recieverName: name,
//                                                   agoraAppId:
//                                                       "18c4ec28d42d4dbda9159124878e6cbb",
//                                                   agoraAppToken:
//                                                       "007eJxTYDB4tby/x9u89qvalpzLyvNuuM/gXbpGMUHg+IcjQgsnvi5QYDC0SDZJTTaySDExSjFJSUpJtDQ0tTQ0MrEwt0g1S05K6u5QSG8IZGTwuHaCkZEBAkF8Pobi3MSikvjkxJyc+MSCAgYGAPZ4JJs=",
//                                                   agoraAppCertificate:
//                                                       "064b1a009cc248afa93a01234876a4c9", // Use your dynamic token
//                                                   agoraAppChannelName:
//                                                       "smart_call_app",
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           child: Container(
//                                             width: 45,
//                                             height: 45,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: Colors.green,
//                                             ),
//                                             child: const Center(
//                                               child: Icon(
//                                                 Icons.videocam,
//                                                 size: 25,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : type == "fake"
//                                           ? GestureDetector(
//                                               onTap: () {
//                                                 Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             DummyWaitingCallScreen(
//                                                               userImage: img,
//                                                               userName: name,
//                                                             )));
//                                               },
//                                               child: const Align(
//                                                 alignment:
//                                                     Alignment.centerRight,
//                                                 child: CircleAvatar(
//                                                   backgroundColor: Colors.green,
//                                                   radius: 30,
//                                                   child: Icon(
//                                                     Icons.videocam_rounded,
//                                                     size: 40,
//                                                     color: Colors.white,
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           : Container(),
//                                 ],
//                               ),
//                             ),

//                             /// Date
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//       animationType: DialogTransitionType.size,
//       curve: Curves.fastOutSlowIn,
//       duration: const Duration(seconds: 1),
//     );
//   }
// }
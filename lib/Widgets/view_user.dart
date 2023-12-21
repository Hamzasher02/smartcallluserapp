// import 'package:flutter/material.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import '../Screens/chat/chat_screen.dart';
// import '../Util/constants.dart';
// import '../db/entity/chat.dart';
// import '../db/entity/message.dart';
// import '../db/entity/utils.dart';
// import '../db/remote/firebase_database_source.dart';
//
//
// final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
//
//
//
// showUserView(BuildContext context, String id,img,name,likes,country,date,age,gender,myid,myuser,bool) {
//   showAnimatedDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return StatefulBuilder(builder: (context, setState) {
//         return AlertDialog(
//             contentPadding: EdgeInsets.zero,
//             content: SizedBox(
//                 height: getHeight(context)*0.7,
//                 width: double.infinity,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Image.network(img,fit: BoxFit.fill,height: 200,width: 300,),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(name,style: const TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
//                           Column(
//                             children: [
//                               GestureDetector(
//                                   onTap:(){
//                                     function();
//                                   },
//                                   child: const Icon(Icons.favorite_border,size: 30,)),
//                               const SizedBox(height: 5,),
//                               Text(likes,style: const TextStyle(fontSize: 22),),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     Padding(
//                       padding:const EdgeInsets.fromLTRB(20, 10, 20, 0),
//                       child: Row(
//                         children: [
//                           const Text("🌍"),
//                           const SizedBox(width: 10,),
//                           Text(country,style: const TextStyle(fontSize: 20),),
//                         ],
//                       ),
//                     ),
//
//                     Padding(
//                       padding:const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                       child: Row(
//                         children: [
//                           Text(date,style: const TextStyle(fontSize: 18),),
//                         ],
//                       ),
//                     ),
//
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                       child: Row(
//                         children: [
//                           const Text("Age: " ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//                           Text("$age" ,style: const TextStyle(fontSize: 20),),
//                         ],
//                       ),
//                     ),
//
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//                       child: Row(
//                         children: [
//                           const Text("Gender: " ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//                           Text("$gender" ,style: const TextStyle(fontSize: 20),),
//                         ],
//                       ),
//                     ),
//
//
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(40, 10, 20, 0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           GestureDetector(
//                             onTap: (){
//                               String chatId = compareAndCombineIds(myid,id,);
//                               Message message =
//                               Message(DateTime.now().millisecondsSinceEpoch, false, myid,"Say Hello 👋","text");
//                               _databaseSource.addChat(Chat(chatId, message));
//                               Navigator.of(context).push(MaterialPageRoute(
//                                   builder: (context) => MessageScreen(
//                                     chatId: compareAndCombineIds(myid, id),
//                                     myUserId: myid,
//                                     otherUserId: id,
//                                     user: myuser,
//                                   )));
//                             },
//                             child: CircleAvatar(
//                               backgroundColor:
//                               Colors.lightBlueAccent.withOpacity(0.7),
//                               radius: 30,
//                               child: const Icon(
//                                 Icons.chat,
//                                 size: 40,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           ZegoSendCallInvitationButton(
//                               isVideoCall: true,
//                               resourceID: "hafeez_khan", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
//                               invitees: [
//                                 ZegoUIKitUser(
//                                   id: id,
//                                   name: name,
//                                 )])
//                         ],
//                       ),
//                     ),
//
//                   ],
//                 )
//             ));
//       });
//
//     },
//     animationType: DialogTransitionType.size,
//     curve: Curves.fastOutSlowIn,
//     duration: const Duration(seconds: 1),);
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../Screens/chat/chat_screen.dart';
import '../Util/constants.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';
import 'country_to_flag.dart';

AppUser? otherUser;
String myid = '';
FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

dataFireBase(userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myid = prefs.getString("myid")!;
  print(myid);
  await db.collection("users").doc(userId).get().then((event) async {
    otherUser = AppUser(
      id: event.data()!['id'],
      name: event.data()!['name'],
      gender: event.data()!['gender'],
      country: event.data()!['country'],
      age: event.data()!['age'],
      profilePhotoPath: event.data()!['profile_photo_path'],
      temp1: event.data()!['temp1'],
      temp2: event.data()!['temp2'],
      temp3: event.data()!['temp3'],
      temp4: event.data()!['temp4'],
      temp5: event.data()!['temp5'],
      token: event.data()!['token'],
      status: event.data()!['status'],
      likes: event.data()!['likes'],
      type: event.data()!['type'],
      views: event.data()!['views'],
    );
  });
  return otherUser;
}

@override
showStatusImage(context, String path, likes, userId, AppUser myuser, List img) async {
 // AppUser? otherUser;
  String myid = '';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myid = prefs.getString("myid")!;
  print(myid);
  await db.collection("users").doc(userId).get().then((event) async {
    otherUser = AppUser(
      id: event.data()!['id'],
      name: event.data()!['name'],
      gender: event.data()!['gender'],
      country: event.data()!['country'],
      age: event.data()!['age'],
      profilePhotoPath: event.data()!['profile_photo_path'],
      temp1: event.data()!['temp1'],
      temp2: event.data()!['temp2'],
      temp3: event.data()!['temp3'],
      temp4: event.data()!['temp4'],
      temp5: event.data()!['temp5'],
      token: event.data()!['token'],
      status: event.data()!['status'],
      likes: event.data()!['likes'],
      type: event.data()!['type'],
      views: event.data()!['views'],
    );
  });
  //dataFireBase(userId);
  return showMaterialModalBottomSheet(
    context: context,
    builder: (context) => PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: img.length,
        //reverse: true,
        itemBuilder: (context, index) {
          getUser(index==0?userId:img[index].userId);
          try {
            return   GestureDetector(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(index==0?path:img[index].imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                height: getHeight(context) * 0.8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          //
                        },
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 30,
                            child: Icon(
                              Icons.favorite,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          String chatId = compareAndCombineIds(
                            myid,
                            otherUser!.id,
                          );
                          Message message = Message(DateTime.now().millisecondsSinceEpoch, false, myid, "Say Hello 👋", "text");
                          _databaseSource.addChat(
                            Chat(chatId, message),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MessageScreen(
                                chatId: compareAndCombineIds(myid, otherUser!.id),
                                myUserId: myid,
                                otherUserId: otherUser!.id,
                                user: myuser,
                                otherUserName: otherUser!.name,
                              ),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                            radius: 30,
                            child: const Icon(
                              Icons.chat,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ZegoSendCallInvitationButton(
                          buttonSize: const Size(60, 80),
                          isVideoCall: true,
                          resourceID: "hafeez_khan",
                          //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                          invitees: [
                            ZegoUIKitUser(
                              id: userId,
                              name: "User",
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " ${countryCodeToEmoji(otherUser!.country)}\t\t${otherUser!.name}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 30,
                            backgroundImage: NetworkImage(otherUser!.profilePhotoPath),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } catch (e) {
            print(e);
            return Container();
          }
        })
  );
}
getUser(userId) async {
  // AppUser? otherUser;
  String myid = '';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myid = prefs.getString("myid")!;
  print(myid);
  await db.collection("users").doc(userId).get().then((event) async {
    otherUser = AppUser(
      id: event.data()!['id'],
      name: event.data()!['name'],
      gender: event.data()!['gender'],
      country: event.data()!['country'],
      age: event.data()!['age'],
      profilePhotoPath: event.data()!['profile_photo_path'],
      temp1: event.data()!['temp1'],
      temp2: event.data()!['temp2'],
      temp3: event.data()!['temp3'],
      temp4: event.data()!['temp4'],
      temp5: event.data()!['temp5'],
      token: event.data()!['token'],
      status: event.data()!['status'],
      likes: event.data()!['likes'],
      type: event.data()!['type'],
      views: event.data()!['views'],
    );
  });
}

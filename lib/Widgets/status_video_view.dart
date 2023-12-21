import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../Screens/chat/chat_screen.dart';
import '../Util/constants.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';
import 'country_to_flag.dart';

late VideoPlayerController _controller;
late Future<void> _initializeVideoPlayerFuture;

AppUser? otherUser;
String myid='';
FirebaseFirestore db = FirebaseFirestore.instance;

dataFireBase(userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myid = prefs.getString("myid")!;
  print(myid);
  await db
      .collection("users")
      .doc(userId)
      .get()
      .then((event) async {
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
final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

@override
showStatusVideo(BuildContext context, String path, likes, userId,AppUser myuser) async {
  _controller = VideoPlayerController.networkUrl(Uri.parse(path));
  // ..initialize().then((_) {
  //   // Ensure the first frame is shown after the video is initialized,
  //   //even before the play button has been pressed.
  //   setState(() {});
  // });
  AppUser? otherUser;
  String myid='';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myid = prefs.getString("myid")!;
  print(myid);
  await db
      .collection("users")
      .doc(userId)
      .get()
      .then((event) async {
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
  _initializeVideoPlayerFuture = _controller.initialize();
  //_controller.setLooping(true);
  _controller.play();
  return showMaterialModalBottomSheet(
    context: context,
    builder: (context) => GestureDetector(
      onDoubleTap: (){

      },
      child: Stack(
        children: [
          SizedBox.expand(
            // child: FittedBox(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff607d8b),
                      ),
                    );
                  }
                },
              ),
              //     ?Container(
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //         image: NetworkImage(widget.sto[index].imageUrl),
              //         fit: BoxFit.cover),
              //   ),
              //   height: getHeight(context)*0.9,
              // )
              //     : VideoPlayer(controller = VideoPlayerController.networkUrl(Uri.parse(widget.sto[index].imageUrl))..initialize().then((_) {
              //   // controller?.setLooping(true);
              //   // controller?.initialize().then((_) => setState(() {}));
              //   // controller?.play();
              // })),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.favorite,
                  size: 55,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Text(
                    likes.toString(),
                    style: TextStyle(fontSize: 30,color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                GestureDetector(
                  onTap: (){
                    String chatId = compareAndCombineIds(
                      myid,
                      otherUser!.id,
                    );
                    Message message = Message(
                        DateTime.now().millisecondsSinceEpoch,
                        false,
                        myid,
                        "Say Hello 👋",
                        "text");
                    _databaseSource.addChat(Chat(chatId, message));
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MessageScreen(
                          chatId:
                          compareAndCombineIds(myid, otherUser!.id),
                          myUserId: myid,
                          otherUserId: otherUser!.id,
                          user: myuser,
                          otherUserName: otherUser!.name,
                        )));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                    radius: 30,
                    child: const Icon(
                      Icons.chat,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ZegoSendCallInvitationButton(
                    buttonSize: Size(60, 80),
                    isVideoCall: true,
                    resourceID: "hafeez_khan",
                    //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                    invitees: [
                      ZegoUIKitUser(
                        id: userId,
                        name: "User",
                      )
                    ]),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${otherUser!.name} ${countryCodeToEmoji(otherUser!.country)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                    ),
                     CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 30,
                      child: Image.network(otherUser!.profilePhotoPath,fit: BoxFit.fill,),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

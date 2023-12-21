import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../Screens/chat/chat_screen.dart';
import '../Util/constants.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/fvrt.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';
import 'country_to_flag.dart';

class StatusBarListView extends StatefulWidget {
  final List fakeUser;
  final AppUser myuser;
  const StatusBarListView({super.key, required this.fakeUser, required this.myuser});

  @override
  State<StatusBarListView> createState() => _StatusBarListViewState();
}

class _StatusBarListViewState extends State<StatusBarListView> {
  @override
  void initState() {
    player = AudioPlayer();
    player.setAsset('assets/audio/ting.mp3');
    super.initState();
  }

  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  late AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: getWidth(context)*.7,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: widget.fakeUser.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(padding: EdgeInsets.only(left: 10),
                child:
                GestureDetector(
                  onTap: (){
                    showUserView(context, widget.fakeUser[index].id,
                        widget.fakeUser[index].profilePhotoPath,
                        widget.fakeUser[index].name,
                        widget.fakeUser[index].country,
                        "01-11-2022",
                        widget.fakeUser[index].age,
                        widget.fakeUser[index].gender,
                        widget.fakeUser[index].views,
                        widget.fakeUser[index].likes,
                        widget.myuser.id,
                        widget.myuser,
                        widget.fakeUser[index].id,
                        index);
                  },
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Column(
                        children:[
                          Image.network(widget.fakeUser[index].profilePhotoPath,width: 50,height: 50,fit: BoxFit.fill,),
                          const SizedBox(height: 3,),
                          Text(widget.fakeUser[index].name,style: (const TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),),

                        ]
                    ),
                  ),
                ));
          } ),);
  }

  showUserView(BuildContext context, String id, img, name, country, date, age,
      gender, view, like, myid, myuser, otherId, index) {
    int views;
    print(view);
    bool fvtVisible = false;
    views = view + 1;
    print(views);
    _databaseSource.addView(id, views);
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                  height: 650,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        img,
                        fit: BoxFit.fill,
                        height: 200,
                        width: 300,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                    onTap:fvtVisible?null
                                        :() {
                                      addF(myid, otherId, "addF", index);
                                      int likes;
                                      likes = like+1;
                                      _databaseSource.addFav(id, likes);
                                      player.play();
                                      setState(() {
                                        fvtVisible = !fvtVisible;
                                      });
                                    },
                                    child: Icon(
                                      fvtVisible
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: fvtVisible
                                          ? Colors.redAccent
                                          : Colors.black,
                                      size: 30,
                                    )),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  like.toString(),
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Row(
                          children: [
                            Text(countryCodeToEmoji(country)),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              country,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Text(
                              date,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            const Text(
                              "Age: ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$age",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            const Text(
                              "Gender: ",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "$gender",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 10, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                String chatId = compareAndCombineIds(
                                  myid,
                                  id,
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
                                      compareAndCombineIds(myid, id),
                                      myUserId: myid,
                                      otherUserId: id,
                                      user: myuser,
                                      otherUserName: name,
                                    )));
                              },
                              child: CircleAvatar(
                                backgroundColor:
                                Colors.lightBlueAccent.withOpacity(0.7),
                                radius: 30,
                                child: const Icon(
                                  Icons.chat,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ZegoSendCallInvitationButton(
                                isVideoCall: true,
                                resourceID: "hafeez_khan",
                                //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                                invitees: [
                                  ZegoUIKitUser(
                                    id: id,
                                    name: name,
                                  )
                                ])
                          ],
                        ),
                      ),
                    ],
                  )));
        });
      },
      animationType: DialogTransitionType.size,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
  }

  addF(String myId, String otherId, String added, index) {
    _databaseSource.addFavourites(myId, AddFavourites(otherId, added));
  }

}

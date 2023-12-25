import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skeletons/skeletons.dart';
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
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.fakeUser.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
              onTap: () {
                showUserView(
                    context,
                    widget.fakeUser[index].id,
                    widget.fakeUser[index].profilePhotoPath,
                    widget.fakeUser[index].name,
                    widget.fakeUser[index].country,
                    "${dateFormat.format(DateTime.now())}",
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
                height: 70,
                width: 75,
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: widget.fakeUser[index].profilePhotoPath,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          placeholder: (context, url) => const Skeleton(
                              isLoading: true,
                              skeleton: SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                              child: Text("")),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.fakeUser[index].name,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /*
  * ? null
                                        : () {
                                            addF(myid, otherId, "addF", index);
                                            int likes;
                                            likes = like + 1;
                                            _databaseSource.addFav(id, likes);
                                            player.play();
                                            setState(() {
                                              fvtVisible = !fvtVisible;
                                            });
                                          },
                                          *
                                          * ZegoSendCallInvitationButton(
                                isVideoCall: true,
                                resourceID: "hafeez_khan",
                                //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                                invitees: [
                                  ZegoUIKitUser(
                                    id: id,
                                    name: name,
                                  )
                                ])
                                * */

  showUserView(BuildContext context, String id, img, name, country, date, age, gender, view, like, myid, myuser, otherId, index) {
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Column(
                          children: [
                            /// name and fvrt
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: fvtVisible
                                            ? null
                                            : () {
                                                addF(myid, otherId, "addF", index);
                                                int likes;
                                                likes = like + 1;
                                                _databaseSource.addFav(id, likes);
                                                player.play();
                                                setState(() {
                                                  fvtVisible = !fvtVisible;
                                                });
                                              },
                                        child: Icon(
                                          fvtVisible ? Icons.favorite : Icons.favorite_border,
                                          color: fvtVisible ? Colors.redAccent : Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                      Text(
                                        like.toString(),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            /// country
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(countryCodeToEmoji(country)),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    Country.tryParse(country)!.name,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// date
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),

                            /// age
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Text(
                                    "Age: ",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$age",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// gender
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Text(
                                    "Gender: ",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$gender",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// buttons
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                        "text",
                                      );
                                      _databaseSource.addChat(Chat(chatId, message));
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                            chatId: compareAndCombineIds(myid, id),
                                            myUserId: myid,
                                            otherUserId: id,
                                            user: myuser,
                                            otherUserName: name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                                      radius: 30,
                                      child: const Icon(
                                        Icons.chat,
                                        size: 30,
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
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skeletons/skeletons.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Screens/call/agora/screen_video_call.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Widgets/call_with_timer.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../Screens/chat/chat_screen.dart';
import '../Util/constants.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/fvrt.dart';
import '../db/entity/message.dart';
import '../db/entity/sentmessage.dart';
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
    //player.setAsset('assets/audio/ting.mp3');
    super.initState();
  }

  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  late AudioPlayer player;
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  initAd() {
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
    _interstitialAd!.show();
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded = true;
  }

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
                initAd();
                showUserView(
                  context,
                  widget.fakeUser[index].id,
                  widget.fakeUser[index].profilePhotoPath,
                  widget.fakeUser[index].name,
                  widget.fakeUser[index].country,
                  dateFormat.format(DateTime.now()),
                  widget.fakeUser[index].age,
                  widget.fakeUser[index].gender,
                  widget.fakeUser[index].views,
                  widget.fakeUser[index].likes,
                  widget.myuser.id,
                  widget.myuser,
                  widget.fakeUser[index].id,
                  index,
                  widget.fakeUser[index].temp1,
                );
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
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
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

  void chatBuddySent(String myid, String otherid, String sent) async {
    _databaseSource.addChatBuddy(myid, SentMessage(otherid, sent));
  }

  void chatBuddyReceived(String otherid, String myid, String received) async {
    //_databaseSource.addMessageRequestRecived(otherid, ReceivedRequest(myid, received));
    _databaseSource.addChatBuddy(otherid, SentMessage(myid, received));
  }

  int showZeroIfNegative(int number) {
    if (number >= 0) {
      return number;
    } else {
      return 0;
    }
  }

  showUserView(BuildContext context, String id, img, name, country, date, age, gender, view, like, myid, myuser, otherId, index, temp1) {
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
              content: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
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
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      name,
                                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: fvtVisible
                                              ? null
                                              : () {
                                                  addF(myid, otherId, "addF", index);
                                                  int likes;
                                                  likes = like + 1;
                                                  player.setAsset('assets/audio/ting.mp3');
                                                  player.play();
                                                  setState(() {
                                                    fvtVisible = !fvtVisible;
                                                  });
                                                  _databaseSource.addFav(id, likes);
                                                  _databaseSource.addFav2(id, fvtVisible.toString());
                                                },
                                          child: Icon(
                                            temp1 != "" || fvtVisible ? Icons.favorite : Icons.favorite_border,
                                            color: temp1 != "" || fvtVisible ? Colors.redAccent : Colors.redAccent,
                                            size: 20,
                                          ),
                                        ),
                                        Text(
                                          showZeroIfNegative(like).toString(),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
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
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(),
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
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                                  ),
                                ],
                              ),
                            ),

                            /// age
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(
                                    "Age: ",
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$age",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                                  ),
                                ],
                              ),
                            ),

                            /// gender
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Text(
                                    "Gender: ",
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$gender",
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(),
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
                                      chatBuddySent(myid, id, "Buddy Sent");
                                      //messagerequestreceived(userid, myid, "received");
                                      chatBuddyReceived(id, myid, "Buddy recived");
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
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => VideoCallScreen(
                                            remoteUid: int.tryParse(id),
                                            username: name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                                      radius: 30,
                                      child: const Icon(
                                        Icons.videocam_rounded,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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

  @override
  void dispose() {
    super.dispose();
    _interstitialAd!.dispose();
  }
}

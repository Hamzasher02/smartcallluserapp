import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skeletons/skeletons.dart';
import 'package:smart_call_app/Screens/call/agora/video_call_screen_1.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Util/video_call_fcm.dart';
import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';

import '../Screens/chat/chat_screen.dart';
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
  final Future<void> onFavoriteChange; // Callback function to notify parent

  const StatusBarListView(
      {super.key,
      required this.fakeUser,
      required this.myuser,
      required this.onFavoriteChange});

  @override
  State<StatusBarListView> createState() => _StatusBarListViewState();
}

class _StatusBarListViewState extends State<StatusBarListView> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded1 = false;

  void _startCall(String callType, String chatId, String currentUserId,
      String otherUserId) {
    if (kDebugMode) {
      print("The id of the current user is $currentUserId");
      print("The id of the other user is $otherUserId");
      print("The chat id is $chatId");
      print("The call type is $callType");
    }
    _databaseSource.storeCallInfo(
      chatId: chatId,
      myUserId: currentUserId,
      otherUserId: otherUserId,
      callType: callType,
      callStatus: "Started",
      isIncoming: false,
    );
  }

  void onCallEnd() {
    if (_isAdLoaded1 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Clear the current ad
      _isAdLoaded1 = false;
      _initializeAd(); // Load a new ad for the next call
    }
  }

  void onCallDecline() {
    if (_isAdLoaded1 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // Clear the current ad
      _isAdLoaded1 = false;
      _initializeAd(); // Load a new ad for the next call
    }
  }

  @override
  void initState() {
    player = AudioPlayer();
    //player.setAsset('assets/audio/ting.mp3');
    super.initState();
  }

  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  late AudioPlayer player;
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

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

  void _initializeAd() {
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded1 = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isAdLoaded1 = false;
        },
      ),
    );
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
                  widget.fakeUser[index].token,
                  context,
                  widget.fakeUser[index].type,
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

  showUserView(
      String token,
      BuildContext context,
      String type,
      String id,
      img,
      name,
      country,
      date,
      age,
      gender,
      view,
      like,
      myid,
      myuser,
      otherId,
      index,
      temp1) {
    int views;
    bool isFavorite =
        temp1 == "true"; // Initially set based on the 'temp1' field
    int likes = like; // Initialize likes counter
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
                  color: Theme.of(context).colorScheme.surface,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Name and Favorite Icon
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            bool newIsFavorite =
                                                !isFavorite; // Toggle favorite status
                                            int newLikes = likes +
                                                (newIsFavorite
                                                    ? 1
                                                    : -1); // Update like count

                                            try {
                                              // Update Firestore with new favorite status and like count
                                              _databaseSource.addFav(
                                                  id, newLikes);
                                              _databaseSource.addFav2(
                                                  id, newIsFavorite.toString());

                                              setState(() {
                                                isFavorite = newIsFavorite;
                                                likes = newLikes;
                                              });

                                              if (isFavorite) {
                                                await addF(myid, otherId,
                                                    "addF", index);
                                                player.setAsset(
                                                    'assets/audio/ting.mp3');
                                                player.play();

                                                Get.snackbar(
                                                  backgroundColor:
                                                      const Color(0xff607d8b),
                                                  snackPosition:
                                                      SnackPosition.TOP,
                                                  duration: const Duration(
                                                      seconds: 4),
                                                  "Favourites",
                                                  "$name is added to favorites.",
                                                );
                                              } else {
                                                await addF(myid, otherId,
                                                    "removeF", index);

                                                Get.snackbar(
                                                  backgroundColor:
                                                      const Color(0xff607d8b),
                                                  snackPosition:
                                                      SnackPosition.TOP,
                                                  duration: const Duration(
                                                      seconds: 4),
                                                  "Favourites",
                                                  "$name is removed from favorites.",
                                                );
                                              }
                                              widget
                                                  .onFavoriteChange; // Call the callback to update parent

                                              Navigator.pop(context);
                                            } catch (e) {
                                              print(
                                                  "Error updating favorites: $e");
                                            }
                                          },
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('$likes'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Country
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

                            /// Age
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Text(
                                    "Age: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$age",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// Gender
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Text(
                                    "Gender: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$gender",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),

                            /// Buttons
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      String chatId = compareAndCombineIds(
                                        myid,
                                        id,
                                      );
                                      Message1 message = Message1(
                                        epochTimeMs: DateTime.now()
                                            .millisecondsSinceEpoch,
                                        seen: false,
                                        senderId: myid,
                                        text: "Say Hello 👋",
                                        type: "text",
                                      );
                                      _databaseSource
                                          .addChat(Chat(chatId, message));
                                      chatBuddySent(myid, id, "Buddy Sent");
                                      chatBuddyReceived(
                                          id, myid, "Buddy received");
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                            gender: gender,
                                            userType: type,
                                            date: date,
                                            age: age,
                                            image: img,
                                            country: country,
                                            chatId:
                                                compareAndCombineIds(myid, id),
                                            myUserId: myid,
                                            otherUserId: id,
                                            otherUserName: name,
                                            user: myuser,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.7),
                                      radius: 30,
                                      child: const Icon(
                                        Icons.chat,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  type == "live"
                                      ? GestureDetector(
                                          onTap: () {
                                            String chatId =
                                                compareAndCombineIds(myid, id);

                                            _startCall(
                                                "video", chatId, myid, id);

                                            VideoCallFcm.sendCallNotification(
                                                FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .displayName ??
                                                    "",
                                                token,
                                                "smart_call_app",
                                                "007eJxTYGhc2MU2h+PQ9Yfb5tWdELZZeFrAYwNr7umsQ83G2x9zuJ9TYDC0SDZJTTaySDExSjFJSUpJtDQ0tTQ0MrEwt0g1S05KCmA2Sm8IZGS4yPeCkZEBAkF8Pobi3MSikvjkxJyc+MSCAgYGALgzI2c=",
                                                name);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoCallScreen1(
                                                  recieverName: name,
                                                  agoraAppId:
                                                      "18c4ec28d42d4dbda9159124878e6cbb",
                                                  agoraAppToken:
                                                      "007eJxTYGhc2MU2h+PQ9Yfb5tWdELZZeFrAYwNr7umsQ83G2x9zuJ9TYDC0SDZJTTaySDExSjFJSUpJtDQ0tTQ0MrEwt0g1S05KCmA2Sm8IZGS4yPeCkZEBAkF8Pobi3MSikvjkxJyc+MSCAgYGALgzI2c=",
                                                  agoraAppCertificate:
                                                      "064b1a009cc248afa93a01234876a4c9", // Use your dynamic token
                                                  agoraAppChannelName:
                                                      "smart_call_app",
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.videocam,
                                                size: 25,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      : type == "fake"
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DummyWaitingCallScreen(
                                                              userImage: img,
                                                              userName: name,
                                                            )));
                                              },
                                              child: const Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  radius: 30,
                                                  child: Icon(
                                                    Icons.videocam_rounded,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                ],
                              ),
                            ),

                            /// Date
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

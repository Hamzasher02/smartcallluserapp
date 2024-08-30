import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/chat/chat_screen.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Util/video_call_utils.dart';
import 'package:smart_call_app/Widgets/country_to_flag.dart';
import 'package:smart_call_app/Widgets/custom_card_tile.dart';
import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';
import 'package:smart_call_app/db/entity/app_user.dart';
import 'package:smart_call_app/db/entity/chat.dart';
import 'package:smart_call_app/db/entity/fvrt.dart';
import 'package:smart_call_app/db/entity/message.dart';
import 'package:smart_call_app/db/entity/sentmessage.dart';
import 'package:smart_call_app/db/entity/utils.dart';
import 'package:smart_call_app/db/remote/firebase_database_source.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ForYouPage extends StatefulWidget {
  final AppUser myuser;
  final String country;

  const ForYouPage({super.key, required this.myuser, required this.country});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
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

  // Convert the width to an integer
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded1 = false;
  late int screenWidthInt;
  late int screenHeghitInt;

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

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getCurrentUserStatusStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.myuser.id)
        .snapshots();
  }

  late ZegoUIKitPrebuiltCallInvitationService _callInvitationService;

  String generateCallId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void initState() {
    player = AudioPlayer();
    // Hook into the call end event

    //dataFireBase();
    super.initState();
    initZego();

    _initializeAd();
    if (kDebugMode) {
      print('Call ended or declined, triggering ad...');
    }
    if (_isAdLoaded1 && _interstitialAd != null) {
      _interstitialAd!.show();
      if (kDebugMode) {
        print('Interstitial ad shown successfully');
      }
      _interstitialAd = null;
      _isAdLoaded1 = false;
      _initializeAd(); // Load a new ad for the next time
    } else {
      if (kDebugMode) {
        print('Ad not ready or not loaded');
      }
    }

    dataFireBase();
  }

  void initZego() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('userId');
    String? storedUserName = prefs.getString('userName');

    if (kDebugMode) {
      print("Id of the current user is $storedUserId");
      print("Name of the current user is $storedUserName");
    }

    // Ensure userID and userName are not null before passing them to Zego
    await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: Utils.appId,
        appSign: Utils.appSignin,
        userID: storedUserId ?? "defaultUserId",
        userName: storedUserName ?? "defaultUserName",
        notifyWhenAppRunningInBackgroundOrQuit: true,
        androidNotificationConfig: ZegoAndroidNotificationConfig(
          channelID: "ZegoUIKit",
          channelName: "Call Notifications",
          sound: "notification",
          icon: "notification_icon",
        ),
        iOSNotificationConfig: ZegoIOSNotificationConfig(
          isSandboxEnvironment: false,
          systemCallingIconName: 'CallKitIcon',
        ),
        plugins: [ZegoUIKitSignalingPlugin()],
        requireConfig: (ZegoCallInvitationData data) {
          final config = (data.invitees.length > 1)
              ? ZegoCallType.videoCall == data.type
                  ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
              : ZegoCallType.videoCall == data.type
                  ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                  : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

          config.topMenuBarConfig.isVisible = true;
          config.topMenuBarConfig.buttons
              .insert(0, ZegoMenuBarButtonName.minimizingButton);
          // Handle when the call ends

          // Handle when the call ends
          // config.onHangUpConfirmation = (context) async {
          //   onCallEnd();
          //   return Future.value(true);
          // };

          // // Handle when the call is declined
          // config.onHangUp = () {
          //   onCallDecline();
          // };

          return config;
        });
  }

  void _uninitializeCallInvitationService() {
    _callInvitationService.uninit();
  }

  String country = 'Country';

  String myid = '';
  List result = [];
  AppUser? myuser;
  late AudioPlayer player;
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  bool _isAdLoaded = false;
  int counterAd = 0;

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
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded = true;
  }

  Future _refresh() async {
    print("in refresh");
    setState(() {
      //dataFireBase();
      result.shuffle();
    });
  }

  List ignorids = [];
  bool tempcheck = false;

  dataFireBase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myid = prefs.getString("myid")!;
    print("Current User id is $myid");

    // await db
    //     .collection("users")
    //     .doc(myid)
    //     .collection("blockedusers")
    //     .get()
    //     .then((event) async {
    //
    //   //  print(event.docs.length);
    //   for (var doc in event.docs) {
    //     ignorids.add(doc.data()['id']);
    //   }
    ignorids.add(myid);
    // });
    // print('hellllo');
    print(ignorids);

    print(widget.country);
    if (widget.country == "random") {
      await db.collection("users").get().then((event) async {
        result = [];
        var count = 0;
        print(event.docs);
        for (var doc in event.docs) {
          result.add(AppUser(
            id: doc.data()['id'],
            name: doc.data()['name'],
            gender: doc.data()['gender'],
            age: doc.data()['age'],
            country: doc.data()['country'],
            profilePhotoPath: doc.data()['profile_photo_path'],
            token: doc.data()['token'],
            temp1: doc.data()['temp1'],
            temp2: doc.data()['temp2'],
            temp3: doc.data()['temp3'],
            temp4: doc.data()['temp4'],
            temp5: doc.data()['temp5'],
            status: doc.data()['status'],
            likes: doc.data()['likes'],
            type: doc.data()['type'],
            views: doc.data()['views'],
          ));
          result.shuffle();
          count++;
          if (count == event.docs.length) break;
        }
      });
    } else {
      await db
          .collection("users")
          .where("country", isEqualTo: widget.country)
          .get()
          .then((event) async {
        result = [];
        var count = 0;
        print(event.docs);
        for (var doc in event.docs) {
          result.add(AppUser(
            id: doc.data()['id'],
            name: doc.data()['name'],
            gender: doc.data()['gender'],
            age: doc.data()['age'],
            country: doc.data()['country'],
            profilePhotoPath: doc.data()['profile_photo_path'],
            token: doc.data()['token'],
            temp1: doc.data()['temp1'],
            temp2: doc.data()['temp2'],
            temp3: doc.data()['temp3'],
            temp4: doc.data()['temp4'],
            temp5: doc.data()['temp5'],
            status: doc.data()['status'],
            likes: doc.data()['likes'],
            type: doc.data()['type'],
            views: doc.data()['views'],
          ));
          result.shuffle();
          count++;
          if (count == event.docs.length) break;
        }
      });
    }
    int i = 0, j = 0;
    print(result.length);
    for (i = 0; i < ignorids.length; i++) {
      for (j = 0; j < result.length; j++) {
        if (ignorids[i] == result[j].id) {
          print(ignorids[i]);
          print(result[j].id);
          print(result.length);
          result.removeAt(j);
          print('removed');
          print(result.length);
          // array2_length = len(array2)
        }
      }
      if (i == ignorids.length) {
        tempcheck = true;
      }
    }
    //result.shuffle();
    if (tempcheck == true) {
      Future.delayed(const Duration(seconds: 2), () {
        return result;
      });
    }
  }

  addF(String myId, String otherId, String added, index) async {
    if (added == "addF") {
      // Add favorite
      await _databaseSource.addFavourite(myId, AddFavourites(otherId, added));
    } else {
      // Remove favorite
      await _databaseSource.removeFavourite(myId, otherId);
    }
  }

  int showZeroIfNegative(int number) {
    if (number >= 0) {
      return number;
    } else {
      return 0;
    }
  }

  showUserView(BuildContext context, String type, String id, img, name, country,
      date, age, gender, view, like, myid, myuser, otherId, index, temp1) {
    int views = view + 1;
    bool isFavorite =
        temp1 == "true"; // Initially set based on the 'temp1' field
    int likes = like; // Initialize likes counter

    // Update views in Firestore
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
                                            setState(() {
                                              isFavorite = !isFavorite;
                                              likes += isFavorite ? 1 : -1;
                                            });

                                            // Update the like count and favorite status in Firestore
                                            _databaseSource.addFav(id, likes);
                                            _databaseSource.addFav2(
                                                id, isFavorite.toString());

                                            if (isFavorite) {
                                              await addF(
                                                  myid, otherId, "addF", index);
                                              player.setAsset(
                                                  'assets/audio/ting.mp3');
                                              player.play();

                                              // Dismiss the dialog
                                              Navigator.pop(context);

                                              // Show Snackbar after the dialog is dismissed
                                              Future.delayed(Duration.zero, () {
                                                Get.snackbar(
                                                    backgroundColor:
                                                        const Color(0xff607d8b),
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    duration:
                                                        Duration(seconds: 4),
                                                    "Favourites",
                                                    "$name is added in the favorites by you. See in the Favorite tab");
                                              });
                                            } else {
                                              await addF(myid, otherId,
                                                  "removeF", index);

                                              // Dismiss the dialog
                                              Navigator.pop(context);

                                              // Show Snackbar after the dialog is dismissed
                                              Future.delayed(Duration.zero, () {
                                                Get.snackbar(
                                                    backgroundColor:
                                                        const Color(0xff607d8b),
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    duration: const Duration(
                                                        seconds: 4),
                                                    "Favourites",
                                                    "$name is removed from the favorites by you.");
                                              });
                                            }
                                          },
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.redAccent
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            size: 20,
                                          ),
                                        ),
                                        Text(
                                          showZeroIfNegative(likes).toString(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
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
                                      Message message = Message(
                                        DateTime.now().millisecondsSinceEpoch,
                                        false,
                                        myid,
                                        "Say Hello 👋",
                                        "text",
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
                                            date:date,
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
                                      ? SizedBox(
                                          width: 90.0, // Set your desired width
                                          height:
                                              90.0, // Set your desired height
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: ZegoSendCallInvitationButton(
                                              isVideoCall: true,
                                              resourceID: "zegouikit_call",
                                              invitees: [
                                                ZegoUIKitUser(
                                                  id: id,
                                                  name: name,
                                                ),
                                              ],
                                              icon: ButtonIcon(
                                                  icon: const Icon(
                                                    Icons.videocam_rounded,
                                                    size: 50,
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor:
                                                      Colors.green),
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

  void chatBuddySent(String myid, String otherid, String sent) async {
    _databaseSource.addChatBuddy(myid, SentMessage(otherid, sent));
  }

  void chatBuddyReceived(String otherid, String myid, String received) async {
    //_databaseSource.addMessageRequestRecived(otherid, ReceivedRequest(myid, received));
    _databaseSource.addChatBuddy(otherid, SentMessage(myid, received));
  }

  @override
  Widget build(BuildContext context) {
    screenWidthInt = MediaQuery.of(context)
        .size
        .width
        .toInt(); // Obtain and convert screen width
    screenHeghitInt = (MediaQuery.of(context).size.height * 0.135).round();
    return FutureBuilder(
      future: dataFireBase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }

        return Scaffold(
          // backgroundColor: Theme.of(context).colorScheme.surface,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          body: RefreshIndicator(
            color: Theme.of(context).colorScheme.onPrimary,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: _refresh,
            child: result.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_outlined),
                        SizedBox(
                          height: 10,
                        ),
                        // Lottie.asset('assets/lottie/no data found.json',width: 200),
                        Text(
                          'No User Found',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: _getCurrentUserStatusStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          // Fetch the updated status
                          final userData = snapshot.data?.data();
                          String currentUserStatus =
                              userData?['status'] ?? 'offline';

                          // Use the currentUserStatus to control the dot color
                          return Expanded(
                            child: ListView.builder(
                              itemCount: result.length + (result.length ~/ 5),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                if (index != 0 && index % 5 == 0) {
                                  return getAd();
                                } else {
                                  final int itemIndex = index - (index ~/ 5);
                                  return GestureDetector(
                                    onTap: () {
                                      // Show user view or other actions
                                      if (kDebugMode) {
                                        print(
                                            "The type of the user is ${result[itemIndex].type}");
                                      }
                                      showUserView(
                                        context,
                                        result[itemIndex].type,
                                        result[itemIndex].id,
                                        result[itemIndex].profilePhotoPath,
                                        result[itemIndex].name,
                                        result[itemIndex].country,
                                        
                                        dateFormat.format(DateTime.now()),
                                        result[itemIndex].age,
                                        result[itemIndex].gender,
                                        result[itemIndex].views,
                                        result[itemIndex].likes,
                                        myid,
                                        widget.myuser,
                                        result[itemIndex].id,
                                        itemIndex,
                                        result[itemIndex].temp1,
                                      );
                                      setState(() {
                                        counterAd++;
                                        print("counterAD: $counterAd");
                                        if (counterAd == 4) {
                                          if (_isAdLoaded) {
                                            _interstitialAd!.show();
                                            setState(() {
                                              counterAd == 0;
                                            });
                                          }
                                        }
                                      });
                                    },
                                    child: CustomCardTile(
                                      currentUserId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      currentUserName: FirebaseAuth.instance
                                              .currentUser!.displayName ??
                                          "",
                                      id: result[itemIndex].id,
                                      name: result[itemIndex].name,
                                      age: result[itemIndex].age,
                                      gender: result[itemIndex].gender,
                                      country: result[itemIndex].country,
                                      myId: widget.myuser.id,
                                      profileImage:
                                          result[itemIndex].profilePhotoPath,
                                      status: result[itemIndex].status,
                                      myStatus: currentUserStatus,
                                      onTapImage: () {
                                        // Show user view or other actions
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget getAd() {
    BannerAd bannerAd = BannerAd(
      size: AdSize(width: screenWidthInt, height: screenHeghitInt),
      adUnitId: AppUrls.nativeAdID,
      listener: BannerAdListener(
        onAdWillDismissScreen: (ad) {
          ad.dispose();
        },
        onAdClosed: (ad) {
          print("Ad closed");
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
    );

    bannerAd.load();

    return Container(
      height: MediaQuery.of(context).size.height *
          0.135, // Match the height of CustomCardTile
      child: Align(
        alignment: Alignment.center,
        child: SizedBox.expand(
          child: AdWidget(
            ad: bannerAd,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd!.dispose();
    _uninitializeCallInvitationService();
  }
}

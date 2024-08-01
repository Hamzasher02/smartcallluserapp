import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Screens/call/agora/screen_video_call.dart';
import 'package:smart_call_app/Screens/chat/chat_screen.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Widgets/country_to_flag.dart';
import 'package:smart_call_app/Widgets/custom_card_tile.dart';
import 'package:smart_call_app/db/entity/app_user.dart';
import 'package:smart_call_app/db/entity/chat.dart';
import 'package:smart_call_app/db/entity/fvrt.dart';
import 'package:smart_call_app/db/entity/message.dart';
import 'package:smart_call_app/db/entity/sentmessage.dart';
import 'package:smart_call_app/db/entity/utils.dart';
import 'package:smart_call_app/db/remote/firebase_database_source.dart';

class ForYouPage extends StatefulWidget {
  final AppUser myuser;
  final String country;

  const ForYouPage({super.key, required this.myuser, required this.country});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  @override
  void initState() {
    player = AudioPlayer();
    //dataFireBase();
    super.initState();
    initAd();
  }

  String country = 'Country';

  String myid = '';
  List result = [];
  AppUser? myuser;
  late AudioPlayer player;
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  InterstitialAd? _interstitialAd;
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
    print(myid);

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
      await db.collection("users").where("country", isEqualTo: widget.country).get().then((event) async {
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

  addF(String myId, String otherId, String added, index) {
    _databaseSource.addFavourites(myId, AddFavourites(otherId, added));
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
    print(id);
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
                                          onTap: fvtVisible
                                              ? null
                                              : () async {
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
                                                  if (_isAdLoaded) {
                                                    _interstitialAd!.show();
                                                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                                      MaterialPageRoute(builder: (context) => const MainPage(tab: 0)),
                                                      (route) => false,
                                                    );
                                                  }
                                                },
                                          child: Icon(
                                            temp1 != "" || fvtVisible ? Icons.favorite : Icons.favorite_border,
                                            color: temp1 != "" || fvtVisible ? Colors.redAccent : Colors.black,
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
                                  // ZegoSendCallInvitationButton(
                                  //     isVideoCall: true,
                                  //     resourceID: "hafeez_khan",
                                  //     //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                                  //     invitees: [
                                  //       ZegoUIKitUser(
                                  //         id: id,
                                  //         name: name,
                                  //       )
                                  //     ])
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

  void chatBuddySent(String myid, String otherid, String sent) async {
    _databaseSource.addChatBuddy(myid, SentMessage(otherid, sent));
  }

  void chatBuddyReceived(String otherid, String myid, String received) async {
    //_databaseSource.addMessageRequestRecived(otherid, ReceivedRequest(myid, received));
    _databaseSource.addChatBuddy(otherid, SentMessage(myid, received));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataFireBase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey,
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: result.length + (result.length ~/ 5),
                          itemBuilder: (BuildContext context, int index) {
                            if (index != 0 && index % 5 == 0) {
                              return getAd();
                            } else {
                              final int itemIndex = index - (index ~/ 5);
                              return GestureDetector(
                                onTap: () {
                                  showUserView(
                                    context,
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
                                  id: result[itemIndex].id,
                                  name: result[itemIndex].name,
                                  age: result[itemIndex].age,
                                  gender: result[itemIndex].gender,
                                  country: result[itemIndex].country,
                                  profileImage: result[itemIndex].profilePhotoPath,
                                  status: result[itemIndex].status,
                                  onTapImage: () {
                                    showUserView(
                                      context,
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
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget getAd() {
    BannerAdListener bannerAdListener = BannerAdListener(onAdWillDismissScreen: (ad) {
      ad.dispose();
    }, onAdClosed: (ad) {
      print("add closed");
    });
    BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AppUrls.nativeAdID,
      listener: const BannerAdListener(),
      request: const AdRequest(),
    );

    bannerAd.load();

    return SizedBox(
      height: 100,
      child: AdWidget(
        ad: bannerAd,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd!.dispose();
  }
}

// import 'dart:developer';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:intl/intl.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_call_app/Screens/call/agora/screen_video_call.dart';
// import 'package:smart_call_app/Util/share_preferences.dart';
// import 'package:smart_call_app/Widgets/call_with_timer.dart';
// import 'package:smart_call_app/Widgets/custom_card_tile.dart';
// import 'package:smart_call_app/db/entity/fvrt.dart';
// import '../chat/chat_screen.dart';
// import '../../Widgets/country_to_flag.dart';
// import '../../db/entity/app_user.dart';
// import '../../db/entity/chat.dart';
// import '../../db/entity/message.dart';
// import '../../db/entity/sentmessage.dart';
// import '../../db/entity/utils.dart';
// import '../../db/remote/firebase_database_source.dart';
//
// class ForYouPage extends StatefulWidget {
//   final AppUser myuser;
//   final String country;
//
//   const ForYouPage({super.key, required this.myuser, required this.country});
//
//   @override
//   State<ForYouPage> createState() => _ForYouPageState();
// }
//
// class _ForYouPageState extends State<ForYouPage> {
//   NativeAd? _nativeAd;
//   bool _nativeAdIsLoaded = false;
//   String myid = '';
//
//   //List result = [];
//   List result = [];
//   AppUser? myuser;
//   late AudioPlayer player;
//   final dateFormat = DateFormat('yyyy-MM-dd hh:mm');
//
//   FirebaseFirestore db = FirebaseFirestore.instance;
//   final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
//   final s1 = S1();
//   bool fvtVisible = false;
//   bool? valueGet;
//   List ignorids = [];
//   bool tempcheck = false;
//
//   @override
//   void initState() {
//     super.initState();
//     //getAd();
//     player = AudioPlayer();
//     player.setAsset('assets/audio/ting.mp3');
//     print(widget.country);
//     dataFireBase();
//   }
//
//   Future _refresh() async {
//     setState(() {
//       result.shuffle();
//     });
//   }
//
//   dataFireBase() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String myid = prefs.getString("myid")!;
//       log(myid);
//
//       List<String> ignorids = [myid];
//       log("$ignorids");
//       log("country for you: ${widget.country}");
//       //QuerySnapshot<Map<String, dynamic>> querySnapshot;
//       result = [];
//       if (widget.country == "random") {
//         await db.collection("users").get().then((value) {
//           result = [];
//           for (var doc in value.docs) {
//             setState(() {
//               result.add(AppUser.fromSnapshot(doc));
//             });
//           }
//         });
//       } else {
//         await db.collection("users").where("country", isEqualTo: widget.country).get().then((value) {
//           result = [];
//           for (var doc in value.docs) {
//             setState(() {
//               result.add(AppUser.fromSnapshot(doc));
//             });
//           }
//         });
//       }
//       // for (var doc in querySnapshot.docs) {
//       //   // Populate the result list with AppUser objects
//       //   result.add(AppUser(
//       //     id: doc['id'],
//       //     name: doc['name'],
//       //     gender: doc['gender'],
//       //     age: doc['age'],
//       //     country: doc['country'],
//       //     profilePhotoPath: doc['profile_photo_path'],
//       //     token: doc['token'],
//       //     temp1: doc['temp1'],
//       //     temp2: doc['temp2'],
//       //     temp3: doc['temp3'],
//       //     temp4: doc['temp4'],
//       //     temp5: doc['temp5'],
//       //     status: doc['status'],
//       //     likes: doc['likes'],
//       //     type: doc['type'],
//       //     views: doc['views'],
//       //   ));
//       // }
//
//       int i = 0, j = 0;
//       print(result.length);
//       for (i = 0; i < ignorids.length; i++) {
//         for (j = 0; j < result.length; j++) {
//           if (ignorids[i] == result[j].id) {
//             print(ignorids[i]);
//             print(result[j].id);
//             print(result.length);
//             result.removeAt(j);
//             print('removed');
//             print(result.length);
//             // array2_length = len(array2)
//           }
//         }
//         if (i == ignorids.length) {
//           tempcheck = true;
//         }
//       }
//
//       result.shuffle();
//       if (tempcheck == true) {
//         Future.delayed(const Duration(seconds: 2), () {
//           return result;
//         });
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }
//
//   // dataFireBase() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   myid = prefs.getString("myid")!;
//   //   print(myid);
//   //   ignorids.add(myid);
//   //   print(ignorids);
//   //
//   //   print(widget.country);
//   //   if (widget.country == "random") {
//   //     await db.collection("users").get().then((event) async {
//   //       result.clear();
//   //       var count = 0;
//   //       print(event.docs);
//   //       for (var doc in event.docs) {
//   //         result.add(AppUser(
//   //           id: doc.data()['id'],
//   //           name: doc.data()['name'],
//   //           gender: doc.data()['gender'],
//   //           age: doc.data()['age'],
//   //           country: doc.data()['country'],
//   //           profilePhotoPath: doc.data()['profile_photo_path'],
//   //           token: doc.data()['token'],
//   //           temp1: doc.data()['temp1'],
//   //           temp2: doc.data()['temp2'],
//   //           temp3: doc.data()['temp3'],
//   //           temp4: doc.data()['temp4'],
//   //           temp5: doc.data()['temp5'],
//   //           status: doc.data()['status'],
//   //           likes: doc.data()['likes'],
//   //           type: doc.data()['type'],
//   //           views: doc.data()['views'],
//   //         ));
//   //         setState(() {});
//   //         count++;
//   //         if (count == event.docs.length) break;
//   //       }
//   //     });
//   //   } else {
//   //     await db.collection("users").where("country", isEqualTo: widget.country).get().then((event) async {
//   //       result.clear();
//   //       var count = 0;
//   //       print(event.docs);
//   //       for (var doc in event.docs) {
//   //         result.add(AppUser(
//   //           id: doc.data()['id'],
//   //           name: doc.data()['name'],
//   //           gender: doc.data()['gender'],
//   //           age: doc.data()['age'],
//   //           country: doc.data()['country'],
//   //           profilePhotoPath: doc.data()['profile_photo_path'],
//   //           token: doc.data()['token'],
//   //           temp1: doc.data()['temp1'],
//   //           temp2: doc.data()['temp2'],
//   //           temp3: doc.data()['temp3'],
//   //           temp4: doc.data()['temp4'],
//   //           temp5: doc.data()['temp5'],
//   //           status: doc.data()['status'],
//   //           likes: doc.data()['likes'],
//   //           type: doc.data()['type'],
//   //           views: doc.data()['views'],
//   //         ));
//   //         setState(() {});
//   //         count++;
//   //         if (count == event.docs.length) break;
//   //       }
//   //     });
//   //   }
//   //   int i = 0, j = 0;
//   //   print(result.length);
//   //   for (i = 0; i < ignorids.length; i++) {
//   //     for (j = 0; j < result.length; j++) {
//   //       if (ignorids[i] == result[j].id) {
//   //         print(ignorids[i]);
//   //         print(result[j].id);
//   //         print(result.length);
//   //         result.removeAt(j);
//   //         print('removed');
//   //         print(result.length);
//   //         // array2_length = len(array2)
//   //       }
//   //     }
//   //     if (i == ignorids.length) {
//   //       tempcheck = true;
//   //     }
//   //   }
//   //   if (tempcheck == true) {
//   //     setState(() {
//   //       result.shuffle(); // Shuffle the result list
//   //       shuffleResult = List.from(result);
//   //     }); // Update the UI with the new data
//   //     return shuffleResult;
//   //   }
//   // }
//
//   addF(String myId, String otherId, String added, index) {
//     _databaseSource.addFavourites(myId, AddFavourites(otherId, added));
//   }
//
//   showUserView(String id, img, name, country, date, age, gender, view, like, myid, myuser, otherId, index) async {
//     loadAd();
//     _interstitialAd?.show();
//     int views;
//     print(view);
//     views = view + 1;
//     print(views);
//     _databaseSource.addView(id, views);
//     showAnimatedDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext childContext) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               contentPadding: EdgeInsets.zero,
//               content: SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.8,
//                 width: MediaQuery.of(context).size.width * 0.9,
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
//                         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//                         child: Column(
//                           children: [
//                             /// name and fvrt
//                             Expanded(
//                               flex: 2,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     flex: 2,
//                                     child: Text(
//                                       name,
//                                       style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     flex: 1,
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                       children: [
//                                         GestureDetector(
//                                           onTap: fvtVisible
//                                               ? () {
//                                                   addF(myid, otherId, "addF", index);
//                                                   like = like - 1;
//                                                   _databaseSource.addFav(id, like);
//                                                   result[index].likes = like;
//                                                   //player.play();
//                                                   setState(() {
//                                                     fvtVisible = !fvtVisible;
//                                                     s1.saveValue(
//                                                       key: "add_f",
//                                                       value: fvtVisible,
//                                                     );
//                                                   });
//                                                 }
//                                               : () {
//                                                   addF(myid, otherId, "addF", index);
//                                                   like = like + 1;
//                                                   result[index].likes = like;
//                                                   _databaseSource.addFav(id, like);
//                                                   player.play();
//                                                   setState(() {
//                                                     fvtVisible = !fvtVisible;
//                                                     s1.saveValue(
//                                                       key: "remove_f",
//                                                       value: fvtVisible,
//                                                     );
//                                                   });
//                                                 },
//                                           child: Icon(
//                                             fvtVisible ? Icons.favorite : Icons.favorite_border,
//                                             color: fvtVisible ? Colors.redAccent : Colors.redAccent,
//                                             size: 20,
//                                           ),
//                                         ),
//                                         Text(
//                                           like.toString(),
//                                           style: const TextStyle(fontSize: 18),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             /// country
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
//                                     style: Theme.of(context).textTheme.titleMedium!.copyWith(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             /// date
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     date,
//                                     style: Theme.of(context).textTheme.titleMedium!.copyWith(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             /// age
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     "Age: ",
//                                     style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     "$age",
//                                     style: Theme.of(context).textTheme.titleMedium!.copyWith(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             /// gender
//                             Expanded(
//                               flex: 1,
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     "Gender: ",
//                                     style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     "$gender",
//                                     style: Theme.of(context).textTheme.titleMedium!.copyWith(),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                             /// buttons
//                             Expanded(
//                               flex: 2,
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () {
//                                       String chatId = compareAndCombineIds(
//                                         myid,
//                                         id,
//                                       );
//                                       Message message = Message(
//                                         DateTime.now().millisecondsSinceEpoch,
//                                         false,
//                                         myid,
//                                         "Say Hello 👋",
//                                         "text",
//                                       );
//                                       _databaseSource.addChat(Chat(chatId, message));
//                                       chatBuddySent(myid, id, "Buddy Sent");
//                                       //messagerequestreceived(userid, myid, "received");
//                                       chatBuddyReceived(id, myid, "Buddy recived");
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (context) => MessageScreen(
//                                             chatId: compareAndCombineIds(myid, id),
//                                             myUserId: myid,
//                                             otherUserId: id,
//                                             user: myuser,
//                                             otherUserName: name,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: CircleAvatar(
//                                       backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
//                                       radius: 30,
//                                       child: const Icon(
//                                         Icons.chat,
//                                         size: 30,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.of(context).push(
//                                         MaterialPageRoute(
//                                           builder: (context) => VideoCallScreen(
//                                             remoteUid: int.tryParse(id),
//                                             username: name,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: CircleAvatar(
//                                       backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
//                                       radius: 30,
//                                       child: const Icon(
//                                         Icons.video_call,
//                                         size: 30,
//                                         color: Colors.lightGreenAccent,
//                                       ),
//                                     ),
//                                   ),
//                                   // CallWithTime(
//                                   //   id: id,
//                                   //   name: name,
//                                   //   height: 60,
//                                   //   width: 60,
//                                   //   video: true,
//                                   // )
//                                   // ZegoSendCallInvitationButton(
//                                   //     isVideoCall: true,
//                                   //     resourceID: "hafeez_khan",
//                                   //     //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
//                                   //     invitees: [
//                                   //       ZegoUIKitUser(
//                                   //         id: id,
//                                   //         name: name,
//                                   //       )
//                                   //     ])
//                                 ],
//                               ),
//                             ),
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
//
//   void chatBuddySent(String myid, String otherid, String sent) async {
//     _databaseSource.addChatBuddy(myid, SentMessage(otherid, sent));
//   }
//
//   void chatBuddyReceived(String otherid, String myid, String received) async {
//     //_databaseSource.addMessageRequestRecived(otherid, ReceivedRequest(myid, received));
//     _databaseSource.addChatBuddy(otherid, SentMessage(myid, received));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey,
//       body: RefreshIndicator(
//         color: Theme.of(context).colorScheme.onPrimary,
//         triggerMode: RefreshIndicatorTriggerMode.onEdge,
//         onRefresh: _refresh,
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: result.length + (result.length ~/ 5),
//                 itemBuilder: (BuildContext context, int index) {
//                   if (index != 0 && index % 5 == 0) {
//                     return FutureBuilder(
//                         future: getAd(),
//                         builder: (BuildContext context, snapshot) {
//                           if (snapshot.hasData) {
//                             AdWidget ad = snapshot.data as AdWidget;
//                             print("snap: $snapshot");
//                             return ConstrainedBox(
//                                 constraints: const BoxConstraints(
//                                   minWidth: 320, // minimum recommended width
//                                   minHeight: 90, // minimum recommended height
//                                   maxWidth: 400,
//                                   maxHeight: 200,
//                                 ),
//                                 child: ad);
//                           } else {
//                             return Container(
//                                 alignment: Alignment.topCenter,
//                                 margin: const EdgeInsets.only(top: 20),
//                                 child: const CircularProgressIndicator(
//                                   value: 0.8,
//                                 ));
//                           }
//                         });
//                   } else {
//                     final int itemIndex = index - (index ~/ 5);
//                     return GestureDetector(
//                       onTap: () {
//                         showUserView(
//                           result[itemIndex].id,
//                           result[itemIndex].profilePhotoPath,
//                           result[itemIndex].name,
//                           result[itemIndex].country,
//                           "${dateFormat.format(DateTime.now())}",
//                           result[itemIndex].age,
//                           result[itemIndex].gender,
//                           result[itemIndex].views,
//                           result[itemIndex].likes,
//                           myid,
//                           widget.myuser,
//                           result[itemIndex].id,
//                           itemIndex,
//                         );
//                       },
//                       child: CustomCardTile(
//                         onTapImage: () {
//                           showUserView(
//                             result[itemIndex].id,
//                             result[itemIndex].profilePhotoPath,
//                             result[itemIndex].name,
//                             result[itemIndex].country,
//                             "${dateFormat.format(DateTime.now())}",
//                             result[itemIndex].age,
//                             result[itemIndex].gender,
//                             result[itemIndex].views,
//                             result[itemIndex].likes,
//                             myid,
//                             widget.myuser,
//                             result[itemIndex].id,
//                             itemIndex,
//                           );
//                         },
//                         id: result[itemIndex].id,
//                         name: result[itemIndex].name,
//                         age: result[itemIndex].age,
//                         gender: result[itemIndex].gender,
//                         country: result[itemIndex].country,
//                         profileImage: result[itemIndex].profilePhotoPath,
//                         status: result[itemIndex].status,
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<Widget> getAd() async {
//     _nativeAd = NativeAd(
//       adUnitId: "ca-app-pub-3940256099942544/2247696110",
//       listener: NativeAdListener(
//         onAdLoaded: (ad) {
//           debugPrint('$NativeAd loaded.');
//           setState(() {
//             _nativeAdIsLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           debugPrint('$NativeAd failed to load: $error');
//           ad.dispose();
//         },
//       ),
//       factoryId: 'adFactoryExample',
//       request: const AdRequest(),
//       nativeTemplateStyle: NativeTemplateStyle(
//         templateType: TemplateType.small,
//         mainBackgroundColor: Colors.purple,
//         cornerRadius: 10.0,
//         callToActionTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.cyan,
//           backgroundColor: Colors.red,
//           style: NativeTemplateFontStyle.monospace,
//           size: 16.0,
//         ),
//         primaryTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.red,
//           backgroundColor: Colors.cyan,
//           style: NativeTemplateFontStyle.italic,
//           size: 16.0,
//         ),
//         secondaryTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.green,
//           backgroundColor: Colors.black,
//           style: NativeTemplateFontStyle.bold,
//           size: 16.0,
//         ),
//         tertiaryTextStyle: NativeTemplateTextStyle(
//           textColor: Colors.brown,
//           backgroundColor: Colors.amber,
//           style: NativeTemplateFontStyle.normal,
//           size: 16.0,
//         ),
//       ),
//     );
//     await _nativeAd!.load();
//     return AdWidget(
//       ad: _nativeAd!,
//       key: Key(_nativeAd!.hashCode.toString()),
//     );
//   }
//
//   InterstitialAd? _interstitialAd;
//
//   void loadAd() {
//     InterstitialAd.load(
//         adUnitId: "ca-app-pub-3940256099942544/6300978111",
//         request: const AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//           // Called when an ad is successfully received.
//           onAdLoaded: (ad) {
//             ad.fullScreenContentCallback = FullScreenContentCallback(
//                 // Called when the ad showed the full screen content.
//                 onAdShowedFullScreenContent: (ad) {},
//                 // Called when an impression occurs on the ad.
//                 onAdImpression: (ad) {},
//                 // Called when the ad failed to show full screen content.
//                 onAdFailedToShowFullScreenContent: (ad, err) {
//                   // Dispose the ad here to free resources.
//                   ad.dispose();
//                 },
//                 // Called when the ad dismissed full screen content.
//                 onAdDismissedFullScreenContent: (ad) {
//                   // Dispose the ad here to free resources.
//                   ad.dispose();
//                 },
//                 // Called when a click is recorded for an ad.
//                 onAdClicked: (ad) {});
//
//             debugPrint('$ad loaded.');
//             // Keep a reference to the ad so you can show it later.
//             _interstitialAd = ad;
//           },
//           // Called when an ad request failed.
//           onAdFailedToLoad: (LoadAdError error) {
//             debugPrint('InterstitialAd failed to load: $error');
//           },
//         ));
//   }
// }

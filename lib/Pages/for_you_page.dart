import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Widgets/call_with_timer.dart';
import 'package:smart_call_app/Widgets/custom_card_tile.dart';
import 'package:smart_call_app/db/entity/fvrt.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../Screens/chat/chat_screen.dart';
import '../Util/constants.dart';
import '../Widgets/country_to_flag.dart';
import '../Widgets/view_user.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';

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
    player.setAsset('assets/audio/ting.mp3');
    dataFireBase();
    super.initState();
  }

  String country = 'Country';

  String myid = '';
  List result = [];
  AppUser? myuser;
  late AudioPlayer player;
  final dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  Future _refresh() async {
    print("in refresh");
    setState(() {
      dataFireBase();
      result.shuffle();
    });
  }

  // String token1='007';
  // void getToken() async{
  //   await FirebaseMessaging.instance.getToken().then((value) {
  //     print(value);
  //     token1=value!;
  //     saveToken(token1);
  //   });
  // }
  // void saveToken(String token) async {
  //   try{
  //     await FirebaseFirestore.instance.collection('users').doc(myid).update({
  //       'token': token,
  //     });
  //   }
  //   catch(e){
  //     print(e.toString());
  //   }
  // }

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
      await db.collection("users").where('type', isEqualTo: 'live').get().then((event) async {
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
                                  CallWithTime(
                                    id: id,
                                    name: name,
                                    height: 60,
                                    width: 60,
                                    video: true,
                                  )
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataFireBase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Scaffold(
          backgroundColor: Colors.grey,
          body: RefreshIndicator(
            color: Theme.of(context).colorScheme.onPrimary,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: _refresh,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: result.length  + (result.length ~/ 5),
                    itemBuilder: (BuildContext context, int index) {
                      if (index != 0 && index % 5 == 0) {
                        return getAd();
                      }else {
                        final int itemIndex = index - (index ~/ 5);
                        return GestureDetector(
                          onTap: () {
                            showUserView(
                              context,
                              result[itemIndex].id,
                              result[itemIndex].profilePhotoPath,
                              result[itemIndex].name,
                              result[itemIndex].country,
                              "${dateFormat.format(DateTime.now())}",
                              result[itemIndex].age,
                              result[itemIndex].gender,
                              result[itemIndex].views,
                              result[itemIndex].likes,
                              myid,
                              widget.myuser,
                              result[itemIndex].id,
                              itemIndex,
                            );
                          },
                          child: CustomCardTile(
                            id: result[itemIndex].id,
                            name: result[itemIndex].name,
                            age: result[itemIndex].age,
                            gender: result[itemIndex].gender,
                            country: result[itemIndex].country,
                            profileImage: result[itemIndex].profilePhotoPath,
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
    BannerAd bannerAd = BannerAd(size: AdSize.banner, adUnitId: "ca-app-pub-3940256099942544/6300978111", listener: BannerAdListener(), request: AdRequest());

    bannerAd.load();

    return SizedBox(
      height: 100,
      child: AdWidget(
        ad: bannerAd,
      ),
    );
  }
}

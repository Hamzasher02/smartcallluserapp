import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  Future _refresh() async {
    print("in refresh");
    setState(() {
      dataFireBase();
    });
  }

  String myid = '';
  List result = [];
  AppUser? myuser;
  late AudioPlayer player;

  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

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
    if(widget.country=="random"){
    await db.collection("users").where('type',isEqualTo: 'live').get().then((event) async {
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
    });}else
      {
        await db.collection("users").where("country",isEqualTo: widget.country).get().then((event) async {
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
    result.shuffle();
    if (tempcheck == true) {
      Future.delayed(new Duration(seconds: 20), () {
        return result;
      });
    }
  }

  addF(String myId, String otherId, String added, index) {
    _databaseSource.addFavourites(myId, AddFavourites(otherId, added));
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
                              Country.tryParse(country)!.name,
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
                            CallWithTime(id: id, name: name, height: 80, width:80, video: true,)
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
                  )));
        });
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
                        itemCount: result.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(index%10==0){
                            return getAd();
                          }
                          return GestureDetector(
                            onTap: () {
                              showUserView(
                                  context,
                                  result[index].id,
                                  result[index].profilePhotoPath,
                                  result[index].name,
                                  result[index].country,
                                  "01-11-2022",
                                  result[index].age,
                                  result[index].gender,
                                  result[index].views,
                                  result[index].likes,
                                  myid,
                                  widget.myuser,
                                  result[index].id,
                                  index);
                            },
                            child: CustomCardTile(
                              id: result[index].id,
                              name: result[index].name,
                              age: result[index].age,
                              gender: result[index].gender,
                              country: result[index].country,
                              profileImage: result[index].profilePhotoPath,
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        });
  }
  Widget getAd(){
    BannerAdListener bannerAdListener = BannerAdListener(
        onAdWillDismissScreen: (ad){
      ad.dispose();
    },
        onAdClosed: (ad){
          print("add closed");
        }
    );
    BannerAd bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-3940256099942544/6300978111",
        listener: BannerAdListener(),
        request: AdRequest());

    bannerAd.load();

    return SizedBox(
      height: 100,
      child: AdWidget(ad: bannerAd,),
    );
  }
}

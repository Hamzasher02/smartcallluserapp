import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Widgets/custom_grid_view.dart';

import '../chat/chat_screen.dart';
import '../../Widgets/country_to_flag.dart';
import '../../db/entity/app_user.dart';
import '../../db/entity/chat.dart';
import '../../db/entity/fvrt.dart';
import '../../db/entity/message.dart';
import '../../db/entity/sentmessage.dart';
import '../../db/entity/utils.dart';
import '../../db/remote/firebase_database_source.dart';

class FavouritesPage extends StatefulWidget {
  final AppUser myuser;

  const FavouritesPage({super.key, required this.myuser});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  @override
  void initState() {
    //fvtData();
    super.initState();
  }

  AppUser? _user;
  String myid = '';
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  List<AppUser> fvtList = [];
  bool check = false;
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

  removeF(String myId, String otherId, String added, index) {
    _databaseSource.removeFavourites(myId, AddFavourites(otherId, added));
    setState(() {
      fvtList.removeAt(index);
    });
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

  showUserView(BuildContext context, String id, img, name, like, country, date,
      age, gender, view, myid, myuser, otherId, index, temp1) {
    int views;
    views = view++;
    bool fvtVisible = true;
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
                          children: [
                            /// name and fvrt
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            removeF(myid, otherId, "", index);
                                            int likes;
                                            likes = like - 1;
                                            setState(() {
                                              fvtVisible = !fvtVisible;
                                            });
                                            _databaseSource.addFav(id, likes);
                                            _databaseSource.addFav2(id, "");
                                            // if (_isAdLoaded) {
                                            //   _interstitialAd!.show();
                                            //   Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                            //     MaterialPageRoute(builder: (context) => const MainPage(tab: 0)),
                                            //         (route) => false,
                                            //   );
                                            // }
                                            Navigator.pop(context);
                                          },
                                          child: Icon(
                                            fvtVisible
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: fvtVisible
                                                ? Colors.red
                                                : Colors.white,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$age",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$gender",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(),
                                  ),
                                ],
                              ),
                            ),

                            /// buttons
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
                                      epochTimeMs: DateTime.now().millisecondsSinceEpoch,
                                      seen: false,
                                      senderId: myid,
                                      text: "Say Hello 👋",
                                      type: "text",
                                    );
                                      _databaseSource
                                          .addChat(Chat(chatId, message));
                                      chatBuddySent(myid, id, "Buddy Sent");
                                      //messagerequestreceived(userid, myid, "received");
                                      chatBuddyReceived(
                                          id, myid, "Buddy recived");
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                            chatId:
                                                compareAndCombineIds(myid, id),
                                            myUserId: myid,
                                            otherUserId: id,
                                            user: myuser,
                                            otherUserName: name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent
                                          .withOpacity(0.7),
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
                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) => VideoCallScreen(
                                      //       remoteUid: int.tryParse(id),
                                      //       username: name,
                                      //     ),
                                      //   ),
                                      // );
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => DummyZego(
                                      //               userId: id,
                                      //               userName: name,
                                      //             )));
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.lightBlueAccent
                                          .withOpacity(0.7),
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

  int count = 0;

  Future fvtData() async {
    print("in function");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String temp = '';
    fvtList = [];
    myid = prefs.getString("myid")!;
    await db
        .collection("users")
        .doc(widget.myuser.id)
        .collection("favourites")
        .get()
        .then((event) async {
      for (var doc in event.docs) {
        temp = doc.data()['id'];
        if (temp != '') {
          try {
            await db.collection("users").doc(temp).get().then((event) async {
              fvtList.add(AppUser(
                id: event.data()!['id'],
                name: event.data()!['name'],
                gender: event.data()!['gender'],
                age: event.data()!['age'],
                country: event.data()!['country'],
                profilePhotoPath: event.data()!['profile_photo_path'],
                token: event.data()!['token'],
                temp1: event.data()!['temp1'],
                temp2: event.data()!['temp2'],
                temp3: event.data()!['temp3'],
                temp4: event.data()!['temp4'],
                temp5: event.data()!['temp5'],
                status: event.data()!['status'],
                likes: event.data()!['likes'],
                type: event.data()!['type'],
                views: event.data()!['views'],
              ));
            });
          } catch (e) {
            print(e.toString());
          }
        }
        count + 1;
        print(count);
        if (count == event.docs.length) {
          break;
        }
      }
    });
    // if(fvtList.isEmpty){
    //   check=true;
    // }else{
    //   check=true;
    // }
    final ids = fvtList.map((e) => e.id).toSet();
    fvtList.retainWhere((x) => ids.remove(x.id));
    print(fvtList.length);
    return fvtList;
  }

  Future _refresh() async {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fvtData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }
        return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,

          body: fvtList.isEmpty
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
                        'No Favourites Found',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    children: List.generate(
                      
                      fvtList.length,
                      (reversedIndex) {
                        final index = fvtList.length - reversedIndex - 1;
                      
                          final int itemIndex = index - (index ~/ 4);
                          return GestureDetector(
                            onTap: () {
                              // initAd();
                              showUserView(
                                context,
                                fvtList[itemIndex].id,
                                fvtList[itemIndex].profilePhotoPath,
                                fvtList[itemIndex].name,
                                fvtList[itemIndex].likes,
                                fvtList[itemIndex].country,
                                dateFormat.format(DateTime.now()),
                                fvtList[itemIndex].age,
                                fvtList[itemIndex].gender,
                                fvtList[itemIndex].views,
                                myid,
                                widget.myuser,
                                fvtList[itemIndex].id,
                                itemIndex,
                                fvtList[itemIndex].temp1,
                              );
                            },
                            child: CustomGridView(
                              id: fvtList[itemIndex].id,
                              name: fvtList[itemIndex].name,
                              age: fvtList[itemIndex].age,
                              gender: fvtList[itemIndex].gender,
                              country: fvtList[itemIndex].country,
                              profileImage: fvtList[itemIndex].profilePhotoPath,
                            ),
                          );
                        
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget getAd() {
    BannerAdListener bannerAdListener =
        BannerAdListener(onAdWillDismissScreen: (ad) {
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
      height: MediaQuery.of(context).size.height,
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
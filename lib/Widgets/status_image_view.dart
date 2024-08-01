import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/db/entity/story.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import '../Screens/chat/chat_screen.dart';
import '../Util/constants.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';

class StatusScrollImage extends StatefulWidget {
  String path;
  List img;
  String userId;
  AppUser myuser;

  StatusScrollImage({
    super.key,
    required this.path,
    required this.img,
    required this.userId,
    required this.myuser,
  });

  @override
  State<StatusScrollImage> createState() => _StatusScrollImageState();
}

class _StatusScrollImageState extends State<StatusScrollImage> {
  //AppUser? otherUser;
  String myid = '';
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  Controller controller = Controller();
  PageController _pageController = PageController();

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AppUrls.bannerAdID,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Ad loaded successfully');
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          _isAdLoaded = false;
        },
      ),
      request: AdRequest(),
    )..load();
  }

  getId() async {
    myid = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myid = prefs.getString("myid")!;
  }

  // getUser(userId) async {
  //   await db.collection("users").doc(userId).get().then((snapshot) async {
  //     otherUser = AppUser(
  //       id: snapshot.data()!['id'],
  //       name: snapshot.data()!['name'],
  //       gender: snapshot.data()!['gender'],
  //       country: snapshot.data()!['country'],
  //       age: snapshot.data()!['age'],
  //       profilePhotoPath: snapshot.data()!['profile_photo_path'],
  //       temp1: snapshot.data()!['temp1'],
  //       temp2: snapshot.data()!['temp2'],
  //       temp3: snapshot.data()!['temp3'],
  //       temp4: snapshot.data()!['temp4'],
  //       temp5: snapshot.data()!['temp5'],
  //       token: snapshot.data()!['token'],
  //       status: snapshot.data()!['status'],
  //       likes: snapshot.data()!['likes'],
  //       type: snapshot.data()!['type'],
  //       views: snapshot.data()!['views'],
  //     );
  //   });
  //   return otherUser;
  // }

  // Future<void> fetchUserByIndex(int index) async {
  //   String targetUserId;
  //   if (index == 0) {
  //     targetUserId = widget.userId; // Use the initial user ID
  //   } else {
  //     targetUserId = widget.img[index].userId; // Use the next user ID after the initial one
  //   }
  //   await getUser(targetUserId);
  // }

  void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success, {int? currentIndex}) {
    print("Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");
  }

  @override
  void initState() {
    super.initState();
    getId();
    _initBannerAd();
    controller = Controller()
      ..addListener((event) {
        _handleCallbackEvent(event.direction, event.success);
      })
    ..addListener((event) {

    })
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(
          ad: _bannerAd!,
        ),
      ),
      body: TikTokStyleFullPageScroller(
          contentSize: widget.img.length,
          // controller: _pageController,
          // scrollDirection: Axis.vertical,
          controller: controller,
          swipePositionThreshold: 0.2,
          swipeVelocityThreshold: 2000,
          animationDuration: const Duration(milliseconds: 400),
          builder: (context, index) {
            //getUser(index == 0 ? widget.userId : widget.img[index].userId);
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: StreamBuilder<DocumentSnapshot>(
                  stream: db.collection("users").doc(index == 0 ? widget.userId : widget.img[index].userId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ); // Or any loading indicator
                    } else if (snapshot.hasError) {
                      return Container();
                    } else {
                      AppUser otherUser = AppUser.fromSnapshot(snapshot.data!);
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(index == 0 ? widget.path : widget.img[index].imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: getHeight(context) * 0.8,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 30,
                                      backgroundImage: NetworkImage(otherUser.profilePhotoPath),
                                    ),
                                    Text(
                                      "\t\t\t${otherUser.name}\t\t",
                                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      //
                                    },
                                    child: const Align(
                                      alignment: Alignment.centerRight,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 30,
                                        child: Icon(
                                          Icons.favorite,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      String chatId = compareAndCombineIds(
                                        myid,
                                        otherUser.id,
                                      );
                                      Message message = Message(DateTime.now().millisecondsSinceEpoch, false, myid, "Say Hello 👋", "text");
                                      _databaseSource.addChat(
                                        Chat(chatId, message),
                                      );
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                            chatId: compareAndCombineIds(myid, otherUser.id),
                                            myUserId: myid,
                                            otherUserId: otherUser.id,
                                            user: widget.myuser,
                                            otherUserName: otherUser.name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                                        radius: 30,
                                        child: const Icon(
                                          Icons.chat,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Align(
                                  //   alignment: Alignment.centerRight,
                                  //   child: ZegoSendCallInvitationButton(
                                  //     buttonSize: const Size(
                                  //       60,
                                  //       80,
                                  //     ),
                                  //     isVideoCall: true,
                                  //     resourceID: "hafeez_khan",
                                  //     //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                                  //     invitees: [
                                  //       ZegoUIKitUser(
                                  //         id: userId,
                                  //         name: "User",
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  }),
            );
          }),
    );
  }
}

AppUser? otherUser;
String myid = '';
FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
final PageController controller = PageController();
BannerAd? _bannerAd;
bool _isAdLoaded = false;

_initBannerAd() {
  _bannerAd = BannerAd(
    size: AdSize.banner,
    adUnitId: AppUrls.bannerAdID,
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        print('Ad loaded successfully');
        _isAdLoaded = true;
      },
      onAdFailedToLoad: (ad, error) {
        print('Ad failed to load: $error');
        _isAdLoaded = false;
      },
    ),
    request: AdRequest(),
  )..load();
}

getUser(userId) async {
  await db.collection("users").doc(userId).get().then((event) async {
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
}

showStatusImage(BuildContext context, {required String path, required List img, required String userId, required AppUser myuser}) async {
  // AppUser? otherUser;
  String myid = '';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  myid = prefs.getString("myid")!;
  print(myid);
  // await db.collection("users").doc(userId).get().then((event) async {
  //   otherUser = AppUser(
  //     id: event.data()!['id'],
  //     name: event.data()!['name'],
  //     gender: event.data()!['gender'],
  //     country: event.data()!['country'],
  //     age: event.data()!['age'],
  //     profilePhotoPath: event.data()!['profile_photo_path'],
  //     temp1: event.data()!['temp1'],
  //     temp2: event.data()!['temp2'],
  //     temp3: event.data()!['temp3'],
  //     temp4: event.data()!['temp4'],
  //     temp5: event.data()!['temp5'],
  //     token: event.data()!['token'],
  //     status: event.data()!['status'],
  //     likes: event.data()!['likes'],
  //     type: event.data()!['type'],
  //     views: event.data()!['views'],
  //   );
  // });

  Future<void> fetchUserByIndex(int index) async {
    String targetUserId;
    if (index == 0) {
      targetUserId = userId; // Use the initial user ID
    } else {
      targetUserId = img[index].userId; // Use the next user ID after the initial one
    }
    await getUser(targetUserId);
  }

  //dataFireBase(userId);
  fetchUserByIndex(0);
  return showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        _initBannerAd();
        return Scaffold(
          bottomNavigationBar: SizedBox(
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(
              ad: _bannerAd!,
            ),
          ),
          body: PageView.builder(
              padEnds: false,
              scrollDirection: Axis.vertical,
              controller: controller,
              itemCount: img.length,
              itemBuilder: (context, index) {
                //print("initial page: ${controller.initialPage}");
                fetchUserByIndex(index);
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(index == 0 ? path : img[index].imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: getHeight(context) * 0.8,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 30,
                                  backgroundImage: NetworkImage(otherUser!.profilePhotoPath),
                                ),
                                Text(
                                  "\t\t\t${otherUser!.name}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  //
                                },
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 30,
                                    child: Icon(
                                      Icons.favorite,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  String chatId = compareAndCombineIds(
                                    myid,
                                    otherUser!.id,
                                  );
                                  Message message = Message(DateTime.now().millisecondsSinceEpoch, false, myid, "Say Hello 👋", "text");
                                  _databaseSource.addChat(
                                    Chat(chatId, message),
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MessageScreen(
                                        chatId: compareAndCombineIds(myid, otherUser!.id),
                                        myUserId: myid,
                                        otherUserId: otherUser!.id,
                                        user: myuser,
                                        otherUserName: otherUser!.name,
                                      ),
                                    ),
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                                    radius: 30,
                                    child: const Icon(
                                      Icons.chat,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Align(
                              //   alignment: Alignment.centerRight,
                              //   child: ZegoSendCallInvitationButton(
                              //     buttonSize: const Size(
                              //       60,
                              //       80,
                              //     ),
                              //     isVideoCall: true,
                              //     resourceID: "hafeez_khan",
                              //     //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
                              //     invitees: [
                              //       ZegoUIKitUser(
                              //         id: userId,
                              //         name: "User",
                              //       )
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        );
      });
}

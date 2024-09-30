import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';
import 'package:smart_call_app/db/entity/story.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import '../Screens/chat/chat_screen.dart';
import '../db/Models/native_ad_model.dart';
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
  String userName;
  String currentUserId;
  String userImage;
  String statusId;
  List<Story> story;

  StatusScrollImage({
    super.key,
    required this.path,
    required this.img,
    required this.userName,
    required this.userId,
    required this.userImage,
    required this.story,
    required this.currentUserId,
    required this.statusId,
    required this.myuser,
  });

  @override
  State<StatusScrollImage> createState() => _StatusScrollImageState();
}

class _StatusScrollImageState extends State<StatusScrollImage> {
  int _currentIndex = 0; // Track the current index

  List<dynamic> combinedContent = [];
  void handleLikeOrDislike(Story story, String currentUserId) async {
    DocumentReference storyRef =
        FirebaseFirestore.instance.collection('stories').doc(story.id);

    if (story.likes.contains(currentUserId)) {
      // Dislike
      storyRef.update({
        'likes': FieldValue.arrayRemove([currentUserId])
      });
      if (kDebugMode) {
        print("like removed successfully by ${widget.currentUserId}");
      }
    } else {
      // Like
      storyRef.update({
        'likes': FieldValue.arrayUnion([currentUserId])
      });
      if (kDebugMode) {
        print("like added successfully by ${widget.currentUserId}");
      }
    }
  }

  Widget getAd() {
    BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
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
      height: MediaQuery.of(context).size.height * 0.135,
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

  // late ZegoUIKitPrebuiltCallInvitationService _callInvitationService;
  NativeAdModel nativeAdModel = Get.put(NativeAdModel());

  // void initZego() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? storedUserId = prefs.getString('userId');
  //   String? storedUserName = prefs.getString('userName');

  //   if (kDebugMode) {
  //     print("Id of the current user is $storedUserId");
  //     print("Name of the current user is $storedUserName");
  //   }

  //   // Ensure userID and userName are not null before passing them to Zego
  //   await ZegoUIKitPrebuiltCallInvitationService().init(
  //     appID: Utils.appId,
  //     appSign: Utils.appSignin,
  //     userID: storedUserId ?? "defaultUserId",
  //     userName: storedUserName ?? "defaultUserName",
  //     notifyWhenAppRunningInBackgroundOrQuit: true,
  //     androidNotificationConfig: ZegoAndroidNotificationConfig(
  //       channelID: "ZegoUIKit",
  //       channelName: "Call Notifications",
  //       sound: "notification",
  //       icon: "notification_icon",
  //     ),
  //     iOSNotificationConfig: ZegoIOSNotificationConfig(
  //       isSandboxEnvironment: false,
  //       systemCallingIconName: 'CallKitIcon',
  //     ),
  //     plugins: [ZegoUIKitSignalingPlugin()],
  //     requireConfig: (ZegoCallInvitationData data) {
  //       final config = (data.invitees.length > 1)
  //           ? ZegoCallType.videoCall == data.type
  //               ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
  //               : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
  //           : ZegoCallType.videoCall == data.type
  //               ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  //               : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

  //       config.topMenuBarConfig.isVisible = true;
  //       config.topMenuBarConfig.buttons
  //           .insert(0, ZegoMenuBarButtonName.minimizingButton);

  //       return config;
  //     },
  //   );
  // }

  // void _uninitializeCallInvitationService() {
  //   _callInvitationService.uninit();
  // }

  AppUser? otherUser;
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

  int _scrollCount = 0;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded1 = false;

  getId() async {
    myid = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myid = prefs.getString("myid")!;
  }

  @override
  void initState() {
    super.initState();
    combinedContent = List.from(widget.img);
    _loadNativeAd();
    Controller()
      ..addListener((event) {
        _handleScrollEvent(event.success);
      });
  }

  void _loadNativeAd() {
    nativeAdModel.loadAd();
    nativeAdModel.isAdLoaded.listen((isLoaded) {
      if (isLoaded) {
        print("Native ad loaded successfully.");
      } else {
        print("Native ad failed to load.");
      }
    });
  }

  Widget _buildAdWidget() {
    return Obx(() {
      if (nativeAdModel.isAdLoaded.value) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: AdWidget(ad: nativeAdModel.nativeAd!),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      }
    });
  }

  void _handleScrollEvent(ScrollSuccess success) {
    if (success == ScrollSuccess.SUCCESS) {
      _currentIndex++;
      _scrollCount++;

      if (_scrollCount >= 3 && _currentIndex < combinedContent.length) {
        _scrollCount = 0;

        if (nativeAdModel.isAdLoaded.value) {
          setState(() {
            if (combinedContent[_currentIndex] != 'ad') {
              combinedContent.insert(_currentIndex, 'ad');
              print("Inserting ad at index $_currentIndex");
            }
          });
        } else {
          print("Ad not loaded, skipping insertion at index $_currentIndex.");
        }
      }
    }
  }

  void initAd() {
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

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      loadInterstitialAd(); // Load a new ad for the next time.
    }
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded1 = true;
  }

  @override
  void dispose() {
    super.dispose();
    // _uninitializeCallInvitationService();
    _interstitialAd!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(
                ad: _bannerAd!,
              ),
            )
          : null,
      body: TikTokStyleFullPageScroller(
        contentSize: combinedContent.length,
        controller: Controller()
          ..addListener((event) {
            _handleScrollEvent(event.success);
          }),
        swipePositionThreshold: 0.2,
        swipeVelocityThreshold: 2000,
        animationDuration: const Duration(milliseconds: 400),
        builder: (context, index) {
          if (combinedContent[index] == 'ad') {
            return _buildAdWidget();
          } else {
            Story story = combinedContent[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(story.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                height: MediaQuery.of(context).size.height,
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
                              backgroundImage: NetworkImage(widget.userImage),
                            ),
                            Text(
                              "\t\t\t${widget.userName}\t\t",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DummyWaitingCallScreen(
                                            story: widget.story,
                                            storyId: widget.statusId,
                                            currentUserId: widget.currentUserId,
                                            path: widget.path,
                                            img: widget.img,
                                            userName1: widget.userName,
                                            userId: widget.userId,
                                            myUser: widget.myuser,
                                            userImage:
                                                widget.myuser.profilePhotoPath,
                                            userName: widget.userName,
                                          )));
                            },
                            child: const Align(
                              alignment: Alignment.centerRight,
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              // handleLikeOrDislike(story, widget.currentUserId);
                            },
                            child: Container(
                              // No background color, just the icon
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 60, // Adjust the size as needed
                              ),
                            ),
                          ),

                          // SizedBox(height: 5),
                          // Text(
                          //   '${story.likes.length} Likes',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 16,
                          //   ),
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              String chatId = compareAndCombineIds(
                                widget.currentUserId,
                                widget.userId,
                              );
                              Message1 message = Message1(
                                epochTimeMs:
                                    DateTime.now().millisecondsSinceEpoch,
                                seen: false,
                                senderId: myid,
                                text: "Say Hello 👋",
                                type: "text",
                              );
                              _databaseSource.addChat(Chat(chatId, message));
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    chatId: chatId,
                                    myUserId: widget.currentUserId,
                                    otherUserId: widget.userId,
                                    user: widget.myuser,
                                    otherUserName: widget.userName,
                                  ),
                                ),
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 30,
                                child: const Icon(
                                  Icons.chat,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
          }
        },
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Util/video_call_utils.dart';
import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';
import 'package:smart_call_app/Widgets/dummy_widget.dart';
import 'package:smart_call_app/db/entity/story.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import '../Screens/chat/chat_screen.dart';
import '../db/entity/app_user.dart';
import '../db/entity/chat.dart';
import '../db/entity/message.dart';
import '../db/entity/utils.dart';
import '../db/remote/firebase_database_source.dart';

// ignore: must_be_immutable

// ignore: must_be_immutable
class StatusScrollImage extends StatefulWidget {
  String path;
  List img;
  String userId;
  AppUser myuser;
  String userName;
  String currentUserId;
  String statusId;
  List<Story> story;

  StatusScrollImage({
    super.key,
    required this.path,
    required this.img,
    required this.userName,
    required this.userId,
    required this.story,
    required this.currentUserId,
    required this.statusId,
    required this.myuser,
  });

  @override
  State<StatusScrollImage> createState() => _StatusScrollImageState();
}

class _StatusScrollImageState extends State<StatusScrollImage> {
    int _currentIndex = 0;  // Track the current index

  List<dynamic> combinedContent=[];
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

  late ZegoUIKitPrebuiltCallInvitationService _callInvitationService;

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

        return config;
      },
    );
  }

  void _uninitializeCallInvitationService() {
    _callInvitationService.uninit();
  }

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
    getId();
    initZego();
    combinedContent = List.from(widget.img); // Initialize combined content
    controller = Controller()
      ..addListener((event) {
        _handleCallbackEvent(event.success);
      });

    if (kDebugMode) {
      print("My Id is ${widget.currentUserId}");
      print("Other user id is ${widget.userId}");
      print("Other user name is ${widget.userName}");
    }
  }

void _handleCallbackEvent(ScrollSuccess success) {
  if (success == ScrollSuccess.SUCCESS) {
    _currentIndex++; // Increment the index on a successful scroll
    _scrollCount++;

    // Check if an ad can be inserted after every 2 successful scrolls
    if (_scrollCount >= 2 && _currentIndex < combinedContent.length) {
      _scrollCount = 0; // Reset the count

      setState(() {
        // Ensure that ads do not get inserted multiple times in the same spot
        if (_currentIndex > 0 && combinedContent[_currentIndex - 1] != 'ad') {
          combinedContent.insert(_currentIndex, 'ad');
        }
      });
    }
  } else if (success == ScrollSuccess.FAILED_END_OF_LIST) {
    _currentIndex = combinedContent.length - 1; // Ensure index is within bounds
  } else if (success == ScrollSuccess.FAILED_THRESHOLD_NOT_REACHED) {
    if (_currentIndex > 0) {
      _currentIndex--; // Decrement index if threshold not reached
    }
  }

  print("Scroll callback received with success: $success and index: $_currentIndex");
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
    _uninitializeCallInvitationService();
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
          contentSize: widget.img.length,
          // controller: _pageController,
          // scrollDirection: Axis.vertical,
          controller: controller,
          swipePositionThreshold: 0.2,
          swipeVelocityThreshold: 2000,
          animationDuration: const Duration(milliseconds: 400),
          builder: (context, index) {
            //getUser(index == 0 ? widget.userId : widget.img[index].userId);
          if (combinedContent[index] == 'ad') {
            // Display your native ad widget in full screen
            return MyDummyNativeAd();
          }
            else{
              return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('stories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading data'));
                  } else if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_outlined),
                          SizedBox(height: 10),
                          Text(
                            'No Status Found',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    );
                  } else {
                    List<Story> stories = snapshot.data!.docs.map((doc) {
                      return Story.fromSnapshot(doc);
                    }).toList();

                    return TikTokStyleFullPageScroller(
                        contentSize: stories.length,
                        controller: controller,
                        swipePositionThreshold: 0.2,
                        swipeVelocityThreshold: 2000,
                        animationDuration: const Duration(milliseconds: 400),
                        builder: (context, index) {
                          Story story = stories[index];
                          bool isLikedByCurrentUser =
                              story.likes.contains(widget.currentUserId);

                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        story.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 0, 20, 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.red,
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                  widget
                                                      .myuser.profilePhotoPath),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DummyWaitingCallScreen(
                                                              story:
                                                                  widget.story,
                                                              storyId: widget
                                                                  .statusId,
                                                              currentUserId: widget
                                                                  .currentUserId,
                                                              path: widget.path,
                                                              img: widget.img,
                                                              userName1: widget
                                                                  .userName,
                                                              userId:
                                                                  widget.userId,
                                                              myUser:
                                                                  widget.myuser,
                                                              userImage: widget
                                                                  .myuser
                                                                  .profilePhotoPath,
                                                              userName: widget
                                                                  .userName)));
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
                                              handleLikeOrDislike(
                                                  story, widget.currentUserId);
                                            },
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: CircleAvatar(
                                                radius: 30,
                                                child: Icon(
                                                  isLikedByCurrentUser
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '${story.likes.length} Likes',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              String chatId =
                                                  compareAndCombineIds(
                                                widget.currentUserId,
                                                widget.userId,
                                              );
                                              if (kDebugMode) {
                                                print(
                                                    "Recipent Id: ${widget.userId}");
                                                print(
                                                    "Recipent name: ${widget.userName}");
                                                print(
                                                    "sender Id: ${widget.myuser.id}");
                                                print("Chat Id: ${chatId}");
                                              }
                                              Message message = Message(
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                  false,
                                                  widget.currentUserId,
                                                  "Say Hello 👋",
                                                  "text");
                                              _databaseSource.addChat(
                                                Chat(chatId, message),
                                              );
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      MessageScreen(
                                                    chatId:
                                                        compareAndCombineIds(
                                                            widget
                                                                .currentUserId,
                                                            widget.userId),
                                                    myUserId:
                                                        widget.currentUserId,
                                                    otherUserId: widget.userId,
                                                    user: widget.myuser,
                                                    otherUserName:
                                                        widget.userName,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: CircleAvatar(
                                                backgroundColor: Colors
                                                    .lightBlueAccent
                                                    .withOpacity(0.7),
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
                              ));
                        });
                  }
                },
              ),
            );
            }
          }),
    );
  }
}

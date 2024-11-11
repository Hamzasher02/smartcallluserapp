import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_call_app/Screens/call/agora/video_call_screen_1.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Util/video_call_fcm.dart';
import 'package:smart_call_app/Widgets/dummy_waiting_call_screen.dart';
import 'package:smart_call_app/db/entity/utils.dart';
import 'package:smart_call_app/db/remote/firebase_database_source.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'country_to_flag.dart';

class CustomCardTile extends StatefulWidget {
  final String id;
  final String recieverDeviceToken;
  final String name;
  final String type;
  final String age;
  final String gender;
  final String country;
  final String profileImage;
  final String currentUserId;
  final String currentUserName;
  final String myId;
  final String myStatus;
  final String status;
  final VoidCallback? onTapImage;

  CustomCardTile({
    required this.id,
    required this.name,
    required this.type,
    required this.age,
    required this.gender,
    required this.currentUserId,
    required this.currentUserName,
    required this.country,
    required this.recieverDeviceToken,
    required this.myId,
    required this.profileImage,
    required this.myStatus,
    required this.status,
    this.onTapImage,
  });

  @override
  State<CustomCardTile> createState() => _CustomCardTileState();
}

class _CustomCardTileState extends State<CustomCardTile> {
  FirebaseDatabaseSource _firebaseDatabaseSource = FirebaseDatabaseSource();
  Random random = Random();

  void _startCall(String callType, String chatId) {
    if (kDebugMode) {
      print(
          "Custom Card Tile The id of the current user is ${widget.currentUserId}");
      print("Custom Card Tile The id of the other user is ${widget.id}");
      print("Custom Card Tile The chat id is $chatId");
      print("Custom Card Tile The call type is $callType");
    }
    _firebaseDatabaseSource.storeCallInfo(
      chatId: chatId,
      myUserId: widget.currentUserId,
      otherUserId: widget.id,
      callType: callType,
      callStatus: "Started",
      isIncoming: false,
    );
  }

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded1 = false;
  int retryCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAd(); // Initialize the ad as soon as the widget is created
    // initZego(); // Initialize Zego after ad initialization
  }

  void _initializeAd() {
    print("Initializing interstitial ad...");
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('InterstitialAd loaded successfully');
          _interstitialAd = ad;
          _isAdLoaded1 = true;
          retryCount = 0; // Reset retry count on success
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _isAdLoaded1 = false;
          if (retryCount < 3) {
            // Retry up to 3 times
            retryCount++;
            Future.delayed(Duration(seconds: 2), () {
              _initializeAd();
            });
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset:const  Offset(0, 4),
                    ),
                  ],
                ),
        height: MediaQuery.of(context).size.height * 0.135,
        // decoration: BoxDecoration(
        //   color: Theme.of(context).colorScheme.outline,
        //   borderRadius: const BorderRadius.all(
        //     Radius.circular(10),
        //   ),
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor:
                          _getDotColor(widget.status, widget.myStatus),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.onTapImage != null) {
                        widget.onTapImage!();
                      }
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: ClipOval(
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: widget.profileImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                widget.name.trim(),
                textAlign: TextAlign.start,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        countryCodeToEmoji(widget.country),
                        style: const TextStyle(fontSize: 20),
                      ),
                      Expanded(
                        flex: 1,
                        child: widget.type == "live"
                            ? GestureDetector(
                                onTap: () {
                                  String chatId = compareAndCombineIds(
                                      widget.currentUserId, widget.id);
                                  // if (widget.status == "offline") {
                                  //   Get.snackbar(
                                  //     backgroundColor: const Color(0xff607d8b),
                                  //     "Call Invitation",
                                  //     "${widget.name} is offline. Please try later",
                                  //     snackPosition: SnackPosition.TOP,
                                  //   );
                                  // }
                                 
                                    if (widget.name.isNotEmpty) {
                                      _startCall("video", chatId);
                                      VideoCallFcm.sendCallNotification(
                                          widget.currentUserName,
                                          widget.recieverDeviceToken,
                                          "smart_call_app",
                                          "007eJxTYNBd3bHmm6XbfSGBhUHZpyPtM5/bbF2uPl94lZZQ/6HElVwKDIYWySapyUYWKSZGKSYpSSmJloamloZGJhbmFqlmyUlJ0ziN0hsCGRnefdvJwAiFID4fQ3FuYlFJfHJiTk58YkEBAwMASV4i1A==",
                                          widget.name);
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoCallScreen1(
                                          recieverName: widget.name,
                                          agoraAppId:
                                              "18c4ec28d42d4dbda9159124878e6cbb",
                                          agoraAppToken:
                                              "007eJxTYNBd3bHmm6XbfSGBhUHZpyPtM5/bbF2uPl94lZZQ/6HElVwKDIYWySapyUYWKSZGKSYpSSmJloamloZGJhbmFqlmyUlJ0ziN0hsCGRnefdvJwAiFID4fQ3FuYlFJfHJiTk58YkEBAwMASV4i1A==", // Use dynamic channel name
                                          agoraAppCertificate:
                                              "064b1a009cc248afa93a01234876a4c9", // Use your dynamic token
                                          agoraAppChannelName: "smart_call_app",
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
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DummyWaitingCallScreen(
                                                  userImage:
                                                      widget.profileImage,
                                                  userName: widget.name)));
                                },
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors
                                        .green, // Ensure the container color is set correctly
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.videocam,
                                      size:
                                          25, // Adjust the size to fit well within the container
                                      color: Colors
                                          .white, // Ensure the icon color is white
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return Container(
      width: 30.0, // Set a fixed width
      height: 30.0, // Set a fixed height
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      child: Icon(
        Icons.videocam_sharp,

        color: Colors.white,
        size: 30.0, // Set the same icon size for both cases
      ),
    );
  }

  Color _getDotColor(String status, String myStatus) {
    if (status == "online" && myStatus == "online") {
      return Colors.green;
    } else if (status == "offline" && myStatus == "offline") {
      return Colors.red;
    } else if (status == "online" && myStatus == "offline") {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }
}

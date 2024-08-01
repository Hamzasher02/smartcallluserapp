import 'dart:convert';

// import 'package:agora_uikit/agora_uikit.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
//
// const String appID = "db09c052819348a182c416918b269d7a";
// const String channelName = "test";
//
// class VideoCallScreen extends StatefulWidget {
//   final int? remoteUid;
//   final String? username;
//
//   const VideoCallScreen({
//     super.key,
//     this.remoteUid,
//     this.username,
//   });
//
//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }
//
// class _VideoCallScreenState extends State<VideoCallScreen> {
//   AgoraClient? client;
//   bool isLoading = false;
//
//   //String baseURL = "https://smart-call-app-1b9a636765fd.herokuapp.com/rtc/test/publisher/userAccount/0/";
//
//   Future initAgora() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       String baseURL = "https://smart-call-app-1b9a636765fd.herokuapp.com/rtc/$channelName/publisher/userAccount/${widget.remoteUid}/";
//       Response _response = await get(Uri.parse(baseURL));
//       Map data = jsonDecode(_response.body);
//       String token = data["rtcToken"];
//       print("token: $token");
//       client = AgoraClient(
//         agoraConnectionData: AgoraConnectionData(
//           appId: appID,
//           channelName: channelName,
//           tokenUrl: baseURL,
//           username: widget.username!,
//           uid: widget.remoteUid,
//         ),
//         enabledPermission: [
//           Permission.camera,
//           Permission.microphone,
//         ],
//       );
//       setState(() {
//         isLoading = false;
//       });
//       await client!.initialize();
//     } catch (e) {
//       print("Error : $e");
//     }
//   }
//
//   @override
//   void initState() {
//     initAgora();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: isLoading == true
//             ? Container(
//                 color: Colors.black,
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               )
//             : Stack(
//                 children: [
//                   AgoraVideoViewer(
//                     client: client!,
//                     layoutType: Layout.floating,
//                     enableHostControls: true, // Add this to enable host controls
//                   ),
//                   AgoraVideoButtons(
//                     client: client!,
//                     addScreenSharing: false, // Add this to enable screen sharing
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as h;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_call_app/Screens/authentication/controller/response.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';
import 'package:smart_call_app/Util/app_url.dart';

const appId = "db09c052819348a182c416918b269d7a";
const channel = "test";

class VideoCallScreen extends StatefulWidget {
  int? remoteUid;
  String? username;

  VideoCallScreen({
    super.key,
    this.remoteUid,
    this.username,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _localUserJoined = false;
  RtcEngine? _engine;
  bool _isMuted = false;
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
    initAgora();
    initAd();
  }

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
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded = true;
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    String _token = "";
    try {
      String baseURL = "https://smart-call-app-1b9a636765fd.herokuapp.com/rtc/$channel/publisher/userAccount/0/";
      h.Response _response = await h.get(Uri.parse(baseURL));
      Map data = jsonDecode(_response.body);
      _token = data["rtcToken"];
      print("token: $_token");
    } catch (e) {
      print("Error: $e");
    }
    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            widget.remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            widget.remoteUid = null;
          });
          _dispose();
          Navigator.pop(context);
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableVideo();
    await _engine!.startPreview();

    await _engine!.joinChannel(
      token: _token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  // Functionality to end the call
  void _endCall() {
    _dispose();
    Navigator.pop(context);
    if (_isAdLoaded) {
      _interstitialAd!.show();
      // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const MainPage(tab: 0)),
      //       (route) => false,
      // );
    }
  }

  // Functionality to mute/unmute the microphone
  void _toggleMute() {
    _engine!.muteLocalAudioStream(!_isMuted);
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  // Functionality to switch camera
  void _switchCamera() {
    _engine!.switchCamera();
    setState(() {
      _isSwitched = !_isSwitched;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine!.leaveChannel();
    await _engine!.release();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine!,
                            useFlutterTexture: true,
                            canvas: const VideoCanvas(
                              uid: 0,
                            ),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _toggleMute,
                      icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                      color: _isMuted ? Colors.grey : Colors.white,
                    ),
                    GestureDetector(
                      onTap: _endCall,
                      child: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.5),
                        radius: 30,
                        child: const Icon(
                          Icons.call_end,
                          size: 30,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _switchCamera,
                      icon: const Icon(Icons.switch_camera),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (widget.remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: widget.remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Calling...',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
        ),
      );
    }
  }
}

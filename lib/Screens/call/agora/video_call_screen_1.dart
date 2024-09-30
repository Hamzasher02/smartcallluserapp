import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_call_app/Util/app_url.dart';

class VideoCallScreen1 extends StatefulWidget {
  final String agoraAppCertificate;
  final String agoraAppId;
  final String agoraAppToken;
  final String agoraAppChannelName;
  final String recieverName;

  VideoCallScreen1({
    super.key,
    required this.agoraAppCertificate,
    required this.agoraAppChannelName,
    required this.agoraAppId,
    required this.recieverName,
    required this.agoraAppToken,
  });

  @override
  State<VideoCallScreen1> createState() => _VideoCallScreen1State();
}

class _VideoCallScreen1State extends State<VideoCallScreen1> {
  bool _isMuted = false;
  bool _isSwitched = false;
  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  // State variables for mic and camera control
  bool _isCameraOff = false;

  // Token renewal mechanism
  String? _newToken;

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: widget.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          _renewToken(); // Renew the token when it's about to expire
        },
        onError: (ErrorCodeType error, String message) {
          debugPrint("Agora error: $message");
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.agoraAppToken,
      channelId: widget.agoraAppChannelName,
      options: const ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  void _endCall() {
    _engine.leaveChannel();
    _showInterstitialAd();
    Navigator.pop(context);
  }

  void _toggleMute() {
    _engine.muteLocalAudioStream(!_isMuted);
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _switchCamera() {
    _engine.switchCamera();
    setState(() {
      _isSwitched = !_isSwitched;
    });
  }

  Future<void> _renewToken() async {
    // Simulating token renewal process.
    // In a real implementation, you'll fetch a new token from your server.
    debugPrint("Token is about to expire. Renewing token...");
    setState(() {
      _newToken = "new_temp_token"; // Get this from your token generation server
    });

    if (_newToken != null) {
      await _engine.renewToken(_newToken!);
      debugPrint("Token renewed successfully.");
    }
  }

  void _initAd() {
    InterstitialAd.load(
      adUnitId: AppUrls.interstitialAdID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initAd();
    initAgora(); // Call Agora initialization here
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: _endCall,
              child: const Icon(Icons.call_end, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display remote video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.agoraAppChannelName),
        ),
      );
    } else {
      return  Text('Please wait for ${widget.recieverName} to join',
          textAlign: TextAlign.center);
    }
  }
}

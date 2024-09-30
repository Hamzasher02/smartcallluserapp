import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/db/entity/app_user.dart';
import 'package:smart_call_app/db/entity/story.dart';

class DummyWaitingCallScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final AppUser? myUser;
  final List<dynamic>? img;
  final String? path;
  final String? userName1;
  final String? currentUserId;
  final String? storyId;
  final List<Story>? story;
  final String? userId;

  const DummyWaitingCallScreen({
    Key? key,
    required this.userImage,
    required this.userName,
    this.img,
    this.myUser,
    this.path,
    this.currentUserId,
    this.storyId,
    this.story,
    this.userId,
    this.userName1,
  }) : super(key: key);

  @override
  State<DummyWaitingCallScreen> createState() => _DummyWaitingCallScreenState();
}

class _DummyWaitingCallScreenState extends State<DummyWaitingCallScreen> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded1 = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

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

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded1 = true;
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _cameraController = CameraController(frontCamera, ResolutionPreset.max);
      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Camera Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initAd();
    initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview in the background
          if (_isCameraInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),
          // Other UI elements
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(widget.userImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.userName,
                style: TextStyle(
                  fontSize: 20.0,
                  // color: Theme.of(context).colorScheme.primary,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Calling...',
                style: TextStyle(
                  fontSize: 16.0,
                  // color: Theme.of(context).colorScheme.primary,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (_isAdLoaded1) {
                  _interstitialAd!.show();
                  Navigator.pop(context);
                }
              },
              child: Center(
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

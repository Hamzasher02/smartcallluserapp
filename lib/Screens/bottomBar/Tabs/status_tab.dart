import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:smart_call_app/Util/app_url.dart';
import 'package:smart_call_app/Util/constants.dart';
import 'package:smart_call_app/Widgets/status_custom_grid_view.dart';
import 'package:smart_call_app/Widgets/status_image_view.dart';
import '../../../Widgets/status_bar_list_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../db/entity/app_user.dart';
import '../../../db/entity/story.dart';
import '../../../db/remote/firebase_database_source.dart';

class StatusScreen extends StatefulWidget {
  final AppUser myuser;

  const StatusScreen({super.key, required this.myuser});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  List<Story> storyData = [];
  List<Story> storyData1 = [];
  List<AppUser> usersData = [];
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = true; // Add this line

  @override
  void initState() {
    super.initState();
    cleanupOldStatuses();
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchUsersData();
    await fetchAndFilterStoriesData();
    await fetchStoryData();
    setState(() {
      _isLoading = false; // Set _isLoading to false when data is loaded
    });
  }

  Future<void> fetchUsersData() async {
    try {
      QuerySnapshot snapshot =
          await db.collection("users").where("type", isEqualTo: "fake").get();
      setState(() {
        usersData =
            snapshot.docs.map((doc) => AppUser.fromSnapshot(doc)).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> fetchAndFilterStoriesData() async {
    try {
      QuerySnapshot snapshot =
          await db.collection("stories").where("type", isEqualTo: "img").get();
      List<Story> allStories =
          snapshot.docs.map((doc) => Story.fromSnapshot(doc)).toList();

      final now = DateTime.now();
      allStories.removeWhere(
          (story) => story.timestamp.add(Duration(days: 7)).isBefore(now));

      setState(() {
        storyData = allStories.where((story) {
          return usersData.any((user) => user.id == story.userId);
        }).toList();
        storyData.shuffle();
        if (kDebugMode) {
          print("Statuses are $storyData");
          print(storyData.length);
        }
      });
    } catch (e) {
      print('Error fetching stories: $e');
    }
  }
    Future<void> cleanupOldStatuses() async {
    final DateTime now = DateTime.now();
    final DateTime cutoffDate = now.subtract(Duration(days: 7));

    try {
      QuerySnapshot snapshot = await db.collection('stories')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await db.collection('stories').doc(doc.id).delete();
      }

      print('Old statuses deleted successfully.');
    } catch (e) {
      print('Error cleaning up old statuses: $e');
    }
  }

  Future<void> fetchStoryData() async {
    try {
      QuerySnapshot snapshot = await db.collection("stories").get();
      List<Story> allStories =
          snapshot.docs.map((doc) => Story.fromSnapshot(doc)).toList();

      setState(() {
        storyData1 = allStories.toList();
      });
    } catch (e) {
      print('Error fetching stories: $e');
    }
  }

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
    _interstitialAd!.show();
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

  showStatus(BuildContext context, String image, String likes, String name,
      String country) {
    return showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
        ),
        height: getHeight(context) * 0.9,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 55,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(
                  likes,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              CircleAvatar(
                backgroundColor: Colors.lightBlueAccent.withOpacity(0.7),
                radius: 30,
                child: const Icon(
                  Icons.chat,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 30,
                child: Icon(
                  Icons.video_call,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$name $country',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 30,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true; // Set _isLoading to false when data is loaded
    });
    await fetchUsersData();
    await fetchAndFilterStoriesData();
    await fetchStoryData();
    setState(() {
      _isLoading = false; // Set _isLoading to false when data is loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,

        body: SafeArea(
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    ), // Show loading indicator
                  )
                : storyData.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_outlined),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'No Status Found',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        color: Theme.of(context).colorScheme.onPrimary,
                        onRefresh: _refresh,
                        child: SafeArea(
                            child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Text(
                                "Today's Feed",
                                style: TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                child: StatusBarListView(
                                  fakeUser: usersData,
                                  myuser: widget.myuser,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  left: 10,
                                  right: 10,
                                ),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // Two items per row
                                    crossAxisSpacing: 10.0,
                                    mainAxisSpacing: 10.0,
                                  ),
                                  itemCount: storyData.length, // Adjust item count
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    // Calculate the storyData index considering the ads

                                    // Check if the current position is where an ad should be displayed
                                    
                                      // Ensure that index is within the bounds of storyData
                                      if (index < storyData.length) {
                                        return GestureDetector(
                                          onTap: () {
                                            initAd();
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  StatusScrollImage(
                                                story: storyData,
                                                statusId:
                                                    storyData[index].id,
                                                currentUserId: widget.myuser.id,
                                                path: storyData[index]
                                                    .imageUrl,
                                                img: storyData,
                                                userId: storyData[index]
                                                    .userId,
                                                userName: storyData[index]
                                                    .userName,
                                                myuser: widget.myuser,
                                              ),
                                            ));
                                          },
                                          child: StatusCustomGridView(
                                            img: storyData[index].imageUrl,
                                            type: storyData[index].type,
                                          ),
                                        );
                                      } else {
                                        // Handle cases where index exceeds the bounds of storyData
                                        return const SizedBox(); // Return an empty widget or handle appropriately
                                      }
                                    
                                  },
                                ),
                              ),
                            ),
                          ],
                        )))));
  }

  int count = 0;
  int temp = 0;
}

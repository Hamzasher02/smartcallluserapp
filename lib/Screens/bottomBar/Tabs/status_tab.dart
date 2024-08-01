import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  List storyData = [];
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    stoData();
    getFakeUser();
    // TODO: implement initState
    super.initState();
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
    _interstitialAd!.show();
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitialAd = ad;
    _isAdLoaded = true;
  }

  showStatus(BuildContext context, String image, likes, name, country) {
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
                    name + " " + country,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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

  List result = [];
  bool tempcheck = false;

  getFakeUser() async {
    await db.collection("users").where("type", isEqualTo: "fake").get().then((event) async {
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
        result.shuffle();
        count++;
        if (count == event.docs.length) break;
      }
    });
    tempcheck = tempcheck;
    if (tempcheck == true) {
      Future.delayed(const Duration(seconds: 20), () {
        return result;
      });
    }
  }

  Future _refresh() async {
    storyData = [];
    print("in function");
    try {
      await db.collection("stories").get().then((event) async {
        print(event.docs.length);
        temp = event.docs.length;
        storyData = [];
        for (var doc in event.docs) {
          count = count + 1;
          print(count);
          print("count");
          storyData.add(Story(
            userId: doc.data()['userId'],
            imageUrl: doc.data()['imageUrl'],
            timestamp: doc.data()['timestamp'].toDate(),
            likes: doc.data()['likes'],
            type: doc.data()['type'],
          ));
          setState(() {
            storyData.shuffle();
          });
          if (count == temp) break;
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return storyData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFakeUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }
        return RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          color: Theme.of(context).colorScheme.onPrimary,
          onRefresh: _refresh,
          child: Scaffold(
            body: storyData.isEmpty
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
                          'No Status Found',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                              fakeUser: result,
                              myuser: widget.myuser,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              left: 10,
                              right: 10,
                            ),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                              ),
                              itemCount: storyData.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    initAd();
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => StatusScrollImage(
                                              path: storyData[index].imageUrl,
                                              img: imagesStories,
                                              userId: storyData[index].userId,
                                              myuser: widget.myuser,
                                            )));
                                  },
                                  child: StatusCustomGridView(
                                    img: storyData[index].imageUrl,
                                    type: storyData[index].type,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  int count = 0;
  int temp = 0;
  List imagesStories = [];

  Future stoData() async {
    storyData = [];
    imagesStories = [];
    print("in function");
    try {
      await db.collection("stories").get().then((event) async {
        print(event.docs.length);
        temp = event.docs.length;
        storyData = [];
        for (var doc in event.docs) {
          count = count + 1;
          print(count);
          print("count");
          storyData.add(Story(
            userId: doc.data()['userId'],
            imageUrl: doc.data()['imageUrl'],
            timestamp: doc.data()['timestamp'].toDate(),
            likes: doc.data()['likes'],
            type: doc.data()['type'],
          ));
          if (doc.data()['type'] == 'img') {
            imagesStories.add(Story(
              userId: doc.data()['userId'],
              imageUrl: doc.data()['imageUrl'],
              timestamp: doc.data()['timestamp'].toDate(),
              likes: doc.data()['likes'],
              type: doc.data()['type'],
            ));
          }
          if (count == temp) break;
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return storyData;
  }
}

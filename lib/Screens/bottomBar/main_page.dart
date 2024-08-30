import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/bottomBar/Tabs/chat_tab.dart';
import 'package:smart_call_app/Screens/bottomBar/Tabs/home_tab.dart';
import 'package:smart_call_app/Screens/bottomBar/Tabs/profile_tab.dart';
import 'package:smart_call_app/Screens/bottomBar/Tabs/status_tab.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smart_call_app/Util/app_url.dart';

import '../../db/entity/app_user.dart';

class MainPage extends StatefulWidget {
  final int tab;

  const MainPage({super.key, r, required this.tab});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  AppUser? myuser;
  String token1 = '007';
  String myid = '';
  List result = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool isLoading = false;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(initialIndex: widget.tab, length: 4, vsync: this);

    // Add listener to TabController
    _tabController.addListener(() {
      setState(() {}); // Rebuild the widget to reflect the highlighted tab
    });

    initCallServices();
    _initBannerAd();
    dataFireBase();
  }

  Widget _buildTabIcon(BuildContext context, IconData icon, bool isSelected) {
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.grey
                  .withOpacity(0.2), // Background color when selected
              shape: BoxShape.circle,
            )
          : null,
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.white, // Icon color
        size: isSelected ? 30 : 24, // Size of the icon when selected
      ),
    );
  }

  _initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AppUrls.bannerAdID,
        listener: BannerAdListener(onAdLoaded: (ad) {
          print('load ho gai add');
          _isAdLoaded = true;
        }, onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('$ad ka ye $error hai');
          }
        }),
        request: const AdRequest())
      ..load();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      print(value);
      print("gettokeh");
      token1 = value!;
      saveToken(token1);
    });
  }

  void saveToken(String token) async {
    try {
      print("save");
      await FirebaseFirestore.instance.collection('users').doc(myid).update({
        'token': token,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  dataFireBase() async {
    if (kDebugMode) {
      print("Following is database registered users");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myid = prefs.getString("myid")!;
    print(myid);
    getToken();
    await db.collection("users").doc(myid).get().then((event) async {
      myuser = AppUser(
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
    await initCallServices();
    print('out call service');
    setState(() {
      isLoading = true;
    });
    return myuser;
  }

  //
  // clean() async{
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   await preferences.clear();
  //   preferences.remove("isLogin");
  //   preferences.setBool("isLogin", false);
  // }
  //
  //

  initCallServices() {
    print('in call service');
    try {
      // ZegoUIKitPrebuiltCallInvitationService().init(
      //   appID: MyConst.appId /*input your AppID*/,
      //   appSign: MyConst.appSignId /*input your AppSign*/,
      //   userID: myuser!.id,
      //   userName: myuser!.name,
      //   plugins: [ZegoUIKitSignalingPlugin()],
      // );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  getData() {}

  @override
  Widget build(BuildContext context) {
    // return DefaultTabController(
    //   initialIndex: widget.tab,
    //   length: 4,
    //   child: FutureBuilder(
    //       future: getData(),
    //       builder: (BuildContext context, AsyncSnapshot snapshot) {
    //         return Scaffold(
    //           appBar: PreferredSize(
    //             preferredSize: const Size.fromHeight(60),
    //             child: AppBar(
    //               elevation: 0,
    //               backgroundColor: Theme.of(context).colorScheme.onPrimary,
    //               bottom: TabBar(
    //                 labelColor: Theme.of(context).colorScheme.primary,
    //                 indicatorSize: TabBarIndicatorSize.tab,
    //                 indicator: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(20),
    //                   color: const Color(0xff8097a2),
    //                 ),
    //                 indicatorPadding: const EdgeInsets.all(6),
    //                 unselectedLabelColor: Theme.of(context).colorScheme.primary,
    //                 indicatorColor: Colors.transparent,
    //                 indicatorWeight: 1,
    //                 dividerColor: Theme.of(context).colorScheme.onPrimary,
    //                 labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    //                 tabs: const [
    //                   Tab(
    //                     // text: '',
    //                     icon: Icon(Icons.cabin),
    //                   ),
    //                   Tab(
    //                     // text: '',
    //                     icon: Icon(Icons.add_chart),
    //                   ),
    //                   Tab(
    //                     // text: '',
    //                     icon: Icon(Icons.chat),
    //                   ),
    //                   Tab(
    //                     // text: '',
    //                     icon: Icon(Icons.person),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //           body: TabBarView(
    //             children: [
    //               HomeScreen(myuser: myuser),
    //               StatusScreen(
    //                 myuser: myuser,
    //               ),
    //               ChatScreen(user: myuser),
    //               ProfileScreen(
    //                 myuser: myuser,
    //               )
    //             ],
    //           ),
    //           bottomNavigationBar: _isAdLoaded
    //               ? Container(
    //                   height: _bannerAd.size.height.toDouble(),
    //                   width: _bannerAd.size.width.toDouble(),
    //                   child: AdWidget(
    //                     ad: _bannerAd,
    //                   ),
    //                 )
    //               : SizedBox(),
    //         );
    //       }),
    // );
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (_tabController.index == 0) {
          // Show dialog to confirm exit from the app
          bool exitConfirmed = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Exit'),
              content: const Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel exit
                  },
                  child: Text(
                    'No',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm exit
                  },
                  child: Text(
                    'Yes',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                  ),
                ),
              ],
            ),
          );

          // If exit is confirmed, exit the app
          if (exitConfirmed) {
            SystemNavigator.pop();
          }
        } else {
          // Go back to the 0th tab
          _tabController.animateTo(0);
          // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //     MaterialPageRoute(
          //         builder: (context) => const MainPage(
          //               tab: 0,
          //             )),
          //     (route) => false);
        }
      },
      child: DefaultTabController(
        initialIndex: widget.tab,
        length: 4,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child:AppBar(
  elevation: 0,
  backgroundColor: Theme.of(context).colorScheme.onPrimary,
  bottom: TabBar(
    controller: _tabController,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white,
    indicator: BoxDecoration(
      color: Color(0xffD3D3D3), // Background color for the selected tab
      borderRadius: BorderRadius.circular(20), // Rounded corners
    ),
    indicatorPadding: const EdgeInsets.symmetric(
      horizontal: 15.0,
      vertical: 8.0,
    ), // Adjust padding for the size of the container
    indicatorSize: TabBarIndicatorSize.tab, // Makes the indicator cover the entire tab
    tabs: [
      Tab(
        icon: Icon(
          Icons.cabin,
          color: Colors.white,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.add_chart,
          color: Colors.white,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
      Tab(
        icon: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
    ],
  ),
),
          ),
          body: isLoading
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    HomeScreen(myuser: myuser!),
                    StatusScreen(myuser: myuser!),
                    ChatScreen(user: myuser!),
                    ProfileScreen(
                        currentUserID: FirebaseAuth.instance.currentUser!.uid),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff607d8b),
                  ),
                ),
          bottomNavigationBar: SizedBox(
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(
              ad: _bannerAd!,
            ),
          ),
        ),
      ),
    );
    // : const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator(
    //         color: Color(0xff607d8b),
    //       ),
    //     ),
    //   );

    // Center(
    //     child: GridView.count(
    //         crossAxisCount: 2,
    //         crossAxisSpacing: 4.0,
    //         mainAxisSpacing: 8.0,
    //         children: List.generate(10, (index) {
    //           return const CustomGridView();
    //         }
    //         )
    //     )
    // )
  }
}

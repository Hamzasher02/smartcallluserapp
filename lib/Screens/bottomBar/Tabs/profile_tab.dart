import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Screens/profile/app_policy.dart';
import 'package:smart_call_app/Screens/profile/edit_profile.dart';
import 'package:smart_call_app/Screens/profile/feedback_page.dart';
import 'package:smart_call_app/Util/constants.dart';

import '../../authentication/authentication_screen.dart';
import '../main_page.dart';
import '../../../db/entity/app_user.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserID;

  const ProfileScreen({super.key, required this.currentUserID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Profile Screen state
class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,

      body: StreamBuilder<DocumentSnapshot>(
          stream: db.collection("users").doc(widget.currentUserID).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            AppUser myuser = AppUser.fromSnapshot(snapshot.data!);
            log("ID: ${myuser.id}");
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    // height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      boxShadow: const [BoxShadow(blurRadius: 20.0)],
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(
                              MediaQuery.of(context).size.width, 100.0)),
                    ),
                    child: Padding(
                      padding:
                        const  EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 90,
                                      width: 90,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(
                                          imageUrl: myuser.profilePhotoPath,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    myuser.status == "online"
                                        ? const Positioned(
                                            right: 2,
                                            bottom: 10,
                                            child: CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.white,
                                              child: CircleAvatar(
                                                radius: 4,
                                                backgroundColor:
                                                    Color(0xFF39FF14),
                                              ),
                                            ),
                                          )
                                        : const Positioned(
                                            right: 2,
                                            bottom: 10,
                                            child: CircleAvatar(
                                              radius: 5,
                                              backgroundColor: Colors.white,
                                              child: CircleAvatar(
                                                radius: 4,
                                                backgroundColor: Colors.grey,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                myuser.name,
                                maxLines: 2,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                Country.tryParse(myuser.country)!.name,
                                maxLines: 2,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    myuser.views.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    myuser.likes.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  settingCard(context, "Home", () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const MainPage(
                          tab: 0,
                        ),
                      ),
                      (route) => false,
                    );
                  }),
                  settingCard(context, "Status", () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const MainPage(
                          tab: 1,
                        ),
                      ),
                      (route) => false,
                    );
                  }),
                  settingCard(context, "Chats", () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const MainPage(
                          tab: 2,
                        ),
                      ),
                      (route) => false,
                    );
                  }),
                  settingCard(
                    context,
                    "Edit Profile",
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditProfile(
                            myuser: myuser,
                          ),
                        ),
                      );
                    },
                  ),
                  settingCard(context, "App Policy", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AppPolicy(),
                      ),
                    );
                  }),
                  settingCard(context, "Feedback", () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  }),
                  settingCard(context, "Rate App", () {}),
                  settingCard(context, "Invite Friends", () {
                    Share.share(
                        "Unlock a world of seamless communication! Join me on the Smartcall journey, where crystal-clear connections meet innovative features. Download the Smartcall app now and let's stay connected in the smartest way possible! 📱✨ ",
                        subject: 'Checkout Now');
                  }),
                  settingCard(context, "Logout", () {
                    logOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const AuthenticationScreen()),
                      (route) => false,
                    );
                  }),
                  const SizedBox(
                    height: 40,
                  )
                ],
              ),
            );
          }),
    );
  }

  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Card settingCard(
      BuildContext context, String text, VoidCallback onTapFunction) {
    return Card(
      color: Theme.of(context).cardTheme.color,
      elevation: 8,
      shadowColor: Theme.of(context).cardTheme.shadowColor,
      child: GestureDetector(
        onTap: onTapFunction,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).cardTheme.color,
          ),
          width: getWidth(context) * .9,
          height: 70,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

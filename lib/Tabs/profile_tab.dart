import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_call_app/Pages/app_policy.dart';
import 'package:smart_call_app/Pages/edit_profile.dart';
import 'package:smart_call_app/Util/constants.dart';

import '../Screens/authentication/authentication_screen.dart';
import '../Screens/main_page.dart';
import '../Widgets/country_to_flag.dart';
import '../db/entity/app_user.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser myuser;

  const ProfileScreen({super.key, required this.myuser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Profile Screen state
class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.red[900],
                boxShadow: const [BoxShadow(blurRadius: 20.0)],
                borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(MediaQuery.of(context).size.width, 100.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(widget.myuser.profilePhotoPath),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.myuser.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            countryCodeToEmoji(widget.myuser.country),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            Country.tryParse(widget.myuser.country)!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
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
                          widget.myuser.views.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
                        widget.myuser.likes.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
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
                      myuser: widget.myuser,
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
            settingCard(context, "Feedback", () {}),
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
                MaterialPageRoute(builder: (BuildContext context) => const AuthenticationScreen()),
                (route) => false,
              );
            }),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }

  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Card settingCard(BuildContext context, String text, VoidCallback onTapFunction) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      elevation: 8,
      shadowColor: Theme.of(context).backgroundColor,
      child: GestureDetector(
        onTap: onTapFunction,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Theme.of(context).colorScheme.primary),
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
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

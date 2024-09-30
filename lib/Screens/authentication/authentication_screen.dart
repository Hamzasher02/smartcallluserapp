import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_call_app/Screens/authentication/widgets/sign_up.dart';
import '../../Util/k_images.dart';
import '../../Widgets/custom_image.dart';
import '../bottomBar/main_page.dart';
import 'controller/auth.dart';
import 'controller/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Future<Response> registerUserFb() async {
  //   Response<dynamic> response = await signInWithFacebook();
  //   print('response haii');
  //   print(response);
  //   if (response is Success<OAuthCredential>) {
  //     print('ooo');
  //     print(FirebaseAuth.instance.currentUser!.uid);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString("myid", FirebaseAuth.instance.currentUser!.uid);
  //     return response;
  //   }
  //   if (response is Error) {
  //     print('error');
  //     print(response);
  //   }
  //   return response;
  // }

  Future<Response> registerUserGoogle(BuildContext context) async {
  Response<dynamic> response = await signInWithGoogle(context);
  print('response haii');
  print(response);

  if (response is Success<OAuthCredential>) {
    print('ooo');
    print(FirebaseAuth.instance.currentUser!.uid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("myid", FirebaseAuth.instance.currentUser!.uid);

    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc =
        await db.collection("users").doc(currentUser!.uid).get();

    if (!userDoc.exists) {
      // If user document doesn't exist, go to the Sign Up screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SignUp(),
        ),
        (route) => false,
      );
    } else {
      // If user document exists, navigate to the main page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MainPage(tab: 0),
        ),
        (route) => false,
      );
    }

    prefs.setBool('isLogin', true);
  } else if (response is Error) {
    print('error');
    print(response);
  }

  return response;
}


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xff607d8b),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          height: height,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: const CustomImage(
                      path: Kimages.mainLogo,
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 80, 30, 20),
                  child: SizedBox(
                    width: width * 0.7,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        registerUserGoogle(context).then((response) async {
                          if (response is Success<OAuthCredential>) {
                            try {
                              await db
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get()
                                  .then(
                                (event) async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('isLogin', true);
                                },
                              );
                            } catch (e) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('isLogin', true);
                              nextScreen();
                            }
                          }
                        });
                      },
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: SizedBox(
                    width: width * 0.7,
                    height: 60,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          // registerUserFb().then((response) async {
                          //   if (response is Success<OAuthCredential>) {
                          //     try {
                          //       await db
                          //           .collection("users")
                          //           .doc(FirebaseAuth.instance.currentUser!.uid)
                          //           .get()
                          //           .then((event) async {
                          //         SharedPreferences prefs =
                          //             await SharedPreferences.getInstance();
                          //         prefs.setBool('isLogin', true);
                          //         homeScreen();
                          //       });
                          //     } catch (e) {
                          //       SharedPreferences prefs =
                          //           await SharedPreferences.getInstance();
                          //       prefs.setBool('isLogin', true);
                          //       nextScreen();
                          //     }
                          //   }
                          // });
                        },
                        child: Text(
                          'Continue with Facebook',
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.primary),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: const Center(
        child: Text(
          'Welcome to\nSmart Video Call',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
    );
  }

  nextScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const SignUp(),
      ),
      (route) => false,
    );
  }

  homeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const MainPage(tab: 0),
      ),
      (route) => false,
    );
  }
}

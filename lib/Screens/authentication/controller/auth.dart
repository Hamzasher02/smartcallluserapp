import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_call_app/Screens/authentication/controller/response.dart';
import 'package:smart_call_app/Screens/authentication/widgets/sign_up.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';

// Future<Response<OAuthCredential>> signInWithFacebook() async {
//   try {
//     final LoginResult loginResult = await FacebookAuth.instance.login();

//     final OAuthCredential facebookAuthCredential =
//         FacebookAuthProvider.credential(loginResult.accessToken!.token);
//     FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
//     return Response.success(facebookAuthCredential);
//   } catch (e) {
//     print("error hai " + e.toString());

//     return Response.error('message');
//   }
// }

Future<Response<OAuthCredential>> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return Response.error('Sign-in aborted by user');
    }

    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in to Firebase with the Google credential
    UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);

    // Check if the user is new
    if (authResult.additionalUserInfo!.isNewUser) {
      // Navigate to Sign Up screen for new users
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SignUp(),
        ),
        (route) => false,
      );
    } else {
      // Navigate to Main Page for existing users
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MainPage(tab: 0),
        ),
        (route) => false,
      );
    }

    return Response.success(credential);
  } catch (e) {
    print('Error during sign-in: ${e.toString()}');
    // Improved error message for better understanding
    return Response.error('Google sign-in failed: ${e.toString()}');
  }
}

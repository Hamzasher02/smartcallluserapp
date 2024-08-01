import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_call_app/Screens/authentication/controller/response.dart';
import 'package:smart_call_app/Screens/authentication/widgets/sign_up.dart';
import 'package:smart_call_app/Screens/bottomBar/main_page.dart';

Future<Response<OAuthCredential>> signInWithFacebook() async {
  // Trigger the sign-in flow
  try{
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
    FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    // Once signed in, return the UserCredential
    return Response.success(facebookAuthCredential);
  }
  catch(e){
    print("error hai " + e.toString());
    // return Response.error(
    //     (e.toString());
    return Response.error('message');
  }
  // final LoginResult loginResult = await FacebookAuth.instance.login();
  //
  // // Create a credential from the access token
  // final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
  // print(facebookAuthCredential);
  // // Once signed in, return the UserCredential
  // return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}



Future<Response<OAuthCredential>> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return Response.error('Sign-in aborted by user');
    }

    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);

    print('User signed in: ${authResult.user?.uid}');
    if (authResult.additionalUserInfo!.isNewUser) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const SignUp(),
        ),
        (route) => false,
      );
    } else {
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
    return Response.error((e as FirebaseException).message ?? e.toString());
  }
}


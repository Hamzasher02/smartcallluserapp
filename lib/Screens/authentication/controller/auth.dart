import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_call_app/Screens/authentication/controller/response.dart';

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



Future<Response<OAuthCredential>> signInWithGoogle() async {
  // Trigger the authentication flow
  try{
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    // Once signed in, return the UserCredential
    return Response.success(credential);
  }
  catch(e){
    return Response.error(
        ((e as FirebaseException).message ?? e.toString()));
  }
  // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //
  // // Obtain the auth details from the request
  // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  //
  // // Create a new credential
  // final credential = GoogleAuthProvider.credential(
  //   accessToken: googleAuth?.accessToken,
  //   idToken: googleAuth?.idToken,
  // );
  // print(credential);
  //
  // // Once signed in, return the UserCredential
  // return await FirebaseAuth.instance.signInWithCredential(credential);
}

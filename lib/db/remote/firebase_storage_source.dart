import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../Screens/authentication/controller/response.dart';


class FirebaseStorageSource {
  FirebaseStorage instance = FirebaseStorage.instance;

  Future<Response<String>> uploadUserProfilePhoto(
      String filePath, String userId) async {
    String userPhotoPath = "user_photos/$userId/profile_photo";

    try {
      await instance.ref(userPhotoPath).putFile(File(filePath));
      String downloadUrl = await instance.ref(userPhotoPath).getDownloadURL();
      return Response.success(downloadUrl);
    } catch (e) {
      return Response.error((e.toString()));
    }
  }

  // Future<Response<String>> uploadUserOptional1Photo(
  //     String filePath, String userId) async {
  //   String userOptionalPhotoPath = "user_photos/$userId/optional_photo/optional1";
  //
  //   try {
  //     await instance.ref(userOptionalPhotoPath).putFile(File(filePath));
  //     String downloadUrl = await instance.ref(userOptionalPhotoPath).getDownloadURL();
  //     return Response.success(downloadUrl);
  //   } catch (e) {
  //     return Response.error(((e as FirebaseException).message ?? e.toString()));
  //   }
  // }
  //
  // Future<Response<String>> uploadUserOptional2Photo(
  //     String filePath, String userId) async {
  //   String userOptionalPhotoPath = "user_photos/$userId/optional_photo/optional2";
  //
  //   try {
  //     await instance.ref(userOptionalPhotoPath).putFile(File(filePath));
  //     String downloadUrl = await instance.ref(userOptionalPhotoPath).getDownloadURL();
  //     return Response.success(downloadUrl);
  //   } catch (e) {
  //     return Response.error(((e as FirebaseException).message ?? e.toString()));
  //   }
  // }
  // Future<Response<String>> uploadUserOptional3Photo(
  //     String filePath, String userId) async {
  //   String userOptionalPhotoPath = "user_photos/$userId/optional_photo/optional3";
  //
  //   try {
  //     await instance.ref(userOptionalPhotoPath).putFile(File(filePath));
  //     String downloadUrl = await instance.ref(userOptionalPhotoPath).getDownloadURL();
  //     return Response.success(downloadUrl);
  //   } catch (e) {
  //     return Response.error(((e as FirebaseException).message ?? e.toString()));
  //   }
  // }
  // Future<Response<String>> uploadUserOptional4Photo(
  //     String filePath, String userId) async {
  //   String userOptionalPhotoPath = "user_photos/$userId/optional_photo/optional4";
  //
  //   try {
  //     await instance.ref(userOptionalPhotoPath).putFile(File(filePath));
  //     String downloadUrl = await instance.ref(userOptionalPhotoPath).getDownloadURL();
  //     return Response.success(downloadUrl);
  //   } catch (e) {
  //     return Response.error(((e as FirebaseException).message ?? e.toString()));
  //   }
  // }
  // Future<Response<String>> uploadUserOptional5Photo(
  //     String filePath, String userId) async {
  //   String userOptionalPhotoPath = "user_photos/$userId/optional_photo/optional5";
  //
  //   try {
  //     await instance.ref(userOptionalPhotoPath).putFile(File(filePath));
  //     String downloadUrl = await instance.ref(userOptionalPhotoPath).getDownloadURL();
  //     return Response.success(downloadUrl);
  //   } catch (e) {
  //     return Response.error(((e as FirebaseException).message ?? e.toString()));
  //   }
  // }
  // Future<Response<String>> uploadUserOptional6Photo(
  //     String filePath, String userId) async {
  //   String userOptionalPhotoPath = "user_photos/$userId/optional_photo/optional6";
  //
  //   try {
  //     await instance.ref(userOptionalPhotoPath).putFile(File(filePath));
  //     String downloadUrl = await instance.ref(userOptionalPhotoPath).getDownloadURL();
  //     return Response.success(downloadUrl);
  //   } catch (e) {
  //     return Response.error(((e as FirebaseException).message ?? e.toString()));
  //   }
  // }

  Future<Response<String>>uploadStoryImage(String filePath, String userId) async {
    String userPhotoPath = "user_photos/$userId/status_photo";

    try {
    await instance.ref(userPhotoPath).putFile(File(filePath));
    String downloadUrl = await instance.ref(userPhotoPath).getDownloadURL();
    return Response.success(downloadUrl);
    } catch (e) {
    return Response.error((e.toString()));
    }
  }

}

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

  Future<Response<String>> uploadStoryImage(
      String filePath, String userId) async {
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

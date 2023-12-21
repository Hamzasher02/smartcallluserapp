import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Screens/authentication/controller/response.dart';
import '../Models/chat_with_user.dart';
import '../entity/app_user.dart';
import '../entity/chat.dart';
import '../entity/match.dart';
import '../entity/utils.dart';
import '../remote/firebase_database_source.dart';
import '../remote/firebase_storage_source.dart';

class UserProvider extends ChangeNotifier {
  //FirebaseAuthSource _authSource = FirebaseAuthSource();
  FirebaseStorageSource _storageSource = FirebaseStorageSource();
  FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  bool isLoading = false;
  late AppUser _user;

  // Future<AppUser> get user => _getUser();

  // Future<Response> loginUser(String email, String password,
  //     GlobalKey<ScaffoldState> errorScaffoldKey) async {
  //   Response<dynamic> response = await _authSource.signIn(email, password);
  //   if (response is Success<UserCredential>) {
  //     String id = response.value.user!.uid;
  //     print("love");
  //     print(id);
  //     // SharedPreferencesUtil.setUserId(id);
  //   } else if (response is Error) {
  //     // showSnackBar(errorScaffoldKey, response.message);
  //   }
  //   return response;
  // }
  //
  // Future<Response> registerUser(UserRegistration userRegistration,
  //     GlobalKey<ScaffoldState> errorScaffoldKey) async {
  //   Response<dynamic> response = await _authSource.register(
  //       userRegistration.email, userRegistration.password);
  //   if (response is Success<UserCredential>) {
  //     String id = (response as Success<UserCredential>).value.user!.uid;
  //     response = await _storageSource.uploadUserProfilePhoto(
  //         userRegistration.localProfilePhotoPath, id);
  //
  //     if (response is Success<String>) {
  //       String profilePhotoUrl = response.value;
  //       AppUser user = AppUser(
  //           id: id,
  //           firstname: userRegistration.firstname,
  //           lastname: userRegistration.lastname,
  //           // age: userRegistration.age,
  //           profilePhotoPath: profilePhotoUrl
  //           );
  //       _databaseSource.addUser(user);
  //       SharedPreferencesUtil.setUserId(id);
  //       _user = _user;
  //       return Response.success(user);
  //     }
  //   }
  //   if (response is Error) showSnackBar(errorScaffoldKey, response.message);
  //   return response;
  // }

  // Future<AppUser> _getUser() async {
  //   if (_user != null) return _user;
  //   String? id = await SharedPreferencesUtil.getUserId();
  //   _user = AppUser.fromSnapshot(await _databaseSource.getUser(id!));
  //   return _user;
  // }

  // void updateUserProfilePhoto(
  //     String localFilePath, GlobalKey<ScaffoldState> errorScaffoldKey) async {
  //   isLoading = true;
  //   notifyListeners();
  //   Response<dynamic> response =
  //       await _storageSource.uploadUserProfilePhoto(localFilePath, _user.id);
  //   isLoading = false;
  //   if (response is Success<String>) {
  //     // _user.profilePhotoPath = response.value;
  //     _databaseSource.updateUser(_user);
  //   } else if (response is Error) {
  //     showSnackBar(errorScaffoldKey, response.message);
  //   }
  //   notifyListeners();
  // }
  //
  // void updateUserlastname(String newlastname) {
  //   // _user.lastname = newlastname;
  //   _databaseSource.updateUser(_user);
  //   notifyListeners();
  // }
  //
  // void updateUserBio(String newBio) {
  //   // _user.bio = newBio;
  //   _databaseSource.updateUser(_user);
  //   notifyListeners();
  // }

  // Future<void> logoutUser() async {
  //   // _user = null;
  //   await SharedPreferencesUtil.removeUserId();
  // }

  Future<List<ChatWithUser>> getChatsWithUser(String userId) async {
    //var matches = await _databaseSource.getMatches(userId);
    var chatbuddy = await _databaseSource.getChatBuddy(userId);
    List<ChatWithUser> chatWithUserList = [];
    print(chatWithUserList);
    print(chatbuddy.size);

    for (var i = 0; i < chatbuddy.size; i++) {
      Match match = Match.fromSnapshot(chatbuddy.docs[i]);
      AppUser matchedUser =
          AppUser.fromSnapshot(await _databaseSource.getUser(match.id));


      String chatId = compareAndCombineIds(match.id, userId);
      print(chatId);

      try{Chat chat = Chat.fromSnapshot(await _databaseSource.getChat(chatId));
      print(chat.id);
      print(chat.lastMessage);
      ChatWithUser chatWithUser = ChatWithUser(chat, matchedUser);
      print(matchedUser);
      chatWithUserList.add(chatWithUser);}
      catch(e){print(e.toString());}

    }
    // for (var i = 0; i < messagesent.size; i++) {
    //   print(messagesent.size);
    //   // Match match = Match.fromSnapshot(messagesent.docs[i]);
    //   // print(match.id);
    //   AppUser matchedUser =
    //   AppUser.fromSnapshot(await _databaseSource.getUser(match.id));
    //
    //   String chatId = compareAndCombineIds(match.id, userId);
    //   print(chatId);
    //
    //   Chat chat = Chat.fromSnapshot(await _databaseSource.getChat(chatId));
    //   print(chat.id);
    //   print(chat.lastMessage);
    //   ChatWithUser chatWithUser = ChatWithUser(chat, matchedUser);
    //   print(matchedUser);
    //   chatWithUserList.add(chatWithUser);
    // }
    return chatWithUserList;
  }
 }

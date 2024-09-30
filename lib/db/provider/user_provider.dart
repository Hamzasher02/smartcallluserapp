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
  FirebaseStorageSource _storageSource = FirebaseStorageSource();
  FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();

  bool isLoading = false;
  late AppUser _user;
  String _myId = ''; // Add this to store the logged-in user's id.
  List<ChatWithUser> chatWithUserList = [];

  // Getter for the current user
  AppUser get myuser => _user;

  // Getter for the current user's id
  String get myid => _myId;

  // Set user details when the user logs in or data is fetched
  Future<void> setUserDetails(AppUser user, String myId) async {
    _user = user;
    _myId = myId;
    notifyListeners();  // Notifies listeners that user data has been updated
  }

  // Method to remove a chat with a user
  void removeChatWithUser(String chatId) {
    chatWithUserList.removeWhere((chatWithUser) => chatWithUser.chat.id == chatId);
    notifyListeners(); // This ensures the UI updates
  }

  // Fetch chat details with users
  Future<List<ChatWithUser>> getChatsWithUser(String userId) async {
    var chatbuddy = await _databaseSource.getChatBuddy(userId);
    List<ChatWithUser> chatWithUserList = [];

    for (var i = 0; i < chatbuddy.size; i++) {
      try {
        Match match = Match.fromSnapshot(chatbuddy.docs[i]);
        AppUser matchedUser = AppUser.fromSnapshot(await _databaseSource.getUser(match.id));
        String chatId = compareAndCombineIds(match.id, userId);
        Chat chat = Chat.fromSnapshot(await _databaseSource.getChat(chatId));

        ChatWithUser chatWithUser = ChatWithUser(chat, matchedUser);
        chatWithUserList.add(chatWithUser);
      } catch (e) {
        print('Error processing chat buddy: $e');
      }
    }

    // Sort the list by the timestamp of the last message
    chatWithUserList.sort((a, b) {
      return (b.chat.lastMessage?.epochTimeMs ?? 0).compareTo(a.chat.lastMessage?.epochTimeMs ?? 0);
    });

    return chatWithUserList;
  }
}

 
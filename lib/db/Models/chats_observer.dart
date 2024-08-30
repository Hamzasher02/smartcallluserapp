import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/chat.dart';
import '../remote/firebase_database_source.dart';
import 'chat_with_user.dart';

class ChatsObserver {
  final FirebaseDatabaseSource _databaseSource = FirebaseDatabaseSource();
  List<ChatWithUser> chatsList = [];
  List<StreamSubscription<DocumentSnapshot>> subscriptionList = [];

  ChatsObserver(this.chatsList);

  void startObservers(Function onChatUpdated) {
    for (var value in chatsList) {
      StreamSubscription<DocumentSnapshot> chatSubscription = _databaseSource.observeChat(value.chat.id).listen((event) {
        Chat updatedChat = Chat.fromSnapshot(event);

        if (updatedChat.lastMessage == null || value.chat.lastMessage == null || (updatedChat.lastMessage?.epochTimeMs != value.chat.lastMessage?.epochTimeMs)) {
          value.chat = updatedChat;
          onChatUpdated(); // Notify listeners of the change
        }
      });

      subscriptionList.add(chatSubscription);
    }
  }
}

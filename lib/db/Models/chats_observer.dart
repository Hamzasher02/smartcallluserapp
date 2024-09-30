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
  for (var chatWithUser in chatsList) {
    StreamSubscription<DocumentSnapshot> chatSubscription = _databaseSource.observeChat(chatWithUser.chat.id).listen((event) {
      Chat updatedChat = Chat.fromSnapshot(event);

      // Update the chat object if there's a new message
      if (updatedChat.lastMessage != null && 
          (chatWithUser.chat.lastMessage == null || updatedChat.lastMessage!.epochTimeMs != chatWithUser.chat.lastMessage!.epochTimeMs)) {
        chatWithUser.chat = updatedChat;
        onChatUpdated(); // Trigger UI update
      }
    });

    subscriptionList.add(chatSubscription);
  }
}
}

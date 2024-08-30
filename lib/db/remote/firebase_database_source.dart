import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_call_app/db/entity/fvrt.dart';
import '../entity/app_user.dart';
import '../entity/chat.dart';
import '../entity/message.dart';
import '../entity/sentmessage.dart';
import '../entity/story.dart';

class FirebaseDatabaseSource {
  final FirebaseFirestore instance = FirebaseFirestore.instance;
  // Store call information in both users' call logs and add it as a message in the chat
  Future<void> storeCallInfo({
  required String myUserId,
  required String otherUserId,
  required String chatId,
  required String callType, // 'missed', 'received', 'ended'
  required String callStatus, // 'Started', 'Ended', 'Declined', etc.
  required bool isIncoming, // true if the call was incoming, false if it was outgoing
  int? callDuration, // Duration in seconds, optional
}) async {
  String callId = DateTime.now().millisecondsSinceEpoch.toString();

  // Store call info for both users
  await instance.collection('users').doc(myUserId).collection('calls').doc(callId).set({
    'otherUserId': otherUserId,
    'callType': callType,
    'callStatus': callStatus,
    'isIncoming': isIncoming,
    'timestamp': DateTime.now(),
    'callDuration': callDuration,
  });

  await instance.collection('users').doc(otherUserId).collection('calls').doc(callId).set({
    'otherUserId': myUserId,
    'callType': callType,
    'callStatus': callStatus,
    'isIncoming': !isIncoming,
    'timestamp': DateTime.now(),
    'callDuration': callDuration,
  });

  // Also add this as a message in the chat
  Message1 callMessage = Message1(
    epochTimeMs: DateTime.now().millisecondsSinceEpoch,
    seen: false,
    senderId: myUserId,
    text: '', // Optionally, you can add a descriptive text here
    type: 'call', // Mark this message as a call
    callType: callType,
    callStatus: callStatus,
    callDuration: callDuration,
  );

  addMessage(chatId, callMessage);
}

  

  Stream<QuerySnapshot> getCallLogs(String userId) {
    return instance.collection('users').doc(userId).collection('calls').orderBy('timestamp', descending: true).snapshots();
  }

void addUser(AppUser user) {
  instance.collection('users').doc(user.id).set(user.toMap());
}


  // void deleteUser(String userId,Delete delete) {
  //   instance.collection('deletedacc').doc(userId).set(delete.toMap());
  // }
  //
  //
void addChat(Chat chat) {
  instance.collection('chats').doc(chat.id).set(chat.toMap());
}


  // Add a message to the chat
  void addMessage(String chatId, Message1 message) {
    instance.collection('chats').doc(chatId).collection('messages').add(message.toMap());
  }


  
 void addFavourites(String userId, AddFavourites addFavourites) {
  instance.collection('users').doc(userId).collection('favourites').doc(addFavourites.id).set(addFavourites.toMap());
}
Future<void> addFavourite(String myId, AddFavourites fav) async {
    await instance
        .collection('users')
        .doc(myId)
        .collection('favourites')
        .doc(fav.id)
        .set(fav.toMap());
  }

  Future<void> removeFavourite(String myId, String otherId) async {
    await instance
        .collection('users')
        .doc(myId)
        .collection('favourites')
        .doc(otherId)
        .delete();
  }


  void removeFavourites(String userId, AddFavourites addFavourites) {
    instance.collection('users').doc(userId).collection('favourites').doc(addFavourites.id).delete();
  }

  void addChatBuddy(String userId, SentMessage sentmessage) {
    instance.collection('users').doc(userId).collection('chatbuddy').doc(sentmessage.id).set(sentmessage.toMap());
  }

 

  void addView(id, view) async {
    instance.collection('users').doc(id).update({
      "views": view,
    });
  }

  void addFav(id, fav) async {
    instance.collection('users').doc(id).update({
      "likes": fav,
    });
  }

  void addFav2(id, fav) async {
    instance.collection('users').doc(id).update({
      "temp1": fav,
    });
  }

 Future<bool> updateStatus(String id, String status) async {
  try {
    await instance.collection('users').doc(id).update({
      "status": status,
    });
    return true;
  } catch (e) {
    return false;
  }
}


  void updateChat(Chat chat) {
    instance.collection('chats').doc(chat.id).update(chat.toMap());
  }

  void updateMessage(String chatId, String messageId, Message message) {
    instance.collection('chats').doc(chatId).collection('messages').doc(messageId).update(message.toMap());
  }

  Future<DocumentSnapshot> getUser(String userId) {
    return instance.collection('users').doc(userId).get();
  }


  Future<DocumentSnapshot> getChat(String chatId) {
    return instance.collection('chats').doc(chatId).get();
  }

 

Future<QuerySnapshot> getChatBuddy(String userId) async {
  try {
    final querySnapshot = await instance.collection('users').doc(userId).collection('chatbuddy').get();
    print('Chat buddy documents: ${querySnapshot.docs.length}');
    return querySnapshot;
  } catch (e) {
    print('Error retrieving chat buddies: $e');
    rethrow;
  }
}


 
  // Observe a user by their ID
  Stream<DocumentSnapshot> observeUser(String userId) {
    return instance.collection('users').doc(userId).snapshots();
  }

 // Observe messages in a chat
  Stream<QuerySnapshot> observeMessages(String chatId) {
    return instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('epoch_time_ms', descending: true)
        .snapshots();
  }


  Stream<DocumentSnapshot> observeChat(String chatId) {
    return instance.collection('chats').doc(chatId).snapshots();
  }

  Stream<QuerySnapshot> observeMessages2(String chatId) {
    return instance.collection('chats').doc(chatId).collection('messages').orderBy('epoch_time_ms', descending: false).snapshots();
  }

  void addStory(Story story) async {
    await FirebaseFirestore.instance
        .collection('stories')
        .doc(story.userId)
        .collection('story')
        .add({'userId': story.userId, 'imageUrl': story.imageUrl, 'timestamp': FieldValue.serverTimestamp(), 'likes': story.likes, 'type': story.type});
  }
}

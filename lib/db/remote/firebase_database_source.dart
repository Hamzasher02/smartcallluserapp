import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_call_app/db/entity/fvrt.dart';
import '../entity/app_user.dart';
import '../entity/chat.dart';
import '../entity/message.dart';
import '../entity/sentmessage.dart';
import '../entity/story.dart';

class FirebaseDatabaseSource {
  final FirebaseFirestore instance = FirebaseFirestore.instance;

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

  void addMessage(String chatId, Message message) {
    instance.collection('chats').doc(chatId).collection('messages').add(message.toMap());
  }

  // void addInterests(String userId, Interests interests) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('interests')
  //       .doc(userId)
  //       .set(interests.toMap());
  // }
  //
  void addFavourites(String userId, AddFavourites addFavourites) {
    instance.collection('users').doc(userId).collection('favourites').doc(addFavourites.id).set(addFavourites.toMap());
  }

  void removeFavourites(String userId, AddFavourites addFavourites) {
    instance.collection('users').doc(userId).collection('favourites').doc(addFavourites.id).delete();
  }

  void addChatBuddy(String userId, SentMessage sentmessage) {
    instance.collection('users').doc(userId).collection('chatbuddy').doc(sentmessage.id).set(sentmessage.toMap());
  }

  //
  // void addMessageRequestSent(String userId, SentRequest sentrequest) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('messagesentrequest')
  //       .doc(sentrequest.id)
  //       .set(sentrequest.toMap());
  // }
  //
  // void addCount(String userId, Count count) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('count')
  //       .doc(userId)
  //       .set(count.toMap());
  // }
  //
  //
  // void addRequestRecived(String userId, ReceivedRequest receivedrequest) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('recivedrequest')
  //       .doc(receivedrequest.id)
  //       .set(receivedrequest.toMap());
  // }
  //
  // void addMessageRequestRecived(String userId, ReceivedRequest receivedrequest) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('messagerecivedrequest')
  //       .doc(receivedrequest.id)
  //       .set(receivedrequest.toMap());
  // }
  //
  // void addMatch(String userId, Match match) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('matches')
  //       .doc(match.id)
  //       .set(match.toMap());
  // }
  //
  // void addSuggestion(String userId, Suggestion suggestion) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('suggestion')
  //       .doc(suggestion.id)
  //       .set(suggestion.toMap());
  // }
  //
  // void addBlockUser(String userId, Suggestion suggestion) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('blockedusers')
  //       .doc(suggestion.id)
  //       .set(suggestion.toMap());
  // }
  //
  // void addNeedhelp(String userId, NeedHelp needHelp) {
  //   instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('needhelp')
  //       .doc(needHelp.id)
  //       .set(needHelp.toMap());
  // }
  //
  // void updateUser(AppUser user) async {
  //   instance.collection('users').doc(user.id).update(user.toMap());
  // }
  //

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

  Future<bool> updateStatus(id, status) async {
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

  // Future<DocumentSnapshot> getSwipe(String userId, String swipeId) {
  //   return instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('swipes')
  //       .doc(swipeId)
  //       .get();
  // }
  //
  // Future<QuerySnapshot> getMatches(String userId) {
  //   return instance.collection('users').doc(userId).collection('matches').get();
  // }
  //
  // Future<QuerySnapshot> getMessageSent(String userId) {
  //   return instance.collection('users').doc(userId).collection('messagesentrequest').get();
  // }
  //
  Future<DocumentSnapshot> getChat(String chatId) {
    return instance.collection('chats').doc(chatId).get();
  }

  // Future<QuerySnapshot> getPersonsToMatchWith(
  //     int limit, List<String> ignoreIds) {
  //   return instance
  //       .collection('users')
  //       .where('id', whereNotIn: ignoreIds)
  //       .limit(limit)
  //       .get();
  // }
  //
  // Future<QuerySnapshot> getSwipes(String userId) {
  //   return instance.collection('users').doc(userId).collection('swipes').get();
  // }
  //
  //
  //

  Future<QuerySnapshot> getChatBuddy(String userId) {
    return instance.collection('users').doc(userId).collection('chatbuddy').get();
  }

  Stream<DocumentSnapshot> observeUser(String userId) {
    return instance.collection('users').doc(userId).snapshots();
  }

  Stream<QuerySnapshot> observeMessages(String chatId) {
    return instance.collection('chats').doc(chatId).collection('messages').orderBy('epoch_time_ms', descending: true).snapshots();
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

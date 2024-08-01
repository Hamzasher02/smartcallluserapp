import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class Chat {
  String id = '';
  Message? lastMessage;

  Chat(this.id, this.lastMessage);

  factory Chat.fromSnapshot(DocumentSnapshot snapshot) =>
      Chat(snapshot['id'], snapshot['last_message'] != null ? Message.fromMap(snapshot['last_message']) : null);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'last_message': lastMessage?.toMap(),
    };
  }
}

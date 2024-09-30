import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_call_app/db/entity/message.dart';

class Chat {
  String id;
  Message1? lastMessage;

  Chat(this.id, this.lastMessage);

  factory Chat.fromSnapshot(DocumentSnapshot snapshot) {
    return Chat(
      snapshot['id'],
      snapshot['last_message'] != null ? Message1.fromMap(snapshot['last_message']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'last_message': lastMessage?.toMap(),
    };
  }

  @override
  String toString() {
    return 'Chat(id: $id, lastMessage: ${lastMessage?.text ?? 'No Message'}, timestamp: ${lastMessage?.epochTimeMs ?? 'No Timestamp'})';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  int epochTimeMs = 0;
  bool? seen;
  String senderId;
  String text = '';
  String type = '';

  Message(this.epochTimeMs, this.seen, this.senderId, this.text, this.type);

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      map['epoch_time_ms'] as int,
      map['seen'] as bool,
      map['sender_id'] as String,
      map['text'] as String,
      map['type'] as String,
    );
  }

  factory Message.fromSnapshot(DocumentSnapshot snapshot) => Message(
        snapshot['epoch_time_ms'],
        snapshot['seen'],
        snapshot['sender_id'],
        snapshot['text'],
        snapshot['type'],
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'epoch_time_ms': epochTimeMs,
      'seen': seen,
      'sender_id': senderId,
      'text': text,
      'type': type,
    };
  }
}

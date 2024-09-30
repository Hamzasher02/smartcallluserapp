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


class Message1 {
  int epochTimeMs;
  bool? seen;
  String senderId;
  String text;
  String type;

  // Additional fields for call logs
  String? callType; // 'missed', 'received', 'ended', etc.
  String? callStatus; // 'video', 'voice'
  int? callDuration; // Duration in seconds

  Message1({
    required this.epochTimeMs,
    this.seen,
    required this.senderId,
    this.text = '',
    this.type = 'chat',
    this.callType,
    this.callStatus,
    this.callDuration,
  });

  factory Message1.fromMap(Map<String, dynamic> map) {
    return Message1(
      epochTimeMs: map['epoch_time_ms'] as int,
      seen: map['seen'] as bool?,
      senderId: map['sender_id'] as String,
      text: map['text'] as String? ?? '',
      type: map['type'] as String,
      callType: map['call_type'] as String?,
      callStatus: map['call_status'] as String?,
      callDuration: map['call_duration'] as int?,
    );
  }

  factory Message1.fromSnapshot(DocumentSnapshot snapshot) {
    return Message1(
      epochTimeMs: snapshot['epoch_time_ms'],
      seen: snapshot['seen'],
      senderId: snapshot['sender_id'],
      text: snapshot['text'] ?? '',
      type: snapshot['type'],
      callType: snapshot['call_type'],
      callStatus: snapshot['call_status'],
      callDuration: snapshot['call_duration'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'epoch_time_ms': epochTimeMs,
      'seen': seen,
      'sender_id': senderId,
      'text': text,
      'type': type,
      'call_type': callType,
      'call_status': callStatus,
      'call_duration': callDuration,
    };
  }
}

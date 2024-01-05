import 'package:cloud_firestore/cloud_firestore.dart';

class SentMessage {
  String id='';
  String sent='';

  SentMessage(this.id, this.sent);

  SentMessage.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    sent = snapshot['sent'];
  }
  SentMessage.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    sent = map['sent'];
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id, 'sent': sent
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  String id = '';

  Match(this.id);

  factory Match.fromSnapshot(DocumentSnapshot snapshot) => Match(
        snapshot['id'],
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id};
  }
}

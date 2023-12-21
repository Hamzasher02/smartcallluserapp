import 'package:cloud_firestore/cloud_firestore.dart';

class AddFavourites {
  String id='';
  String added='';

  AddFavourites(this.id, this.added);

  AddFavourites.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    added = snapshot['added'];
  }
  AddFavourites.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    added = map['added'];
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id, 'added': added
    };
  }
}

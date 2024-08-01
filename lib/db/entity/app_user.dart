import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id = "";
  String name = "";
  String age = "";
  String gender = "";
  String country = "";
  String profilePhotoPath = "";
  String token = "";
  String status = "";
  int likes = 0;
  int views = 0;
  String type = "";
  String temp1 = "";
  String temp2 = "";
  String temp3 = "";
  String temp4 = "";
  String temp5 = "";

  // String bio = "";

  AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.country,
    required this.profilePhotoPath,
    required this.token,
    required this.status,
    required this.likes,
    required this.type,
    required this.views,
    required this.temp1,
    required this.temp2,
    required this.temp3,
    required this.temp4,
    required this.temp5,
  });

  factory AppUser.fromSnapshot(DocumentSnapshot snapshot) => AppUser(
        id: snapshot['id'],
        name: snapshot['name'],
        age: snapshot['age'],
        gender: snapshot['gender'],
        country: snapshot['country'],
        profilePhotoPath: snapshot['profile_photo_path'],
        token: snapshot['token'],
        status: snapshot['status'],
        likes: snapshot['likes'],
        type: snapshot['type'],
        views: snapshot['views'],
        temp1: snapshot['temp1'],
        temp2: snapshot['temp2'],
        temp3: snapshot['temp3'],
        temp4: snapshot['temp4'],
        temp5: snapshot['temp5'],
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'country': country,
      'profile_photo_path': profilePhotoPath,
      'token': token,
      'status': status,
      'likes': likes,
      'type': type,
      'views': views,
      'temp1': temp1,
      'temp2': temp2,
      'temp3': temp3,
      'temp4': temp4,
      'temp5': temp5,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  String userId;
  String imageUrl;
  DateTime timestamp;
  List<String> likes;
  String id;
  String type;
  String userName;

  Story({
    required this.userId,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.id,
    required this.userName,
    required this.type,
  });

  factory Story.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Story(
      userId: data['userId'] ?? '',
      userName: data["userName"] ?? '',
      id: data["id"] ?? "",
      imageUrl: data['imageUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      type: data['type'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Story(userId: $userId, userName: $userName, id: $id, imageUrl: $imageUrl, timestamp: $timestamp, likes: $likes, type: $type)';
  }
}

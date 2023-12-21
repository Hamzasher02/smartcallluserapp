class Story {
  String userId;
  String imageUrl;
  DateTime timestamp;
  int likes =0;
  String type;

  Story({required this.userId, required this.imageUrl, required this.timestamp, required this.likes,required this.type});
}
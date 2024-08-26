class Story {
  String storyId;
  String storyText;
  String storyMediaUrl;
  String userId;
  DateTime timestamp;

  Story({
    required this.storyId,
    required this.storyText,
    required this.storyMediaUrl,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': storyId,
      'text': storyText,
      'imageUrl': storyMediaUrl,
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}

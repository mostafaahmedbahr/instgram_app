import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String storyId;
  final String storyText;
  final String? storyMediaUrl; // Make this nullable
  final String userId;
  final String userName;
  final bool isVideo;
  final DateTime timestamp;

  Story({
    required this.storyId,
    required this.storyText,
    this.storyMediaUrl, // Nullable in the constructor
    required this.userId,
    required this.userName,
    required this.isVideo,
    required this.timestamp,

  });

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      storyId: map['storyId'] ?? '',
      storyText: map['storyText'] ?? '',
      storyMediaUrl: map['storyMediaUrl'], // Nullable
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      isVideo: map['isVideo'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'storyText': storyText,
      'storyMediaUrl': storyMediaUrl, // Nullable
      'userId': userId,
      'userName': userName,
      'isVideo': isVideo,
      'timestamp': timestamp,

    };
  }
}

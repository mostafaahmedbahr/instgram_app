import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String commentText;
  final Timestamp createdAt;
  final String userId;
  final String userImage;
  final String userName;

  CommentModel({
    required this.commentId,
    required this.commentText,
    required this.createdAt,
    required this.userId,
    required this.userImage,
    required this.userName,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'],
      commentText: map['commentText'],
      createdAt: map['createdAt'],
      userId: map['userId'],
      userImage: map['userImage'],
      userName: map['userName'],
    );
  }
}
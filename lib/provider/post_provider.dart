import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../models/comment_model.dart';

class PostProvider with ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('instaAppPosts')
          .orderBy('timestamp', descending: true) // Order by timestamp, most recent first
          .get();

      _posts = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<DocumentSnapshot> getPostStream(String postId) {
    return FirebaseFirestore.instance.collection('instaAppPosts').doc(postId).snapshots();
  }

  Future<void> likePost(String postId , context , bool currentUserLikeOrNot) async {
    final String userId = Provider.of<UserProvider>(context, listen: false).userModel?.uid ?? '';
    final String userName = Provider.of<UserProvider>(context, listen: false).userModel?.name ?? '';
    final String userImage = Provider.of<UserProvider>(context, listen: false).userModel?.image ?? '';
    final postDoc = FirebaseFirestore.instance.collection('instaAppPosts')
        .doc(postId);

    try {
      // Check if the user has already liked the post
      final docSnapshot = await postDoc.get();
      final data = docSnapshot.data();
      final List<dynamic> likedBy = data?['likedBy'] ?? [];

      if (likedBy.contains(userId)) {
        // If the user has already liked the post, remove the like
        await postDoc.update({
          'likedBy': FieldValue.arrayRemove([userId , userName , userImage]),
          'likesCount': FieldValue.increment(-1),
          'currentUserLikeOrNot' :  !currentUserLikeOrNot,
        });
      } else {
        // If the user hasn't liked the post, add the like
        await postDoc.update({
          'likedBy': FieldValue.arrayUnion([userId , userName , userImage]),
          'likesCount': FieldValue.increment(1),
          'currentUserLikeOrNot' : currentUserLikeOrNot,
        });
      }
    } catch (e) {
      print('Error updating like: $e');
    }
  }

  Future<void> commentPost(String postId, BuildContext context,
      bool currentUserCommentOrNot, CommentModel comment) async {
    final String userId = Provider.of<UserProvider>(context, listen: false).userModel?.uid ?? '';
    final String userName = Provider.of<UserProvider>(context, listen: false).userModel?.name ?? '';
    final String userImage = Provider.of<UserProvider>(context, listen: false).userModel?.image ?? '';

    final postDoc = FirebaseFirestore.instance.collection('instaAppPosts').doc(postId);
    final commentDoc = postDoc.collection('commentedBy').doc();
     try {
      // Create a new comment document
      await commentDoc.set({
        'userId': userId,
        'userName': userName,
        'userImage': userImage,
        'commentText': comment.commentText,
        'commentId': commentDoc.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the post document with the new comment count
      await postDoc.update({
        'commentsCount': FieldValue.increment(1),
        'currentUserCommentOrNot': currentUserCommentOrNot,
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }


  Future<void> deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('instaAppPosts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }






}

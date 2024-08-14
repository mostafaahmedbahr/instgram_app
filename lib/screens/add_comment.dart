import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/comment_model.dart';
import '../provider/post_provider.dart';
import '../provider/user_provider.dart';

class AddCommentScreen extends StatefulWidget {
  const AddCommentScreen({super.key, required this.postId});
  final String postId;
  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  final TextEditingController commentController = TextEditingController();
  bool currentUserCommentOrNotVal = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchComments();
    });
  }

  List<CommentModel> commentsList = [];
  void fetchComments() {
    print("object");
    Provider.of<PostProvider>(context, listen: false)

        .getPostStream(widget.postId)

        .listen((snapshot) {

      final data = snapshot.data();

      if (data != null && data is Map<String, dynamic>) {
        final List<dynamic>? commentedBy = data['commentedBy'] as List<dynamic>?;
        final bool currentUserCommentOrNot =
            commentedBy?.contains(Provider.of<UserProvider>(context, listen: false).userModel?.uid ?? '') ?? false;
        setState(() {
          currentUserCommentOrNotVal = currentUserCommentOrNot;
        });

        // Fetch the comments
        FirebaseFirestore.instance
            .collection('instaAppPosts')
            .doc(widget.postId)
            .collection('commentedBy') // Changed from 'commentedBy' to 'comments'
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((commentSnapshot) {
          final comments = commentSnapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data())) // Added type casting
              .toList();
          setState(() {
            commentsList = comments;
            print(commentsList);
          });
        });
      }
    });
  }

  void addComment() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final comment = CommentModel(
      commentId: const Uuid().v4(),
      commentText: commentController.text,
      userId: userProvider.userModel?.uid ?? '',
      userImage: userProvider.userModel?.image ?? '',
      userName: userProvider.userModel?.name ?? '',
      createdAt: Timestamp.now(),
    );

    postProvider.commentPost(
      widget.postId,
      context,
      currentUserCommentOrNotVal,
      comment,
    ).then((_) {
      commentController.clear();
    }).catchError((error) {
      // Handle error
      print('Error adding comment: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Comment",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: Provider.of<PostProvider>(context, listen: false).getPostStream(widget.postId),
                builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

                return ListView.builder(
                    itemCount:  commentsList.length,
                    itemBuilder: (context, index) {
                      final comment = commentsList[index];
                      return ListTile(
                        title:   Text(
                          comment.userName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle:   Text(
                          comment.commentText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading:   CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            comment.userImage,
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite,
                            )),
                      );
                    });
                },
            
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    Provider.of<UserProvider>(context).userModel?.image ?? '',
                  ),
                ),
                SizedBox(
                  width: w * 0.03,
                ),
                Expanded(
                  child: TextFormField(
                    controller: commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration:   InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: (){
                          if(commentController.text!=""){
                            addComment();
                          }
                        },
                        icon: const Icon(Icons.send),
                      ),
                      hintText: "Add New Comment",
                      hintStyle: const TextStyle(color: Colors.white),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

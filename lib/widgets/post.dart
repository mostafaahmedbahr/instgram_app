import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/screens/add_comment.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../provider/post_provider.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
  });

  final Map<String, dynamic> post;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final bool isOwner = post["userUid"] == FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('instaAppPosts')
          .doc(post["postId"])
          .snapshots(),
    builder: (context, snapshot) {
        return Consumer<PostProvider>(builder: (context, postProvider, child) {
          DateTime dateTime = post["timestamp"].toDate();
          String formattedDate = DateFormat('yyyy-MM-dd HH:00').format(dateTime);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Row(
                     children: [
                       CircleAvatar(
                         radius: 30,
                         backgroundImage: NetworkImage(
                           "${post["userImage"]}",
                         ),
                       ),
                       SizedBox(
                         width: w * 0.05,
                       ),
                       Text(
                         "${post["userName"]}",
                         style: const TextStyle(color: Colors.white, fontSize: 22),
                       ),
                     ],
                   ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                           await Provider.of<PostProvider>(context, listen: false).deletePost(context, post["postId"]);
                        },
                      ),
                  ],
                ),
                SizedBox(
                  height: h * 0.01,
                ),
                Image.network(
                  "${post["postImageUrl"]}",
                  height: h * 0.5,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('instaAppPosts')
                                .doc(post["postId"])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                );
                              }
                              final postDoc = snapshot.data!.data() as Map<String, dynamic>;
                              final List<dynamic> likedBy = postDoc['likedBy'] ?? [];
                              final bool isLiked = likedBy.contains(FirebaseAuth.instance.currentUser!.uid);
                              return IconButton(
                                onPressed: () {
                                  Provider.of<PostProvider>(context, listen: false)
                                      .likePost(
                                      "${post["postId"]}",
                                      context,
                                      "${post["userUid"]}" ==
                                          FirebaseAuth.instance.currentUser!.uid
                                          ? true
                                          : false);
                                },
                                icon: Icon(
                                  Icons.favorite,
                                  color: isLiked
                                      ? Colors.red
                                      : Colors.white,
                                ),
                              );
                            }),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.comment,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Text(
                  "${post["likesCount"]} Likes",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Text(
                  "comment 1 ...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const AddCommentScreen();
                    }));
                  },
                  child: const Text(
                    "add new comment",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        });
    },

    );
  }
}

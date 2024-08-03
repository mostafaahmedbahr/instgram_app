import 'package:flutter/material.dart';
import 'package:instgram_app/screens/add_comment.dart';
import 'package:provider/provider.dart';

import '../provider/post_provider.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({super.key, required this.post, });
  final Map<String, dynamic>  post;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return  Consumer<PostProvider>(
        builder: (context, postProvider, child) {

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.comment,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "1 hour ago",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
                const Text(
                  "100 Likes",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const Text(
                  "comment 1 ...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
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
        }
    );
  }
}

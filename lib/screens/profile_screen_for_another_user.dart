import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../provider/user_provider.dart';

class ProfileScreenForAnotherUser extends StatefulWidget {
  const ProfileScreenForAnotherUser({super.key, required this.uid});
  final String uid;
  @override
  State<ProfileScreenForAnotherUser> createState() =>
      _ProfileScreenForAnotherUserState();
}

class _ProfileScreenForAnotherUserState
    extends State<ProfileScreenForAnotherUser> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUserData(userId: widget.uid.toString());
        userProvider.fetchUserPosts(userId: widget.uid.toString());
    });
  }
  bool isFollowing = false;
  void isUserFollowing() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('instaAppUsers').doc(currentUserId).get();
      // Check if the data is not null and is of type Map<String, dynamic>
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        List<dynamic> followingList = userData['following'] ?? [];
        setState(() {
          isFollowing = followingList.contains(widget.uid);
        });
      }
    }
  }
  void toggleFollowUser() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference currentUserRef = firestore.collection('instaAppUsers').doc(currentUserId);
      DocumentReference userToFollowRef = firestore.collection('instaAppUsers').doc(widget.uid);

      firestore.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot = await transaction.get(currentUserRef);
        DocumentSnapshot userToFollowSnapshot = await transaction.get(userToFollowRef);

        if (currentUserSnapshot.exists && userToFollowSnapshot.exists) {
          List<dynamic> followingList = currentUserSnapshot.get('following') ?? [];
          List<dynamic> followersList = userToFollowSnapshot.get('followers') ?? [];

          if (followingList.contains(widget.uid)) {
            // Unfollow user
            followingList.remove(widget.uid);
            followersList.remove(currentUserId);
          } else {
            // Follow user
            followingList.add(widget.uid);
            followersList.add(currentUserId);
          }

          transaction.update(currentUserRef, {'following': followingList});
          transaction.update(userToFollowRef, {'followers': followersList});

          bool isCurrentlyFollowing = followingList.contains(widget.uid);
          setState(() {
            isFollowing = isCurrentlyFollowing;
          });
        }
      });
    } else {
      print('User is not logged in');
    }
  }
  Stream<DocumentSnapshot> followingStream(String currentUserId) {
    return FirebaseFirestore.instance.collection('instaAppUsers').doc(currentUserId).snapshots();
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title:   Text(
            "${userProvider.userModel?.name}",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white),
          ),
          backgroundColor: Colors.black87,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back ,color: Colors.white,),),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('instaAppUsers')
                .doc(widget.uid)
                .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            if (userData == null) {
              return const Center(child: Text('No user data'));
            }
            List<dynamic> followersList = userData['followers'] ?? [];
            bool isFollowing = followersList.contains(FirebaseAuth.instance.currentUser?.uid);
            return userProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userProvider.userModel == null
                ? const Center(child: Text('No user data'))
                : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(
                            "${userProvider.userModel?.image}"
                         ),
                      ),
                        Column(
                        children: [
                          Text(
                            "${userProvider.userPostsList.length}",
                            style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          const Text(
                            "posts",
                            style:
                            TextStyle(fontSize: 18, color: Colors.white),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${followersList.length}",
                            style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          const Text(
                            "followers",
                            style:
                            TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "${userProvider.userModel?.following.length}",
                            style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          const Text(
                            "following",
                            style:
                            TextStyle(fontSize: 18, color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? Colors.red : Colors.grey,
                      ),
                      onPressed: toggleFollowUser,
                      child:   Text(
                        isFollowing ? "Unfollow" : "Follow",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  Expanded(
                    child:
                    userProvider.isLoadingPosts ? const Center(
                      child: CircularProgressIndicator(),
                    ) :
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      crossAxisCount: 3,
                      children: List.generate(
                          userProvider.userPostsList.length, (index) {
                        return Image.network(
                          "${userProvider.userPostsList[index]["postImageUrl"]}",
                          fit: BoxFit.cover,);
                      }),
                    ),
                  ),
                ],
              ),
            );
          }
        )
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/screens/story_screen.dart';
import 'package:instgram_app/screens/user_story_screen.dart';
import 'package:provider/provider.dart';

import '../models/story_model.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import 'add_story_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    fetchStories();
    cleanupOldStories();
    // Schedule periodic cleanup every 24 hours
    Timer.periodic(const Duration(hours: 24), (timer) {
      cleanupOldStories();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.fetchUserData(userId: FirebaseAuth.instance.currentUser!.uid);
      userProvider.fetchUserPosts(userId: FirebaseAuth.instance.currentUser!.uid);
    });
  }
  List<Story> userStories = [];
  Future<void> fetchStories() async {
    try {
      // Get current user ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Query Firestore to fetch stories for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('instaAppStories')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Convert the query snapshot to a list of Story objects
      List<Story> stories = querySnapshot.docs.map((doc) {
        return Story.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        userStories = stories; // Store stories in the list
      });
    } catch (e) {
      print("Error fetching stories: $e");
      setState(() {
        userStories = []; // Handle error and set an empty list
      });
    }
  }

  Future<void> cleanupOldStories() async {
    print("object");
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final now = Timestamp.now();
    final cutoffTime = Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24)));

    try {
      // Fetch stories older than 2 minutes
      final querySnapshot = await _firestore.collection('instaAppStories')
          .where('timestamp', isLessThan: cutoffTime)
          .get();

      // Delete the old stories
      for (var doc in querySnapshot.docs) {
        await _firestore.collection('instaAppStories').doc(doc.id).delete();
      }

      print('Old stories deleted successfully.');
    } catch (e) {
      print('Error deleting old stories: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
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
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            InkWell(
                              onTap: (){
                                if (userStories.isNotEmpty) { // Check if there are stories
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserStoryScreen(stories: userStories),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage("${userProvider.userModel?.image}"
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: userStories.isNotEmpty
                                        ? Border.all(color: Colors.green, width: 3) // Green border if stories exist
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: IconButton(onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return const AddStoryScreen();
                                }));
                              },
                                  icon: const Icon(Icons.camera,size: 15,),),
                            ),
                          ],
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
                              "${userProvider.userModel?.followers.length}",
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
                      Text(
                      "${userProvider.userModel?.name}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.white),
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
                      ):
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        crossAxisCount: 3,
                        children: List.generate(userProvider.userPostsList.length, (index) {
                          return Image.network(
                              "${userProvider.userPostsList[index]["postImageUrl"]}",fit: BoxFit.cover,);
                        }),
                      ),
                    ),
                  ],
                ),
              );
  }
}

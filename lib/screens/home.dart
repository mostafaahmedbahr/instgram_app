import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/screens/login.dart';
import 'package:instgram_app/screens/story_screen.dart';
import 'package:instgram_app/widgets/post.dart';
import 'package:provider/provider.dart';

import '../models/story_model.dart';
import '../provider/post_provider.dart';
import '../provider/user_provider.dart';
import 'chats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signOut();
      // Successfully logged out
      print('User logged out');
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const LoginScreen();
      }));
      // You can navigate to the login screen or show a success message here
    } catch (e) {
      print('Error logging out: $e');
      // Show error message to user
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Story>> fetchStories() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('instaAppStories').get();
      List<Story> stories = querySnapshot.docs.map((doc) {
        return Story.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      return stories;
    } catch (e) {
      print("Error fetching stories: $e");
      return [];
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    fetchStories();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData(userId: FirebaseAuth.instance.currentUser!.uid.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: 10,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Instgram App",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ChatsScreen();
                    }));
                  }, icon: Icon(Icons.chat,color: Colors.white,)),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : IconButton(
                    onPressed: () {
                      logout();
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: h * 0.02,
          ),
          FutureBuilder<List<Story>>(
            future: fetchStories(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No stories available.'));
              }else{
                List<Story> stories = snapshot.data!;
                return  SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context ,index){
                      Story story = stories[index];
                      return InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return   StoryScreen(story: story,);
                          }));
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.red,
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: story.storyMediaUrl!.isNotEmpty
                                      ? NetworkImage(story.storyMediaUrl.toString())
                                      : const AssetImage('assets/placeholder_image.png') as ImageProvider, // Use a placeholder image
                                ),
                              ),
                              child: story.isVideo
                                  ? const Icon(Icons.play_arrow, color: Colors.white, size: 40) // Add a play icon for videos
                                  : null,
                            ),
                            const SizedBox(height: 5,),
                              Text(story.userName,style: const TextStyle(
                                color: Colors.white
                            ),),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context ,index){
                      return const SizedBox(width: 10,);
                    },
                    itemCount: stories.length,
                  ),
                );
              }
              }

          ),
          SizedBox(
            height: h * 0.02,
          ),
          Expanded(
            child:
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('instaAppPosts').snapshots(),
    builder: (context, snapshot) {
                return  Consumer<PostProvider>(builder: (context, postProvider, child) {
                  if (postProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No posts available.'));
                  }
                  final posts = snapshot.data!.docs.map((doc) {
                    return doc.data() as Map<String, dynamic>;
                  }).toList();
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostWidget(post: posts[index]);
                    },
                  );
                });
    }

                ),
          ),
        ],
      ),
    );
  }
}

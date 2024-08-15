import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/screens/login.dart';
import 'package:instgram_app/screens/story_screen.dart';
import 'package:instgram_app/widgets/post.dart';
import 'package:provider/provider.dart';

import '../provider/post_provider.dart';
import '../provider/user_provider.dart';

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
        return LoginScreen();
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


  @override
  void initState() {
    // TODO: implement initState
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
          SizedBox(
            height: h * 0.02,
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
                itemBuilder: (context ,index){
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return StoryScreen();
                      }));
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration:   BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Colors.red,
                            ),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage("https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740"),
                            )
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text("name",style: TextStyle(
                          color: Colors.white
                        ),),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context ,index){
                  return const SizedBox(width: 10,);
                },
                itemCount: 10,
            ),
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

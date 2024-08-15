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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    double h = MediaQuery
        .of(context)
        .size
        .height;
    double w = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back ,color: Colors.white,),),
        ),
        body: userProvider.isLoading
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
        )
    );
  }
}

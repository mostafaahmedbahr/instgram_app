import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage("${userProvider.userModel?.image}"
                         //   "https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740",
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "5",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
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
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
                              "follwers",
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
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Text(
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
                      style: TextStyle(
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
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        crossAxisCount: 3,
                        children: List.generate(5, (index) {
                          return Image.network(
                              "https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740");
                        }),
                      ),
                    ),
                  ],
                ),
              );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/screens/profile_screen_for_another_user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchCon = TextEditingController();
  String searchText = "";
  final focusNode = FocusNode();
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    searchCon.addListener(() {
      setState(() {
        searchText = searchCon.text.toLowerCase();
      });
    });
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }
  @override
  void dispose() {
    searchCon.dispose();
    focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            focusNode: focusNode,
            controller: searchCon,
            style: const TextStyle(color: Colors.white),
            validator: (value) {},
            decoration: const InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(
            height: h * 0.02,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('instaAppUsers').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final users = snapshot.data?.docs ?? [];
            final filteredUsers = users.where((user) {
              final userData = user.data() as Map<String, dynamic>;
              final userName = userData['name'] ?? '';
              final userId = userData['uid'] ?? '';
               return  userId != currentUserId && userName.toLowerCase().contains(searchText);
            }).toList();
            return
            Expanded(
              child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index].data() as Map<String, dynamic>;
                    final userName = user['name'] ?? 'No Name';
                    final userEmail = user['email'] ?? 'No Email';
                    final userImage = user['image'] ?? 'No Email';
                    final userId = user['uid'] ?? 'No Email';
                    return   InkWell(
                      onTap: (){
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return   ProfileScreenForAnotherUser(
                            uid: userId,
                          );
                        }));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(
                            userName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              userImage,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }
          ),
        ],
      ),
    );
  }
  bool get wantKeepAlive => true; // Required by AutomaticKeepAliveClientMixin
}

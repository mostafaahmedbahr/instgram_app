import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instgram_app/firebase/firebase_firestore.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier{

  // UserProvider() {
  //   fetchUserData();
  // }

  var uid = FirebaseAuth.instance.currentUser!.uid;
  UserModel? userModel;
  bool isLoading = false;

  Future<void> fetchUserData({required String userId}) async {
    isLoading = true;
    notifyListeners();

    try {
      // String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        userModel = await FirebaseFirestoreMethod().getUserDataFromFirebaseFirestore(userId);
        if (userModel != null) {
          print('User Name: ${userModel!.name}');
        }
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isLoadingPosts = false;
  List<dynamic> userPostsList =[];
  Future<void> fetchUserPosts({required String userId}) async {
    isLoadingPosts = true;
    notifyListeners();

    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      if (uid != null) {
          QuerySnapshot querySnapshot = await firestore.collection('instaAppPosts')
              .where('userUid', isEqualTo: userId).get();
          List<dynamic> posts = querySnapshot.docs.map((doc) => doc.data()).toList();
          userPostsList = posts;
      } else {
        print('User is not logged in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoadingPosts = false;
      notifyListeners();
    }
  }

  // Future<void> fetchUserPosts(String userId) async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //   QuerySnapshot querySnapshot = await firestore.collection('instaAppPosts')
  //       .where('userId', isEqualTo: userId).get();
  //
  //   for (var doc in querySnapshot.docs) {
  //     print(doc.id);
  //     print(doc.data());
  //     // Handle each post data
  //   }
  // }


}
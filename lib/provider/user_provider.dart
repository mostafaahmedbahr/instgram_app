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

  Future<void> fetchUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        userModel = await FirebaseFirestoreMethod().getUserDataFromFirebaseFirestore(uid);
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


}
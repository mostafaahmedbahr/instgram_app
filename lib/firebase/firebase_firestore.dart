import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class FirebaseFirestoreMethod{



  Future<UserModel?> getUserDataFromFirebaseFirestore(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('instaAppUsers').doc(uid).get();

      if (documentSnapshot.exists) {
        // Convert the document snapshot to a UserModel
        return UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        print('User does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram_app/models/user_model.dart';
import 'package:instgram_app/screens/bottom_nav_bar.dart';
import 'package:instgram_app/screens/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailCon = TextEditingController();
  final nameCon = TextEditingController();
  final passwordCon = TextEditingController();

  @override
  void dispose() {
    emailCon.dispose();
    nameCon.dispose();
    passwordCon.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  File? pickedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  Future<void> signUpWithEmailAndPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailCon.text.trim(),
        password: passwordCon.text.trim(),
      );
      // Successfully signed up
      print('User signed up: ${userCredential.user?.uid}');
      await storeUserDataInFirebaseFirestore(userCredential.user?.uid);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return BottomNavBarScreen();
      }));
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } catch (e) {
      print('Error signing up: $e');
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> storeUserDataInFirebaseFirestore(String? uid) async {
    if (uid == null) return;
    String imageUrl = '';
    if (pickedImage != null) {
      imageUrl = await uploadImageToStorage(uid);
    }
    UserModel userModel = UserModel(
      name: nameCon.text.trim(),
      email: emailCon.text.trim(),
      password: passwordCon.text.trim(),
      uid: uid,
      image: imageUrl,
      followers: [],
      following: [],
    );
    await FirebaseFirestore.instance.collection('instaAppUsers')
        .doc(uid).set(userModel.toMap());
  }

  Future<String> uploadImageToStorage(String uid) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('insta_app_user_images')
        .child('$uid.jpg');

    await ref.putFile(pickedImage!);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Instgram App",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: h * 0.1,
                ),
                Stack(
                  children: [
                    pickedImage != null
                        ? Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  pickedImage!,
                                  fit: BoxFit.cover,
                                )))
                        : const CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                              "https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740",
                            ),
                          ),
                    Positioned(
                      top: 60,
                      left: 60,
                      child: IconButton(
                        onPressed: () {
                          _pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: h * 0.05,
                ),
                Form(
                  key: formKey,
                  child: Column(children: [
                    TextFormField(
                      controller: nameCon,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please enter your name";
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "Name",
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
                    TextFormField(
                      controller: emailCon,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains("@")) {
                          return "please enter a valid email";
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "E-Mail",
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
                    TextFormField(
                      controller: passwordCon,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 8) {
                          return "please enter a valid password";
                        }
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.visibility,
                          color: Colors.white,
                        ),
                        hintText: "Password",
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
                      height: h * 0.05,
                    ),
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        :  SizedBox(
                      width: double.infinity,
                      height: h * 0.06,
                      child: ElevatedButton(
                        onPressed: () {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            signUpWithEmailAndPassword();
                          }
                        },
                        child: const Text("Sign Up"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                      },
                      child: const Text("Do you have an account ? "),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

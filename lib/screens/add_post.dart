import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? pickedImage;
  var commentCon = TextEditingController();
  bool _isLoading = false; // Add this variable to manage the loading state

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadPost() async {
    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    } else if (commentCon.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a comment')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true
    });

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('instaAppPosts/${DateTime.now().toIso8601String()}.jpg');

    try {
      await imageRef.putFile(pickedImage!);
      final imageUrl = await imageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('instaAppPosts').add({
        'userName': Provider.of<UserProvider>(context, listen: false).userModel?.name,
        'userUid': Provider.of<UserProvider>(context, listen: false).userModel?.uid,
        'userImage': Provider.of<UserProvider>(context, listen: false).userModel?.image,
        'postImageUrl': imageUrl,
        'postComment': commentCon.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        pickedImage = null;
        commentCon.clear();
        _isLoading = false; // Reset loading state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false; // Reset loading state on error
      });

      print('Error uploading post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload post.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    pickedImage = null;
                    commentCon.clear();
                    _isLoading = false; // Reset loading state
                  });
                },
                icon: const Icon(Icons.cancel),
              ),
              const Text(
                "New Post",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: _isLoading ? null : uploadPost, // Disable button when loading
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Next"),
              ),
            ],
          ),
          pickedImage != null
              ? InkWell(
            onTap: () {
              _pickImage(ImageSource.gallery);
            },
            child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.file(
                      pickedImage!,
                      fit: BoxFit.cover,
                    ))),
          )
              : Column(
            children: [
              SizedBox(
                height: h * 0.3,
              ),
              IconButton(
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
                icon: const Icon(
                  Icons.upload,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Upload Image",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: h * 0.03,
          ),
          TextFormField(
            controller: commentCon,
            maxLines: 10,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Add Comment !!",
              hintStyle: TextStyle(color: Colors.white),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

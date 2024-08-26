import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../models/story_model.dart';
import '../provider/user_provider.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  // @override
  // void initState() {
  //   _controller.initialize();
  //   super.initState();
  // }
  File? pickedImage;
  File? pickedVideo;
  var commentCon = TextEditingController();
  bool _isLoading = false;
  late VideoPlayerController _controller;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
        pickedVideo=null;
        // _controller.dispose();
        // _controller.pause();
      });
    }
  }
  Future<void> _pickVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        pickedVideo = File(pickedFile.path);
        pickedImage = null;
        _controller = VideoPlayerController.file(pickedVideo!);
        _controller.initialize();
        _controller.play();
      });
    }
  }

  Future<String> uploadFile(File file, bool isVideo) async {
    try {
      String fileType = isVideo ? 'videos' : 'images';
      String fileName = const Uuid().v4(); // Generate a unique ID for the file
      Reference storageRef = FirebaseStorage.instance.ref().child('stories/$fileType/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      throw e;
    }
  }

  Future<void> uploadStoryToCollection(Story story) async {
    try {
      CollectionReference stories = FirebaseFirestore.instance.collection('instaAppStories');

      // The story will be added to a field within the user's document.
      // The field can be an array of stories or a map with the storyId as the key.
      await stories.doc(story.storyId).set(story.toMap());

      print("Story uploaded successfully to a separate field");
    } catch (e) {
      print("Failed to upload story: $e");
      throw e;
    }
  }

  Future<void> uploadUserStory(File? mediaFile,
      String storyText, bool isVideo, String userId) async {
    if (mediaFile == null) {
      print("No media file selected.");
      return;
    }
    try {
      // Generate a unique story ID
      String storyId = const Uuid().v4();
      // Upload the media file (image or video) to Firebase Storage
      String mediaUrl = await uploadFile(mediaFile, isVideo);

      // Get the current timestamp
      DateTime timestamp = DateTime.now();

      // Create the Story object
      Story story = Story(
        storyId: storyId,
        storyText: storyText,
        storyMediaUrl: mediaUrl, // Use the media URL here
        userId: userId,
        timestamp: timestamp,
      );

      // Upload the story data to the instaAppStories collection
      await uploadStoryToCollection(story);
    } catch (e) {
      print("Error during story upload: $e");
    }
  }

  void handleStoryUpload() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    File? selectedMediaFile = pickedImage ?? pickedVideo;
    String storyText = commentCon.text;
    bool isVideo = pickedVideo != null;
    String? userId = Provider.of<UserProvider>(context, listen: false).userModel?.uid.toString();

    if (selectedMediaFile != null) {
      await uploadUserStory(selectedMediaFile, storyText, isVideo, userId!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Story uploaded successfully")));

      // Clear the form after a successful upload
      setState(() {
        pickedImage = null;
        pickedVideo = null;
        commentCon.clear();
        _isLoading = false; // Stop loading
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an image or video")));

      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },icon: const Icon(Icons.arrow_back ,color: Colors.white,),),
      ),
      body: Padding(
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
                  "New Story",
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: (){
                    handleStoryUpload();

                    //_isLoading ? null : uploadPost
                  }, // Disable button when loading
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text("Add"),
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu,color: Colors.white,),
              onSelected: (choice) {
                switch (choice) {
                  case "option1":
                    _pickVideo(ImageSource.gallery);
                  // Handle Option 1 selection
                    print('Option 1 selected');
                    break;
                  case "option2":
                    _pickImage(ImageSource.gallery);
                  // Handle Option 2 selection
                    print('Option 2 selected');
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: "option1",
                  child: Text('select video'),
                ),
                PopupMenuItem<String>(
                  value: "option2",
                  child: Text('select image '),
                ),
              ],

            ),
             pickedImage != null ?
                 InkWell(
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
            ) : pickedVideo != null ?
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: 100,
              child: VideoPlayer(_controller),
            ) : const Text(""),
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
      ),
    );
  }
}

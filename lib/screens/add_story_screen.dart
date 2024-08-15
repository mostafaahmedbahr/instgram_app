import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
                    //_isLoading ? null : uploadPost
                  }, // Disable button when loading
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text("Next"),
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.menu,color: Colors.white,),
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
              // controller: commentCon,
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

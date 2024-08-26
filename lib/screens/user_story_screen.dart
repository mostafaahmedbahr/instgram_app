import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/widgets/story_view.dart';

import '../models/story_model.dart';

class UserStoryScreen extends StatefulWidget {
    UserStoryScreen({super.key , required this.stories});
  List<Story> stories;

  @override
  State<UserStoryScreen> createState() => _UserStoryScreenState();
}

class _UserStoryScreenState extends State<UserStoryScreen> {
  var storyCon = StoryController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteStory(String storyId) async {
    try {
      await _firestore.collection('instaAppStories').doc(storyId).delete();
      print('Story deleted successfully.');
      setState(() {
        widget.stories.removeWhere((story) => story.storyId == storyId);
      });
      Navigator.of(context).pop(); // Optionally close the screen after deletion
    } catch (e) {
      print('Error deleting story: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting story: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<StoryItem> storyItems = widget.stories.map((story) {
      return
        story.isVideo
          ? StoryItem.pageVideo(
        story.storyMediaUrl.toString(),
        controller: storyCon,
      )
          : StoryItem.pageImage(
        url: story.storyMediaUrl.toString(),
        controller:storyCon,
      );
    }).toList();
    return  Scaffold(
      body: Stack(
        children: [
          StoryView(
            storyItems: storyItems,
            controller: storyCon,
            repeat: false,
            onComplete: () {
              Navigator.of(context).pop(); // Close the screen when story is complete
            },
          ),
          Positioned(
            top: 50,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 30,
              ),
              onPressed: (){
                if (widget.stories.isNotEmpty) {
                  deleteStory(widget.stories.first.storyId); // Pass the ID of the first story as an example
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

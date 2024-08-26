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
  @override
  Widget build(BuildContext context) {
    final List<StoryItem> storyItems = widget.stories.map((story) {
      return story.isVideo
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
      body: StoryView(
        storyItems: storyItems,
        controller: storyCon,
        repeat: false,
        onComplete: () {
          Navigator.of(context).pop(); // Close the screen when story is complete
        },
      ),
    );
  }
}

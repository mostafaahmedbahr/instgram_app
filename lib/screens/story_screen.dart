import 'package:flutter/material.dart';
import 'package:instgram_app/models/story_model.dart';
import 'package:story_view/story_view.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.story});
  final Story story;
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  var storyCon = StoryController();
  @override
  Widget build(BuildContext context) {
    print(widget.story.isVideo);
    final storyItem = widget.story.isVideo
        ? StoryItem.pageVideo(
      widget.story.storyMediaUrl.toString(),
      controller: storyCon,
      caption: Text(widget.story.storyText , style : const TextStyle(
          color: Colors.white)),
    )
        : StoryItem.pageImage(
      caption: Text(widget.story.storyText,style: const TextStyle(
        color: Colors.white
      ),),
      url: "${widget.story.storyMediaUrl}",
      controller: storyCon,
    );
    return   Scaffold(
      body: StoryView(
        storyItems: [storyItem],
        controller: storyCon,
        repeat: false,
        onComplete: () {
          Navigator.of(context).pop(); // Close the screen when story is complete
        },
      ),
    );
  }
}

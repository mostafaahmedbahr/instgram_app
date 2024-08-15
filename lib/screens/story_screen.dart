import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  var storyCon = StoryController();
  @override
  Widget build(BuildContext context) {
    return   StoryView(
        storyItems: [
          StoryItem.pageImage(
              url: "https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740",
              controller: storyCon
          ),
          // StoryItem.pageVideo(url, controller: controller),
        ],
        controller: storyCon,
        repeat: false,
        onComplete: (){},
    );
  }
}

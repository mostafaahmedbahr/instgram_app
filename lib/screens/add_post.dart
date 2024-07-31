import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cancel),
            ),
            const Text(
              "New Post",
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Next"),
            ),
          ],
        ),
        SizedBox(
          height: h * 0.3,
        ),
        Column(
          children: [
            IconButton(
              onPressed: () {},
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
          maxLines: 10,
          style: TextStyle(color: Colors.white),
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
      ]),
    );
  }
}

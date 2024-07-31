import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                  "https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740",
                ),
              ),
              Column(
                children: [
                  Text(
                    "5",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "posts",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    "10",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "follwers",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "14",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "following",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: h * 0.01,
          ),
          const Text(
            "Name",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              onPressed: () {},
              child: const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: h * 0.01,
          ),
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 3,
              children: List.generate(5, (index) {
                return Image.network(
                    "https://img.freepik.com/free-photo/international-day-education-celebration_23-2150931022.jpg?t=st=1721128291~exp=1721131891~hmac=be6b799ae01a499e56028121b8d0fa57b2db43b5850175c4ab1f9c1c606b11dc&w=740");
              }),
            ),
          ),
        ],
      ),
    );
  }
}

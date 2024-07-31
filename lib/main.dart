import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instgram_app/screens/bottom_nav_bar.dart';
import 'package:instgram_app/screens/login.dart';
import 'package:instgram_app/screens/sign_up.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Instgram App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SignUpScreen(),
    );
  }
}

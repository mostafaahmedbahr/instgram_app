import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bottom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  Future<void> loginWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Successfully logged in
      print('User logged in: ${userCredential.user?.uid}');
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return BottomNavBarScreen();
      }));
      // You can navigate to another screen or show a success message here
    } catch (e) {
      print('Error logging in: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const Text(
                  "Instgram App",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: h * 0.1,
                ),
                Form(
                  key: formKey,
                  child: Column(children: [
                    TextFormField(
                      controller : _emailController,
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains("@")) {
                          return "please enter a valid email";
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "E-Mail",
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    TextFormField(
                      controller : _passwordController,
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 8) {
                          return "please enter a valid password";
                        }
                      },
                      decoration: const InputDecoration(
                        suffixIcon: Icon(
                          Icons.visibility,
                          color: Colors.white,
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: h * 0.05,
                    ),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      height: h * 0.06,
                      child: ElevatedButton(
                        onPressed: () {
                          loginWithEmailAndPassword();
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Create new account ! "),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

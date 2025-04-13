import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: 20),
          Container(
              width: 340,
              child: Text('Hello! Register to get \nstarted',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))),
          SizedBox(height: 20),
          SizedBox(
            width: 340,
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                hintText: 'Username',
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 340,
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                hintText: 'Email',
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 340,
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                hintText: 'Password',
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 340,
            height: 50,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2.0),
                ),
                hintText: 'Confirm Password',
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  spreadRadius: 0, // Spread radius
                  blurRadius: 10, // Blur radius
                  offset: Offset(0, 2), // Offset for the shadow
                ),
              ],
            ),
            width: 300,
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Background color
                  // Text color
                ),
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
          ),
          SizedBox(height: 60),
          Text(
            "Or Register with",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 30),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the icons
              children: [
                SizedBox(width: 10),
                IconButton(
                  icon: Image.asset(
                    'assets/fblogo.webp',
                    width: 35, // Set width for the icon
                    height: 35, // Set height for the icon
                  ),
                  onPressed: () {
                    // Add your Google action here
                  },
                ),
                SizedBox(width: 80), // Space between icons
                IconButton(
                  icon: Image.asset(
                    'assets/google_logo.webp',
                    width: 45, // Set width for the icon
                    height: 45, // Set height for the icon
                  ),
                  onPressed: () {
                    // Add your LinkedIn action here
                  },
                ),
                SizedBox(width: 65),
                IconButton(
                  icon: Image.asset(
                    'assets/apple3.webp',
                    width: 53, // Set width for the icon
                    height: 53, // Set height for the icon
                  ),
                  onPressed: () {
                    // Add your LinkedIn action here
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 60),
          Row(
            children: [
              SizedBox(width: 50),
              Text(
                "Don't have an account?",
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
              TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/signup');
                    context.go('/signup');
                  },
                  child: Text("Register now",
                      style: TextStyle(color: Colors.green)))
            ],
          )
        ],
      )),
    );
  }
}

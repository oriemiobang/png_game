import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:png_game/firebase_service/auth.dart';
import 'package:png_game/main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String capitalize(String str) {
    // Split the string into words
    List<String> words = str.split(' ');

    // Capitalize the first character of each word
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    // Join the words back into a string
    return words.join(' ');
  }

  void alert(message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity,
            child: AlertDialog(
              title: const Text('Could not register!'),
              content: Text('$message'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            ),
          );
        });
  }

  String password = '';
  String userName = '';
  String email = '';
  String rePassword = '';
  bool matching = false;
  bool loading = false;
  String error = '';

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
          SizedBox(
              width: 340,
              child: Text('Hello! Register to get \nstarted',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  width: 340,
                  height: 50,
                  child: TextFormField(
                    onChanged: (val) {
                      setState(() {
                        userName = val;
                      });
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Your name is required' : null,
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
                  child: TextFormField(
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                    validator: (value) =>
                        value!.isEmpty ? 'Email is required' : null,
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
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 4) {
                        return 'Password should be at least 4 characters';
                      }
                      if (matching) {
                        setState(() {
                          matching =
                              false; // Set matching to false when passwords don't match
                        });
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    obscureText: true,
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
                  child: TextFormField(
                    obscureText: true,
                    onChanged: (val) {
                      setState(() {
                        rePassword = val;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 4) {
                        return 'Password should be at least 4 characters';
                      }
                      if (matching) {
                        setState(() {
                          matching =
                              false; // Set matching to false when passwords don't match
                        });
                        return 'Passwords do not match';
                      }
                      return null;
                    },
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
                    onPressed: () async {

                      
                      if (_formKey.currentState!.validate()) {
                        print('register clicked once');
                        if (rePassword.trim() != password.trim()) {

                          print('register clicked');
                          setState(() {
                            error = 'Passwords do not match';
                            matching = true;
                          });
                        }else {
                        setState(() {
                          loading = true;
                        });

                        String capitalizedName = capitalize(userName);
                        String trimPassword = password.trim();
                        String trimEmail = email.trim();

                        dynamic result =
                            await _auth.registerWithEmailAndPassword(
                                email: trimEmail,
                                password: trimPassword,
                                name: capitalizedName);
                        if (result == null) {
                          print('fail to register');
                          setState(() {
                            error =
                                'Please make sure your email is valid and your internet connection is stable.';
                            loading = false;
                          });

                          alert(error);
                        }
                      } 
                      } 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Background color
                      // Text color
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 60),

          Text(error, style: TextStyle(color: Colors.red),),
          Text(
            "Or Register with",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 30),
          SizedBox(
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

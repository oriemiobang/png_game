import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:png_game/screens/loading.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:ionicons/ionicons.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String capitalize(String str) {
    List<String> words = str.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => loading = true);
    final authApi = context.read<AuthApiService>();
    final result = await authApi.signInWithGoogle();
    
    if (result != null && result is! String) {
      Fluttertoast.showToast(msg: "Signed in with Google successfully");
      if (mounted) {
        context.read<SocketService>().connect();
        context.go('/');
      }
    } else {
      setState(() {
        error = result is String ? result : 'Google Sign In failed.';
        loading = false;
      });
      alert(error);
    }
  }

  String password = '';
  String userName = '';
  String email = '';
  String rePassword = '';
  bool matching = false;
  bool loading = false;
  String error = '';
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authApi = context.read<AuthApiService>();

    return loading ? const Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(height: 20),
          const SizedBox(
              width: 340,
              child: Text('Hello! Register to get \nstarted',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
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
                    decoration: const InputDecoration(
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
                const SizedBox(height: 10),
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
                    decoration: const InputDecoration(
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
                const SizedBox(height: 10),
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
                          matching = false;
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
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black54),
                        onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 340,
                  height: 50,
                  child: TextFormField(
                    obscureText: !isPasswordVisible,
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
                          matching = false;
                        });
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
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
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 0, // Spread radius
                        blurRadius: 10, // Blur radius
                        offset: const Offset(0, 2), // Offset for the shadow
                      ),
                    ],
                  ),
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (rePassword.trim() != password.trim()) {
                          setState(() {
                            error = 'Passwords do not match';
                            matching = true;
                          });
                        } else {
                          setState(() {
                            loading = true;
                          });

                          String capitalizedName = capitalize(userName);
                          String trimPassword = password.trim();
                          String trimEmail = email.trim();

                          dynamic result = await authApi.registerWithEmailAndPassword(
                                  email: trimEmail,
                                  password: trimPassword,
                                  name: capitalizedName);
                                  
                          if (result == null || result is String) {
                            setState(() {
                              error = result is String ? result : 'Please make sure your email is valid and your internet connection is stable.';
                              loading = false;
                            });
                            alert(error);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Signed up successfully",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                            );
                            if (mounted) {
                              context.read<SocketService>().connect();
                              context.go('/');
                            }
                          }
                        } 
                      } 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),

          Text(error, style: const TextStyle(color: Colors.red),),
          const Text(
            "Or Register with",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the icons
            children: [
              IconButton(
                icon: const Icon(Ionicons.logo_google, size: 40, color: Colors.red),
                onPressed: _handleGoogleSignIn,
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            children: [
              const SizedBox(width: 50),
              const Text(
                "Already have an account?",
                style: TextStyle(fontSize: 17, color: Colors.grey),
              ),
              TextButton(
                  onPressed: () {
                    context.go('/signin');
                  },
                  child: const Text("Sign in now",
                      style: TextStyle(color: Colors.green)))
            ],
          )
        ],
      )),
    );
  }
}

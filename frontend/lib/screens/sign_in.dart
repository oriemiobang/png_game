import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:png_game/screens/loading.dart';
import 'package:ionicons/ionicons.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  void alert(message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity,
            child: AlertDialog(
              title: const Text('Could not sign in!'),
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
      if (mounted) context.go('/');
    } else {
      setState(() {
        error = result is String ? result : 'Google Sign In failed.';
        loading = false;
      });
      alert(error);
    }
  }

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
                child: Text('Welcome back! Glad \nto see you. Again!',
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
                  hintText: 'Enter your Email',
                ),
              ),
            ),
                    
            const SizedBox(height: 15),
            SizedBox(
              width: 340,
              height: 50,
              child: TextFormField(
                      obscureText: !isPasswordVisible,
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                                validator: (value) => value!.length < 4
                                    ? 'password should be at least 4 digit'
                                    : null,
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
                  hintText: 'Enter your Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible =
                            !isPasswordVisible; // Toggle visibility
                      });
                    },
                  ),
                ),
              ),
            ),
              ],
            ),),
  
            Row(
              children: [
                const SizedBox(width: 220),
                TextButton(
                    onPressed: () {
                      context.go('/forgotpassword');
                    },
                    child: const Text('Forget Password ?',
                        style: TextStyle(color: Colors.black)))
              ],
            ),
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
                  onPressed: ()  async{
                    if(_formKey.currentState!.validate()){
  
                      setState(() {
                        loading = true;
                      });
  
                      String trimPassword = password.trim();
                      String trimEmail = email.trim();
                      
                      dynamic result = await authApi.signInWithEmailAndPassword(trimEmail, trimPassword);
                      
                      if (result == null || result is String) {
                        setState(() {
                          error = result is String ? result : 'This could be because of wrong email or password, or unstable internet connection, please check and try again.';
                          loading = false;
                        });
                        alert(error);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Signed in successfully",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                        );
                        if (mounted) context.go('/');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    // Text color
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),),
            ),
            const SizedBox(height: 60),
            const Text(
              "Or Login with",
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
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 50),
                const Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
                TextButton(
                    onPressed: () {
                      context.go('/signup');
                    },
                    child: const Text("Register now",
                        style: TextStyle(color: Colors.green)))
              ],
            )
          ],
        ),
      ),
    );
  }
}

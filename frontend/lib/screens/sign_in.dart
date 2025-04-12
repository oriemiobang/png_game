import 'package:flutter/material.dart';
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}
class _SignInState extends State<SignIn> {
  bool isPasswordVisible = false;
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: 
      
        Column(
          children: [
            SizedBox(height:30),
            const Text('Welcome back Glad \nto see you. Again!', style: TextStyle(fontSize: 24, color:Colors.black, fontWeight: FontWeight.bold)),
            SizedBox(height:20),
            SizedBox(
              width : 300,
              child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 0.4),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
                      hintText: 'Enter your Email',
                    ),
                  ),
            ),
     SizedBox(
  width: 300,
  child: TextField(
    cursorColor: Colors.black54,
    obscureText: !isPasswordVisible, // Show password when true
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 0.4),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
      hintText: "Enter Password",
      hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
      contentPadding: EdgeInsets.only(top: 20.0, left: 0.0, bottom: 0.0),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.black54,
        ),
        onPressed: () {
          setState(() {
            isPasswordVisible = !isPasswordVisible; // Toggle visibility
          });
        },
      ),
    ),
  ),
),
Row(children: [
  SizedBox(width: 70),
  TextButton(onPressed:(){}, 
  child: Text('forgot Password?', style: TextStyle(color:Colors.black)))
],)

          ],
        ),
      
    );
}
}
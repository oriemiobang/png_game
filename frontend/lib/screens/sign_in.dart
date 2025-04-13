import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}
class _SignInState extends State<SignIn> {
  bool isPasswordVisible = false;
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: 
      
        Column(
          
          children: [
            SizedBox(height:20),
            Container(
              width:340,
              child: Text('Welcome back! Glad \nto see you. Again!',
              textAlign: TextAlign.start, style: TextStyle(fontSize: 24, color:Colors.black, fontWeight: FontWeight.bold))),
            SizedBox(height:20),
            SizedBox(
              width : 340,
              height:50,
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
                      hintText: 'Enter your Email',
                    ),
                  ),
            ),
            SizedBox(height:15),
     SizedBox(
              width : 340,
              height:50,
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
                      hintText: 'Enter your Password',
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
  SizedBox(width: 220),
  TextButton(onPressed:(){}, 
  child: Text('Forget Password ?', style: TextStyle(color:Colors.black)))
],),
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
  width:300,
   child: ElevatedButton(onPressed: (){}, 
   style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,  // Background color
    // Text color
  ),
   child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16),)),
 ),
 SizedBox(height:60),
  Text("Or Login with",style: TextStyle(color: Colors.black, fontSize: 16),),
  SizedBox(height:30),
  Container(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center, // Center the icons
    children: [
      SizedBox(width:10),
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
      SizedBox(width:65),
      IconButton(
        icon: Image.asset(
          'assets/apple3.webp',
          width: 53, // Set width for the icon
          height:53, // Set height for the icon
        ),
        onPressed: () {
          // Add your LinkedIn action here
        },
      ),
    ],
  ),
),
  
  SizedBox(height:160),
  Row(children: [
    SizedBox(width:50),
    Text("Don't have an account?", style: TextStyle(fontSize:17, color:Colors.grey),),
    
    TextButton(onPressed: (){
      Navigator.pushNamed(context, '/signup');
    },
    child: Text("Register now", style:TextStyle(color:Colors.green)))
  ],)
  
          ],
        ),
      
    );
}
}
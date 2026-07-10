import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:png_game/screens/loading.dart';
import 'package:png_game/services/socket_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final authApi = context.read<AuthApiService>();

    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: const Color(0xFFF4F4F4),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Container(
                    width: 380,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Welcome back.\nReady to play?',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                            validator: (value) =>
                                value!.isEmpty ? 'Email is required' : null,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF1A1A1A)),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: const Icon(Icons.mail_outline,
                                  color: Color(0xFF999999), size: 20),
                              hintText: 'name@example.com',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF999999), fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDDDDDD), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF111111), width: 1),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            obscureText: !isPasswordVisible,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                            validator: (value) => value!.length < 4
                                ? 'Password should be at least 4 digits'
                                : null,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF1A1A1A)),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Color(0xFF999999), size: 20),
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(
                                  color: Color(0xFF999999), fontSize: 14),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFDDDDDD), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF111111), width: 1),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF999999),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 20),
                              child: InkWell(
                                onTap: () {
                                  context.go('/forgotpassword');
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      color: Color(0xFF1A1A1A), fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    loading = true;
                                  });

                                  String trimPassword = password.trim();
                                  String trimEmail = email.trim();

                                  dynamic result = await authApi
                                      .signInWithEmailAndPassword(
                                          trimEmail, trimPassword);

                                  if (result == null || result is String) {
                                    setState(() {
                                      error = result is String
                                          ? result
                                          : 'This could be because of wrong email or password, or unstable internet connection, please check and try again.';
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
                                    if (mounted) {
                                      context.read<SocketService>().connect();
                                      context.go('/');
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: const Color(0xFFEAEAEA))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                      color: Color(0xFF999999), fontSize: 12),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: const Color(0xFFEAEAEA))),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _handleGoogleSignIn,
                              icon: const Icon(Ionicons.logo_google,
                                  size: 18, color: Color(0xFFEA4335)),
                              label: const Text(
                                'Google',
                                style: TextStyle(
                                    color: Color(0xFF1A1A1A), fontSize: 14),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Color(0xFFDDDDDD), width: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'New to PNG? ',
                                  style: TextStyle(
                                      color: Color(0xFF666666), fontSize: 13),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.go('/signup');
                                  },
                                  child: const Text(
                                    'Create an account',
                                    style: TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

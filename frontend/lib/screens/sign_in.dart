import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:png_game/services/auth_api_service.dart';
import 'package:png_game/screens/loading.dart';
import 'package:png_game/services/socket_service.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 40.0),
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
                            padding: const EdgeInsets.only(top: 12, bottom: 20),
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
                                    height: 1, color: const Color(0xFFEAEAEA))),
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
                                    height: 1, color: const Color(0xFFEAEAEA))),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _handleGoogleSignIn,
                            icon: SvgPicture.string(
                              '<svg width="18" height="18" viewBox="0 0 18 18"><path fill="#4285F4" d="M17.64 9.2c0-.64-.06-1.25-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.9c1.7-1.57 2.7-3.88 2.7-6.62z"/><path fill="#34A853" d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.9-2.26c-.8.54-1.84.86-3.06.86-2.35 0-4.34-1.59-5.05-3.72H.96v2.33A9 9 0 0 0 9 18z"/><path fill="#FBBC05" d="M3.95 10.7A5.4 5.4 0 0 1 3.66 9c0-.59.1-1.17.29-1.7V4.97H.96A9 9 0 0 0 0 9c0 1.45.35 2.83.96 4.03l2.99-2.33z"/><path fill="#EA4335" d="M9 3.58c1.32 0 2.51.46 3.44 1.35l2.58-2.58C13.46.89 11.43 0 9 0A9 9 0 0 0 .96 4.97l2.99 2.33C4.66 5.17 6.65 3.58 9 3.58z"/></svg>',
                              width: 18,
                              height: 18,
                            ),
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
          );
  }
}

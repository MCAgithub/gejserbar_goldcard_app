// ignore_for_file: constant_identifier_names, prefer_const_constructors

// ignore: unused_import, avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: unused_import
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gejserbar_guldkort_app/main.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetPasswordController = TextEditingController();
  bool isChecked = false;

  var emailHelperText = '';
  var passwordHelperText = '';
  var resetpasswordHelperText = '';

  var emailHintColor = textcolor;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 120,
            backgroundColor: app_backgroundcolor,
            child: Image.asset('asset/images/gejserbarlogo.jpg'),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: 400,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: '',
                  helperText: emailHelperText,
                  helperStyle: TextStyle(color: Colors.red),
                  //hintStyle: TextStyle(color: emailHintColor)
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: 400,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: '',
                  helperText: passwordHelperText,
                  helperStyle: TextStyle(color: Colors.red),
                  //hintStyle: TextStyle(hintStyle: )
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              forgotPasswordDialog(context);
            },
            child: Text('Forgot password'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  }),
              Text('GDPR guidelines Terms'),
              /*InkWell(
                  child: Text(
                    'Terms',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  onTap: () async {
                    const stringUrl = 'https://www.google.com/';
                    // ignore: unused_local_variable
                    final Uri url = Uri.parse(stringUrl);
                    try {
                      await launchUrl(url, mode: LaunchMode.platformDefault);
                      //html.window.open(stringUrl, 'Terms and conditions');
                    } catch (e) {
                      print(e);
                    }
                  })*/
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
            onPressed: () {
              if (isChecked == true) {
                signIn();
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: app_backgroundcolor,
                        title: Text(
                          'Consent missing',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        content: Text(
                            'To use this app you must accept the Terms and Conditionens outlined in the link above.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Ok')),
                        ],
                      );
                    });
              }
            },
            child: Text(
              'Login',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> forgotPasswordDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: app_backgroundcolor,
            title: Text(
              'Reset Password',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            content: StatefulBuilder(builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                      controller: resetPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        helperText: resetpasswordHelperText,
                      )),
                ],
              );
            }),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Send Reset Password email',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  resetPassword();
                },
              ),
              TextButton(
                child: Text(
                  'Close',
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future resetPassword() async {
    setState(() {
      resetpasswordHelperText = '';
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: resetPasswordController.text.trim());
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: const Text(
                  'Reset Email Sent!\nCheck your mailbox and beaware that the email will be coming from\nnoreply@gejserbar.firebaseapp.com'),
            );
          });
    } on FirebaseAuthException catch (e) {
      setState(() {
        resetpasswordHelperText = '';
      });
      // ignore: avoid_print
      print(e.code);
      if (e.code == "missing-email") {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Please write your email'),
              );
            });
      }
      if (e.code == "invalid-email") {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Please write your email'),
              );
            });
      }
    }
  }

  Future signIn() async {
    // Displays loading circle - seams clunky
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        emailHelperText = '';
        passwordHelperText = '';
      });
      // ignore: avoid_print
      print(e.code);
      if (e.code == "invalid-email") {
        setState(() {
          emailHelperText = 'That user does not exist';
        });
      }
      if (e.code == "missing-password") {
        setState(() {
          passwordHelperText = 'please type your password';
        });
      }
      if (e.code == "invalid-login-credentials") {
        setState(() {
          passwordHelperText = 'wrong password';
        });
      }
      if (e.code == "too-many-requests") {
        setState(() {
          emailHelperText = 'Too many login attempts, try again in 60 seconds';
        });
      }
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

// ignore_for_file: constant_identifier_names, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:gejserbar_guldkort_app/admin_page.dart';

import 'goldcardholder_page.dart';
import 'login_widget.dart';

const app_backgroundcolor = Colors.black;
const highlightcolor = Colors.black;
const textcolor = Colors.white;
const goldcardcolor = Color.fromARGB(255, 195, 160, 92);
const mainred = Color.fromARGB(255, 146, 61, 93);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyCMhdeiXGwQ9cvb5Pzv2rPo_SLnrY0Z60c',
          appId: '1:104355812109:web:0dcef6223028a51cf29644',
          messagingSenderId: '104355812109',
          projectId: 'gejserbar',
          storageBucket: 'gejserbar.appspot.com'));
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: app_backgroundcolor,
        colorScheme: ColorScheme.fromSeed(seedColor: highlightcolor),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
        ).apply(
          bodyColor: textcolor,
          displayColor: textcolor,
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final testing = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error'));
          } else if (snapshot.hasData) {
            if (snapshot.data?.email == 'admin@test.dk') {
              return AdminPage();
            } else {
              return GoldCardHolderPage();
            }
          } else {
            return LoginWidget();
          }
        },
      ),
    );
  }
}
// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';



import 'main.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  final storage = FirebaseStorage.instance;
  // ignore: prefer_typing_uninitialized_variables
  var imageUrl;

  @override
  void initState(){
    super.initState();
    imageUrl='';
    getImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      backgroundColor: goldcardcolor,
      appBar: AppBar(
        title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.email!,
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                signOut();
              },
              child: Text(
                'Log out',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          ],
        )),
        backgroundColor: goldcardcolor,
        titleTextStyle: const TextStyle(fontSize: 20, color: textcolor),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [//Image.asset('asset/images/Guldkort.jpg',)
                  //Image.network(imageUrl),
          Card(clipBehavior : Clip.hardEdge, child: Image(image: NetworkImage(imageUrl),fit: BoxFit.cover,))

        ],
        ),
      ),
    );
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> getImageUrl() async {
    final ref = storage.ref().child('Guldkort.jpg');
    
    final url = await ref.getDownloadURL();
    setState(() {
      imageUrl = url;
    });
  }
}

// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:gejserbar_guldkort_app/database_classes/db_firebase_functions.dart';

import 'main.dart';

class GoldCardHolderPage extends StatefulWidget {
  const GoldCardHolderPage({super.key});

  @override
  State<GoldCardHolderPage> createState() => _GoldCardHolderPage();
}

class _GoldCardHolderPage extends State<GoldCardHolderPage> {
  String? discount;
  String? discountTime;

  @override
  void initState() {
    super.initState();
    //discount = '25';
    //discountTime = '22:00';
    fetchDiscountInfo();
  }

  Future fetchDiscountInfo() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .doc('Discount')
        .get();
    discount = snapshot.data()?['discount amount'];
    discountTime = snapshot.data()?['discount time'];
    setState(() {
      // updates the string to show the fetched values
    });
  }

  String formatDate(int timestamp) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return "$day-$month-$year";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: DatabaseFirebasefunctions.getGoldUser(user.email),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Database Error $snapshot');
        } else if (snapshot.hasData) {
          final goldUsers = snapshot.data![0];
          //print(goldUsers.expirationdate);
          //print(DateTime.fromMicrosecondsSinceEpoch(goldUsers.expirationdate).year);
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FilledButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
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
              backgroundColor: Colors.transparent,
              titleTextStyle: const TextStyle(fontSize: 20, color: textcolor),
            ),
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      //border: Border.all(color: Colors.blueAccent),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          //image: AssetImage('asset/images/Guldkort_noexpdate_640x1136.jpg'))),
                          image: AssetImage('asset/images/wood.png'))),
                ),
                Center(
                  child: Container(
                    height: 480,
                    width: 325,
                    foregroundDecoration: const BoxDecoration(
                        //border: Border.all(color: Colors.blueAccent),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            //image: AssetImage('asset/images/Guldkort_noexpdate_640x1136.jpg'))),
                            image: AssetImage(
                                'asset/images/goldplateblackbgwithtextnobackground.png'))),
                  ),
                ),
                const Center(
                  child: SizedBox(
                    height: 465,
                    width: 325,
                    child: AnimatedBorderComponent(),
                  ),
                ),

                // orginal fit height : 480, width 350, in a center widget

                //const Positioned(top: 173,right: 87,child: AnimatedBorderComponent(height: 480, width: 335,)),
                Center(
                  child: SizedBox(
                    height: 465,
                    width: 325,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text('$discount% OFF ALL DRINKS UNTIL $discountTime'),
                        const SizedBox(
                          height: 320,
                        ),
                        Column(
                          children: [
                            Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 40,
                                ),
                                const SizedBox(
                                    child: Text(
                                  'Card Holder:',
                                )),
                                const SizedBox(
                                  width: 65,
                                ),
                                SizedBox(
                                    //width: 150,
                                    child: Text(
                                  goldUsers.name.length > 14
                                      ? goldUsers.name.split(' ').join('\n')
                                      : goldUsers.name,
                                )),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 40,
                                ),
                                const SizedBox(child: Text('Expiration Date:')),
                                const SizedBox(
                                  width: 39,
                                ),
                                SizedBox(
                                    //width: 150,
                                    child: Text(
                                        formatDate(goldUsers.expirationdate))
                                    //SizedBox(width: 150, child: Text(goldUsers.expirationdate.toString())),
                                    ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: user.email == 'admin@test.dk'
                ? FloatingActionButton.extended(
                    label: const Text('Preview'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                : null,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
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
}

class AnimatedBorderComponent extends StatefulWidget {
  final Widget? child;

  const AnimatedBorderComponent({
    super.key,
    this.child,
  });

  @override
  State<AnimatedBorderComponent> createState() {
    return _AnimatedBorderComponentState();
  }
}

class _AnimatedBorderComponentState extends State<AnimatedBorderComponent> {
  int index = 0;
  List<Color> colors = [Colors.black, const Color(0x00ffd700)];
  Duration duration = const Duration(milliseconds: 1000);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          index = (index + 1) % colors.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: Border.all(
            color: colors[index], style: BorderStyle.solid, width: 4),
        borderRadius: BorderRadius.circular(35),
      ),
      child: widget.child,
    );
  }
}

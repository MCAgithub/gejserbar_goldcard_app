// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gejserbar_guldkort_app/database_classes/db_firebase_functions.dart';
import 'package:gejserbar_guldkort_app/database_classes/db_user.dart';
import 'package:gejserbar_guldkort_app/goldcardholder_page.dart';

import 'main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPage();
}

class _AdminPage extends State<AdminPage> with TickerProviderStateMixin {
  // page 1
  final _formKey = GlobalKey<FormState>();
  var newGoldUserName = TextEditingController();
  var newGoldUserEmail = TextEditingController();
  var newGoldUserPassword = TextEditingController();
  var newGoldUserExpirationDateText = TextEditingController();
  var newGoldUserExpirationDate = 0;

  var newGoldUserNameHelperText = '';
  var newGoldUserEmailHelperText = '';
  var newGoldUserPasswordText = '';
  var newGoldUserExpirationDateHelperText = '';

  // page 2
  final _editGoldUser = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpened = false;
  var editGoldUserExpirationDateText = TextEditingController();
  var editGoldUserExpirationDate = 0;

  late GoldUser? _selectedGoldCardHolder;

  var editGoldUserHelperText = '';
  var editGoldUserExpirationDateHelperText = '';

  // page 3
  var discountController = TextEditingController();
  var discountdateController = TextEditingController();

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchDiscountInfo();
  }

  Future fetchDiscountInfo() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .doc('Discount')
        .get();
    discountController.text = snapshot.data()?['discount amount'];
    discountdateController.text = snapshot.data()?['discount time'];
  }

  @override
  Widget build(BuildContext context) {
    //final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: DatabaseFirebasefunctions.getGoldUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Database Error $snapshot');
          } else if (snapshot.hasData) {
            List<GoldUser> goldlist = snapshot.data!;
            var filteredItems = _editGoldUser.text.isEmpty
                ? goldlist
                : goldlist
                    .where((item) => item.email
                        .toLowerCase()
                        .contains(_editGoldUser.text.toLowerCase()))
                    .toList();
            return GestureDetector(
              onTap: () {
                if (_isDropdownOpened) {
                  setState(() {
                    _isDropdownOpened = false;
                    _focusNode.unfocus();
                  });
                }
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  title: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(width: 1, color: mainred)),
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
                  titleTextStyle:
                      const TextStyle(fontSize: 20, color: textcolor),
                ),
                body: Column(
                  children: [
                    TabBar(controller: tabController,tabs: const [
                      Text(
                        'New \n Gold Card Holder',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Edit \n Gold Card Holder',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Discount Info',
                        textAlign: TextAlign.center,
                      ),
                    ]),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.5,
                      width: MediaQuery.of(context).size.width,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          // page 1
                          Form(
                            key: _formKey,
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Create New Gold Card Holder',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MyTextFormField(
                                  controller: newGoldUserName,
                                  helpertext: newGoldUserNameHelperText,
                                  labelText: 'Name',
                                  width: 400,
                                  tapped: () {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                                MyTextFormField(
                                  controller: newGoldUserEmail,
                                  helpertext: newGoldUserEmailHelperText,
                                  labelText: 'Email',
                                  width: 400,
                                  tapped: () {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    } else if (RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value) ==
                                        false) {
                                      return 'Not a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                MyTextFormField(
                                  controller: newGoldUserPassword,
                                  helpertext: newGoldUserPasswordText,
                                  labelText: 'Password',
                                  width: 400,
                                  tapped: () {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                                MyTextFormField(
                                  controller: newGoldUserExpirationDateText,
                                  helpertext:
                                      newGoldUserExpirationDateHelperText,
                                  labelText: 'Expiration Date',
                                  width: 400,
                                  tapped: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(
                                                DateTime.now().year - 5),
                                            lastDate: DateTime(
                                                DateTime.now().year + 5))
                                        .then((pickeddate) {
                                      if (pickeddate != null) {
                                        var day = pickeddate.day.toString();
                                        if (day.length == 1) {
                                          day = '0$day';
                                        }
                                        var month = pickeddate.month.toString();
                                        if (month.length == 1) {
                                          month = '0$month';
                                        }
                                        newGoldUserExpirationDateText.text =
                                            '$day/$month/${pickeddate.year}';
                                        newGoldUserExpirationDate =
                                            pickeddate.microsecondsSinceEpoch;
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                                submitButton(context),
                              ],
                            ),
                          ),
                          // page 2
                          SizedBox(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Edit Gold Card Holder',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MyTextFormField(
                                  controller: _editGoldUser,
                                  focusnode: _focusNode,
                                  helpertext: editGoldUserHelperText,
                                  labelText: 'Gold Card Holder Email',
                                  width: 400,
                                  tapped: () {
                                    setState(() {
                                      _isDropdownOpened = true;
                                    });
                                  },
                                  changed: (value) {
                                    setState(() {});
                                  },
                                ),
                                IgnorePointer(
                                  ignoring: !_isDropdownOpened,
                                  child: Visibility(
                                    visible: _isDropdownOpened,
                                    child: Material(
                                      elevation: 10,
                                      child: SizedBox(
                                        height: 200,
                                        width: 400,
                                        child: ListView.builder(
                                          itemCount: filteredItems.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(
                                                  filteredItems[index].email),
                                              onTap: () {
                                                setState(() {
                                                  _selectedGoldCardHolder =
                                                      filteredItems[index];
                                                  _editGoldUser.text =
                                                      filteredItems[index]
                                                          .email;
                                                  editGoldUserExpirationDateText
                                                          .text =
                                                      '${DateTime.fromMicrosecondsSinceEpoch(filteredItems[index].expirationdate).day}/${DateTime.fromMicrosecondsSinceEpoch(filteredItems[index].expirationdate).month}/${DateTime.fromMicrosecondsSinceEpoch(filteredItems[index].expirationdate).year}';

                                                  _isDropdownOpened = false;
                                                  _focusNode.unfocus();
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                MyTextFormField(
                                  controller: editGoldUserExpirationDateText,
                                  helpertext:
                                      editGoldUserExpirationDateHelperText,
                                  labelText: 'Expiration Date',
                                  width: 400,
                                  tapped: () async {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(
                                                DateTime.now().year - 5),
                                            lastDate: DateTime(
                                                DateTime.now().year + 5))
                                        .then((pickeddate) {
                                      if (pickeddate != null) {
                                        var day = pickeddate.day.toString();
                                        if (day.length == 1) {
                                          day = '0$day';
                                        }
                                        var month = pickeddate.month.toString();
                                        if (month.length == 1) {
                                          month = '0$month';
                                        }
                                        editGoldUserExpirationDateText.text =
                                            '$day/$month/${pickeddate.year}';
                                        editGoldUserExpirationDate =
                                            pickeddate.microsecondsSinceEpoch;
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                                updateButton(context),
                              ],
                            ),
                          ),
                          // page 3
                          Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Edit Discount Info',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 150,
                                        child: TextFormField(
                                          controller: discountController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value == '') {
                                              return 'Cannot be empty';
                                            }
                                            return null;
                                          },
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            labelText: 'Discount %',
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            floatingLabelAlignment:
                                                FloatingLabelAlignment.start,
                                            helperText: '',
                                            helperStyle: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 1, color: mainred)),
                                        onPressed: () async {
                                          final docUser = FirebaseFirestore
                                              .instance
                                              .collection('Admin')
                                              .doc('Discount');

                                          await docUser.update({
                                            'discount amount':
                                                discountController.text
                                          });
                                        },
                                        child: const Text(
                                          'Update',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        width: 150,
                                        child: TextFormField(
                                          controller: discountdateController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Cannot be empty';
                                            } else if (RegExp(
                                                        r'^(\d{0,2}):?(\d{0,2})$')
                                                    .hasMatch(value) ==
                                                false) {
                                              return 'Not a valid time';
                                            }
                                            return null;
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            labelText: 'Discount until',
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            floatingLabelAlignment:
                                                FloatingLabelAlignment.start,
                                            helperText: '',
                                            helperStyle: const TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 1, color: mainred)),
                                        onPressed: () async {
                                          final docUser = FirebaseFirestore
                                              .instance
                                              .collection('Admin')
                                              .doc('Discount');

                                          await docUser.update({
                                            'discount time':
                                                discountdateController.text
                                          });
                                        },
                                        child: const Text(
                                          'Update',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton.extended(
                  label: const Text('Preview'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const GoldCardHolderPage();
                      },
                    ));
                  },
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Padding submitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1, color: mainred)),
        child: const Text(
          'Create User',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            var newGoldCardUser = GoldUser(
                email: newGoldUserEmail.text,
                expirationdate: newGoldUserExpirationDate,
                name: newGoldUserName.text);
            createNewGoldCardUser(newGoldCardUser);
          }
        },
      ),
    );
  }

  Padding updateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1, color: mainred)),
        child: const Text(
          'Update User',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          if (_selectedGoldCardHolder != null &&
              editGoldUserExpirationDate != 0) {
            var editGoldCardUser = GoldUser(
                email: _selectedGoldCardHolder!.email,
                expirationdate: editGoldUserExpirationDate,
                name: _selectedGoldCardHolder!.name);
            updateGoldCardHolder(editGoldCardUser, _selectedGoldCardHolder!.id);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('User Updated')));
            editGoldUserExpirationDate = 0;
            editGoldUserExpirationDateText.clear();
            _selectedGoldCardHolder = null;
            _editGoldUser.clear();
          }
        },
      ),
    );
  }

  Future createNewGoldCardUser(GoldUser newGoldUser) async {
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary', options: Firebase.app().options);
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(
              email: newGoldUser.email, password: newGoldUserPassword.text);
      await userCredential.user?.updateDisplayName(newGoldUser.name);
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e.code);
      if (e.code == 'email-already-in-use') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User Already Exists')));
      }
      if (e.code == 'network-request-failed') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network error, restart')));
      }
      return 'not ok';
    }

    final docUser =
        FirebaseFirestore.instance.collection('GoldCardHolder').doc();
    newGoldUser.id = docUser.id;

    final json = newGoldUser.toJson();
    await docUser.set(json);
    

    // sends reset email to new user
    FirebaseAuth.instance
          .sendPasswordResetEmail(email: newGoldUser.email.trim());


    //await app.delete();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('New User Created')));

    setState(
      () {
        _formKey.currentState!.reset();
        newGoldUserName.text = '';
        newGoldUserEmail.text = '';
        newGoldUserPassword.text = '';
        //newGoldUserExpirationDate = 0;
        newGoldUserExpirationDateText.text = '';
      },
    );

    return 'ok';
  }

  dynamic updateGoldCardHolder(GoldUser goldUserEdit, String editID) async {
    final docUser =
        FirebaseFirestore.instance.collection('GoldCardHolder').doc(editID);
    final json = goldUserEdit.updatetoJson();
    await docUser.update(json);
  }
}

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String helpertext;
  final String labelText;
  final double width;
  final String? Function(String?)? validator;
  final FocusNode? focusnode;
  final void Function()? tapped;
  final void Function(String)? changed;

  const MyTextFormField(
      {super.key,
      required this.controller,
      required this.helpertext,
      required this.labelText,
      required this.width,
      this.validator,
      this.focusnode,
      required this.tapped,
      this.changed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        //autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        validator: validator,
        focusNode: focusnode,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary)),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary)),
          errorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary)),
          labelText: labelText,
          labelStyle: Theme.of(context).textTheme.bodyLarge,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          helperText: helpertext,
          helperStyle: const TextStyle(color: Colors.red),
        ),
        onTap: tapped,
        onChanged: changed,
      ),
    );
  }
}

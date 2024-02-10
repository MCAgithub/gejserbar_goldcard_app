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
                    TabBar(
                        controller: tabController,
                        labelPadding: const EdgeInsets.only(bottom: 5),
                        tabs: const [
                          Text(
                            'Add New',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Edit/Delete',
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
                          newGoldcardHolderTab(context),
                          editGoldcardHolderTab(context, filteredItems),
                          discountInfoTab(context),
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

  Form newGoldcardHolderTab(BuildContext context) {
    return Form(
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
            helpertext: newGoldUserExpirationDateHelperText,
            labelText: 'Expiration Date',
            width: 400,
            tapped: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5))
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
                  newGoldUserExpirationDate = pickeddate.microsecondsSinceEpoch;
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
    );
  }

  SizedBox editGoldcardHolderTab(
      BuildContext context, List<GoldUser> filteredItems) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            'Edit or Delete Gold Card Holder',
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
                        title: Text(filteredItems[index].email),
                        onTap: () {
                          setState(() {
                            _selectedGoldCardHolder = filteredItems[index];
                            _editGoldUser.text = filteredItems[index].email;
                            editGoldUserExpirationDateText.text =
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
            helpertext: editGoldUserExpirationDateHelperText,
            labelText: 'Expiration Date',
            width: 400,
            tapped: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5))
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
          deleteButton(context),
          userlistButton(context),
        ],
      ),
    );
  }

  Column discountInfoTab(BuildContext context) {
    return Column(
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
                      if (value == null || value.isEmpty || value == '') {
                        return 'Cannot be empty';
                      }
                      return null;
                    },
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      labelText: 'Discount %',
                      labelStyle: Theme.of(context).textTheme.bodyLarge,
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      helperText: '',
                      helperStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1, color: mainred)),
                  onPressed: () async {
                    final docUser = FirebaseFirestore.instance
                        .collection('Admin')
                        .doc('Discount');

                    await docUser
                        .update({'discount amount': discountController.text});
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
                      if (value == null || value.isEmpty) {
                        return 'Cannot be empty';
                      } else if (RegExp(r'^(\d{0,2}):?(\d{0,2})$')
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
                              color: Theme.of(context).colorScheme.primary)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary)),
                      labelText: 'Discount until',
                      labelStyle: Theme.of(context).textTheme.bodyLarge,
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      helperText: '',
                      helperStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(width: 1, color: mainred)),
                  onPressed: () async {
                    final docUser = FirebaseFirestore.instance
                        .collection('Admin')
                        .doc('Discount');

                    await docUser
                        .update({'discount time': discountdateController.text});
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
          try {
            if (_selectedGoldCardHolder != null &&
                editGoldUserExpirationDate != 0) {
              var editGoldCardUser = GoldUser(
                  email: _selectedGoldCardHolder!.email,
                  expirationdate: editGoldUserExpirationDate,
                  name: _selectedGoldCardHolder!.name);
              updateGoldCardHolder(
                  editGoldCardUser, _selectedGoldCardHolder!.id);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('User Updated')));
              editGoldUserExpirationDate = 0;
              editGoldUserExpirationDateText.clear();
              _selectedGoldCardHolder = null;
              _editGoldUser.clear();
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No User Selected')));
          }
        },
      ),
    );
  }

  Padding deleteButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1, color: Colors.red)),
        child: const Text(
          'Delete User',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          try {
            if (_selectedGoldCardHolder != null) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: app_backgroundcolor,
                      title: const Text(
                        'Are you sure you want to delete this user?',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'Delete User',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            if (_selectedGoldCardHolder != null) {
                              deleteGoldCardHolder(_selectedGoldCardHolder!.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('User Deleted')));
                              editGoldUserExpirationDate = 0;
                              editGoldUserExpirationDateText.clear();
                              _selectedGoldCardHolder = null;
                              _editGoldUser.clear();
                            }
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text(
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
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No User Selected')));
          }
        },
      ),
    );
  }

  Padding userlistButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(width: 1, color: mainred)),
        child: const Text(
          'Show list of Users',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const UserList()));
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

  dynamic deleteGoldCardHolder(String editID) async {
    final docUser =
        FirebaseFirestore.instance.collection('GoldCardHolder').doc(editID);
    await docUser.delete();
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

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(context) {
    return StreamBuilder(
        stream: DatabaseFirebasefunctions.getGoldUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
            return Scaffold(body: Text('Error $snapshot'),);
          }
          else if (snapshot.hasData){
            List<GoldUser> goldlist = snapshot.data!;
            List<String> emails = goldlist.map((user) => user.email).toList();
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'User List',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold, color: mainred),
              ),
              centerTitle: true,
              backgroundColor: app_backgroundcolor,
              iconTheme: const IconThemeData(color: mainred),
              actions: [
                TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: emails.join('\n')),);
                      ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emails copied to clipboard'),
                  ),
                );
                    },
                    child: const Text(
                      'Select all',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: mainred),
                    ))
              ],
            ),
            body: ListView.builder(
              itemCount: goldlist.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: SelectableText(
                    goldlist[index].email,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                );
              },
            ),
          );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
        });
  }
}

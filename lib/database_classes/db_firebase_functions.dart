import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gejserbar_guldkort_app/database_classes/db_user.dart';

class DatabaseFirebasefunctions {
  static Stream<List<GoldUser>> getGoldUser(golduser) => FirebaseFirestore.instance
      .collection('GoldCardHolder').where('email',isEqualTo: golduser)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => GoldUser.fromJson(doc.data())).toList());

  static Stream<List<GoldUser>> getGoldUsers() => FirebaseFirestore.instance
      .collection('GoldCardHolder')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => GoldUser.fromJson(doc.data())).toList());
}
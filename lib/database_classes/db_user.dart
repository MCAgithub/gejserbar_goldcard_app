// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

class GoldUser {
  String id;
  String email;
  int expirationdate;
  String name;

  GoldUser({
    this.id = '',
    required this.email,
    required this.expirationdate,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'id'            : id,
    'email'         : email,
    'expirationdate': expirationdate,
    'name'          : name,
  };

  static GoldUser fromJson(Map<String, dynamic> json) => GoldUser (
    id              : json['id'],
    email           : json['email'],
    expirationdate  : json['expirationdate'],
    name            : json['name']
    );

  Map<String, dynamic> updatetoJson() => {
    'email'         : email,
    'expirationdate': expirationdate,
    'name'          : name,
  };
}
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  static final storage = FirebaseStorage.instance;
  static final firestore = FirebaseFirestore.instance;

  final notifications = firestore.collection("notifications");

}

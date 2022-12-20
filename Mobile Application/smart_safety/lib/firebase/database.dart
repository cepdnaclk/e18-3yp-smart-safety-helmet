// class for add user to users collection when they are registering

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // User ID
  final String userID;
  String username = '';

  // Constructor
  DatabaseService({required this.userID});

  // Collection refernece
  final database = FirebaseFirestore.instance.collection('users');

  // Function to update database
  Future updateUserData(String name) async {
    return await database.doc(userID).set({
      'name': name,
    });
  }
}

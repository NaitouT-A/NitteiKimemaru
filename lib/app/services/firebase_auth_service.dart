import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez2gether/utils/random_generator_util.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<Map<String, String>> saveData({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime dueDate,
    required String note,
  }) async {
    CollectionReference schedules =
        FirebaseFirestore.instance.collection('schedules');
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid.toString();
    // Generate the room ID and password
    String roomId = getRandomRoomId().toString();
    String rawPassword = getRandomRoomPassword();
    String hashedPassword = hashPassword(rawPassword);
    try {
      await schedules.add({
        'roomid': roomId,
        'password': hashedPassword,
        'uid': uid,
        'title': title,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'note': note,
      });
      // Return the room ID and raw password
      return {'roomid': roomId, 'password': rawPassword};
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<QuerySnapshot> getRoomDetails(String roomId) {
    return FirebaseFirestore.instance
        .collection('schedules')
        .where('roomid', isEqualTo: roomId)
        .get();
  }

  String? currentUserUid() {
    return _firebaseAuth.currentUser?.uid;
  }
}

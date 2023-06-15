import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez2gether/utils/random_generator_util.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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
      DocumentReference docRef = await schedules.add({
        'roomid': roomId,
        'password': hashedPassword,
        'uid': uid,
        'title': title,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'note': note,
      });
      // get the document ID
      String docId = docRef.id;
      // Return the room ID, raw password and document ID
      return {'roomid': roomId, 'password': rawPassword, 'docId': docId};
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      try {
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        return userCredential;
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    }
    return null;
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

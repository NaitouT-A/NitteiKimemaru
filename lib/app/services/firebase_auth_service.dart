import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ez2gether/utils/random_generator_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez2gether/app/providers/auth_provider.dart';

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

  Future<void> addHandleName(
      String roomId, String uid, String handleName) async {
    DocumentReference roomDoc =
        FirebaseFirestore.instance.collection('rooms').doc(roomId);

    return roomDoc
        .set({
          'members': {uid: handleName}
        }, SetOptions(merge: true))
        .then((value) => debugPrint("Handle Name Added"))
        .catchError((error) => debugPrint("Failed to add handle name: $error"));
  }

  Future<String?> getHandleName(String roomId, String userId) async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> members = data['members'] as Map<String, dynamic>;
      return members[userId] ?? null;
    } else {
      return null;
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

// ルームIDに対応するルームが存在するかをチェックする
  Future<bool> roomExists(String roomId) async {
    QuerySnapshot snapshot = await getRoomDetails(roomId);
    return snapshot.docs.isNotEmpty;
  }

  Future<bool> verifyPassword(String roomId, String password) async {
    // Hash the input password
    String hashedPassword = hashPassword(password);

    // Fetch the room details
    QuerySnapshot snapshot = await getRoomDetails(roomId);
    if (snapshot.docs.isNotEmpty) {
      // If multiple docs have the same roomId (which should not be the case), verify the first one
      Map<String, dynamic> data =
          snapshot.docs.first.data() as Map<String, dynamic>;
      String storedPassword = data['password'] ?? '';
      // Return true if the hashed password matches the stored password
      return hashedPassword == storedPassword;
    } else {
      throw Exception('Room does not exist');
    }
  }

  Future<String> getDocumentIdFromRoomId(String roomId) async {
    QuerySnapshot snapshot = await getRoomDetails(roomId);
    if (snapshot.docs.isNotEmpty) {
      // If multiple docs have the same roomId (which should not be the case), return the first one
      return snapshot.docs.first.id;
    } else {
      throw Exception('Room does not exist');
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
        'hostUid': uid,
        'title': title,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'deadline': Timestamp.fromDate(dueDate),
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

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth != null) {
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final userCredential =
            await _firebaseAuth.currentUser!.linkWithCredential(credential);
        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          return _firebaseAuth
              .signInWithCredential(credential)
              .then((userCredential) => userCredential.user);
        }
        debugPrint(e.message);
        return null;
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

  String? currentUserUid(BuildContext context) {
    final container = ProviderContainer();
    return container.read(authProvider).currentUser?.uid;
  }
}

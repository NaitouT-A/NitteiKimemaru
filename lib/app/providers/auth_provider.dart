import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ez2gether/app/services/firebase_auth_service.dart';

final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authProvider).authStateChanges();
});

final firebaseAuthProvider =
    Provider<FirebaseAuthService>((ref) => FirebaseAuthService());

final initializationProvider = FutureProvider<void>((ref) async {
  await ref.read(firebaseAuthProvider).signInAnonymously();
});

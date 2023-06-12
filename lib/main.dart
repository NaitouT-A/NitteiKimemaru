import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ez2gether/app/views/top_view.dart';
import 'package:ez2gether/app/services/firebase_auth_service.dart';
import 'package:ez2gether/app/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

final firebaseAuthProvider =
    Provider<FirebaseAuthService>((ref) => FirebaseAuthService());

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationStatus = ref.watch(initializationProvider);

    return initializationStatus.when(
      data: (_) => MaterialApp(
        title: 'ez2gether',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 49, 110, 196)),
            useMaterial3: true,
            fontFamily: 'NotoSansJP'),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale("en"),
          Locale("ja"),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('An error occurred'),
    );
  }
}

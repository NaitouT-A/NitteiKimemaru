import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez2gether/app/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF385A7C),
              Color(0xFF203A54),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 80),
            Text(
              '日程決め丸',
              style: TextStyle(
                fontSize: size.width / 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    ref
                        .read(firebaseAuthProvider)
                        .signInAnonymously()
                        .then((_) {
                      context.go('/create');
                    }).catchError((e) {
                      debugPrint(e.toString());
                    });
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '予定を作る',
                  style: TextStyle(
                    fontSize: size.width / 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  _showJoinScheduleDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '予定に参加する',
                  style: TextStyle(
                    fontSize: size.width / 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showJoinScheduleDialog(BuildContext context, WidgetRef ref) {
  final TextEditingController roomIdController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('予定に参加する'),
        content: TextField(
          controller: roomIdController,
          decoration: const InputDecoration(
            hintText: "ルームIDを入力",
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () async {
              String roomId = roomIdController.text.trim();
              bool roomExists =
                  await ref.read(firebaseAuthProvider).roomExists(roomId);
              if (roomExists) {
                Navigator.of(context).pop();
                _showPasswordDialog(context, roomId, ref);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('該当のルームは存在しません。'),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('参加する'),
          ),
        ],
      );
    },
  );
}

void _showPasswordDialog(BuildContext context, String roomId, WidgetRef ref) {
  final TextEditingController passwordController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('パスワードを入力してください'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "パスワードを入力",
          ),
        ),
        actions: [
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            onPressed: () async {
              String password = passwordController.text.trim();
              bool passwordIsCorrect = await ref
                  .read(firebaseAuthProvider)
                  .verifyPassword(roomId, password);
              if (passwordIsCorrect) {
                Navigator.of(context).pop();
                String docId = await ref
                    .read(firebaseAuthProvider)
                    .getDocumentIdFromRoomId(roomId);
                context.go('/$roomId/$docId');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('パスワードが間違っています。'),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

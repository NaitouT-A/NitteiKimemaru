import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez2gether/app/providers/auth_provider.dart';
import 'package:ez2gether/app/views/create_schedule.view.dart';

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateScheduleView(),
                        ),
                      );
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
                  _showJoinScheduleDialog(context);
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

void _showJoinScheduleDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('予定に参加する'),
        content: TextField(
          onChanged: (value) {},
          decoration: const InputDecoration(
            hintText: "予定のURLを入力",
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
            onPressed: () {
              Navigator.of(context).pop();
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

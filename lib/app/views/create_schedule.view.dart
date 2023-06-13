import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ez2gether/app/providers/other_provider.dart';
import 'package:ez2gether/app/services/firebase_auth_service.dart';
import 'package:flutter/services.dart';
import 'package:ez2gether/app/router/router.dart';

class CreateScheduleView extends ConsumerStatefulWidget {
  const CreateScheduleView({Key? key}) : super(key: key);

  @override
  CreateScheduleViewState createState() => CreateScheduleViewState();
}

class CreateScheduleViewState extends ConsumerState<CreateScheduleView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _startDate = ref.watch(scheduleProvider).startDate;
    _endDate = ref.watch(scheduleProvider).endDate;
    _dueDate = ref.watch(scheduleProvider).dueDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('予定を作る'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24.0),
                const Text(
                  'タイトル',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: '予定のタイトルを入力してください',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'タイトルを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '期間',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: _startDate == null
                              ? '開始日を選択してください'
                              : _dateFormatter.format(_startDate!),
                        ),
                        validator: (value) {
                          if (_startDate == null) {
                            return '開始日を入力してください';
                          }
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            locale: const Locale("ja"),
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(DateTime.now().year - 5),
                            lastDate: DateTime(DateTime.now().year + 5),
                          );
                          if (date != null) {
                            ref
                                .read(scheduleProvider.notifier)
                                .updateStartDate(date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          hintText: _endDate == null
                              ? '終了日を選択してください'
                              : _dateFormatter.format(_endDate!),
                        ),
                        validator: (value) {
                          if (_endDate == null) {
                            return '終了日を入力してください';
                          }
                          return null;
                        },
                        onTap: () async {
                          final date = await showDatePicker(
                            locale: const Locale("ja"),
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(DateTime.now().year - 5),
                            lastDate: DateTime(DateTime.now().year + 5),
                          );
                          if (date != null) {
                            ref
                                .read(scheduleProvider.notifier)
                                .updateEndDate(date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '締切日',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: _dueDate == null
                        ? '締切日を選択してください'
                        : _dateFormatter.format(_dueDate!),
                  ),
                  validator: (value) {
                    if (_dueDate == null) {
                      return '締切日を入力してください';
                    }
                    return null;
                  },
                  onTap: () async {
                    final date = await showDatePicker(
                      locale: const Locale("ja"),
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (date != null) {
                      ref.read(scheduleProvider.notifier).updateDueDate(date);
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelText: '備考',
                    hintText: 'その他の詳細情報を入力してください',
                  ),
                  minLines: 4,
                  maxLines: 4,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Map<String, String> result =
                          await FirebaseAuthService().saveData(
                        title: _titleController.text,
                        startDate: _startDate!,
                        endDate: _endDate!,
                        dueDate: _dueDate!,
                        note: _noteController.text,
                      );
                      _showDialog(context, result, () {
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    '作成',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showDialog(
    BuildContext context, Map<String, String> result, VoidCallback onCopy) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("ルームIDとパスワード"),
        content: SelectableText(
          'ルームID：${result['roomid']} パスワード：${result['password']}',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("コピー"),
            onPressed: () {
              // クリップボードにコピーします
              Clipboard.setData(ClipboardData(
                  text:
                      'ルームID：${result['roomid']} パスワード：${result['password']}'));
              onCopy();
              goRouter.go('/${result['roomid']}/${result['docId']}');
            },
          ),
        ],
      );
    },
  );
}

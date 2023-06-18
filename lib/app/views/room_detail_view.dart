import 'dart:io';

import 'package:ez2gether/app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez2gether/app/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ez2gether/app/providers/other_provider.dart'; // Import the other_provider file

class RoomDetailsScreen extends ConsumerWidget {
  final String roomId;
  final String docId;
  final FirebaseAuthService auth = FirebaseAuthService();

  RoomDetailsScreen({Key? key, required this.roomId, required this.docId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayState = ref.watch(dayStateProvider);
    final userAsyncValue = ref.watch(authStateChangesProvider);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      userAsyncValue.whenData((user) {
        if (user != null) {
          auth.getHandleName(roomId, user.uid).then((handleName) {
            if (handleName == null) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String newHandleName = '';
                  return AlertDialog(
                    title: const Text('Set your handle name'),
                    content: TextField(
                      onChanged: (value) {
                        newHandleName = value;
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          auth.addHandleName(roomId, user.uid, newHandleName);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          });
        }
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: auth.getRoomDetails(roomId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            var documents = snapshot.data!.docs;
            if (documents.isNotEmpty) {
              var roomDetails = documents.first.data() as Map<String, dynamic>;
              var title = roomDetails['title'];
              var startDate = (roomDetails['startDate'] as Timestamp).toDate();
              var endDate = (roomDetails['endDate'] as Timestamp).toDate();
              var dueDate = (roomDetails['deadline'] as Timestamp).toDate();
              var note = roomDetails['note'];
              var hostUid = roomDetails['uid'];
              var password = roomDetails['password'];
              var roomId = roomDetails['roomid'];

              var dueDateFormatted = DateFormat('MM/dd/yyyy').format(dueDate);

              var isHost = hostUid;

              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(fontSize: 24),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Details"),
                                    content: Text(
                                        "URL: url \nRoom ID: $roomId\nPassword: ${(isHost) ? password : 'Not available'}"),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info),
                            ),
                            Text(
                              dueDateFormatted,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        userAsyncValue.when(
                          data: (user) {
                            if (user != null) {
                              return Text('Logged in as: ${user.uid}');
                            } else {
                              return const Text('Not logged in');
                            }
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) => Text('Error: $error'),
                        )
                      ],
                    ),
                  ),
                  TableCalendar(
                    firstDay: startDate,
                    lastDay: endDate,
                    focusedDay: startDate.isAfter(DateTime.now())
                        ? startDate
                        : DateTime.now(),
                    locale: 'ja_JP',
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.week: 'Week',
                      CalendarFormat.twoWeeks: '2 Weeks',
                    },
                    onFormatChanged: (format) {},
                    onDaySelected: (selectedDay, focusedDay) {
                      ref
                          .read(dayStateProvider.notifier)
                          .onDaySelected(selectedDay);
                    },
                    onHeaderTapped: (focusedDay) {
                      ref
                          .read(dayStateProvider.notifier)
                          .onHeaderTapped(focusedDay.weekday);
                      debugPrint(focusedDay.weekday.toString());
                    },
                  ),
                ],
              );
            }
          }
          return const Center(child: Text("No data"));
        },
      ),
    );
  }
}

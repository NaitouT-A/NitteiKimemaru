import 'package:flutter/material.dart';
import 'package:ez2gether/app/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class RoomDetailsScreen extends StatelessWidget {
  final String roomId;
  final String docId;
  final FirebaseAuthService auth = FirebaseAuthService();

  RoomDetailsScreen({Key? key, required this.roomId, required this.docId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              var dueDate = (roomDetails['dueDate'] as Timestamp).toDate();
              var note = roomDetails['note'];
              var hostUid = roomDetails['uid'];
              var password = roomDetails['password'];
              var roomId = roomDetails['roomid'];

              var dueDateFormatted = DateFormat('MM/dd/yyyy').format(dueDate);

              var isHost = hostUid == auth.currentUserUid();

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
                        // Add the host and member list here
                        // Use appropriate widgets to display the list
                        const Text("Host and Members")
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
                    onFormatChanged: (format) {
                      // do something when format changes
                      // e.g., you could trigger a state update here
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

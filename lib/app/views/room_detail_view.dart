import 'package:flutter/material.dart';
import 'package:ez2gether/app/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomDetailsScreen extends StatelessWidget {
  final String roomId;
  final FirebaseAuthService auth = FirebaseAuthService();

  RoomDetailsScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Details'),
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
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: <Widget>[
                    _buildText("Room ID: ${roomDetails['roomid']}"),
                    _buildText("Title: ${roomDetails['title']}"),
                    _buildText("Start Date: ${roomDetails['startDate']}"),
                    _buildText("End Date: ${roomDetails['endDate']}"),
                    _buildText("Due Date: ${roomDetails['dueDate']}"),
                    _buildText("Note: ${roomDetails['note']}"),
                    _buildText("Host UID: ${roomDetails['uid']}"),
                    // Ensure that the password is only visible to the host
                    if (roomDetails['uid'] == auth.currentUserUid())
                      _buildText("Password: ${roomDetails['password']}"),
                  ],
                ),
              );
            }
          }
          return const Center(child: Text("No data"));
        },
      ),
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

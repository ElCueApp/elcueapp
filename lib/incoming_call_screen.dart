import 'package:flutter/material.dart';
import 'package:elcueapp/video_call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerId;
  final String channelName; // Tambahkan parameter channelName
  final String receiverId; // Tambahkan parameter receiverId

  const IncomingCallScreen({Key? key, required this.callerId, required this.channelName, required this.receiverId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAD7DB),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFF0021AC)),
        backgroundColor: Color(0xFFFAD7DB),
        title: Text('Incoming Call', style: TextStyle(color: Color(0xFF0021AC))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Incoming call from $callerId', style: TextStyle(color: Color(0xFF0021AC), fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Menangani logika jika panggilan diterima
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoCallScreen(
                      callerId: callerId,
                      channelName: channelName,
                      receiverId: receiverId,
                    ),
                  ),
                );
              },
              child: Text('Accept Call'),
            ),
            ElevatedButton(
              onPressed: () {
                // Menangani logika jika panggilan ditolak
                Navigator.pop(context);
              },
              child: Text('Decline Call'),
            ),
          ],
        ),
      ),
    );
  }
}

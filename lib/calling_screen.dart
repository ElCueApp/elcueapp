import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elcueapp/chat_provider.dart';
import 'package:elcueapp/video_call_screen.dart';

class CallingScreen extends StatelessWidget {
  final String receiverId;
  final String callerName; // Nama penelepon

  const CallingScreen({Key? key, required this.receiverId, this.callerName = 'Unknown'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendVideoCallNotification(receiverId);

    return Scaffold(
      backgroundColor: Color(0xFFFAD7DB),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFF0021AC)),
        backgroundColor: Color(0xFFFAD7DB),
        title: Text('Calling...', style: TextStyle(color: Color(0xFF0021AC))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Calling $callerName...', style: TextStyle(color: Color(0xFF0021AC), fontSize: 20)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality to cancel the call if needed
              },
              child: Text('Cancel Call'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import 'video_call_screen.dart';

class CreateChannelScreen extends StatefulWidget {
  @override
  _CreateChannelScreenState createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  TextEditingController _channelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Channel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _channelController,
              decoration: InputDecoration(
                hintText: 'ElCue-VC',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => joinVideoCall(context),
              child: Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }

  void joinVideoCall(BuildContext context) async {
    String channelName = _channelController.text;
    if (channelName.isNotEmpty) {
      // Assumed that the token is generated from your server or statically defined for testing
      String token = "007eJxTYKjResTP/TWbnZklJEaON+1aXus3Na3gM0odB+7IdpWV/lBgSDZMMjIzNzRJMTI3MTFMTrNISTayMLQwMjRMtTA3MzbV4e9MawhkZCi6fpyJkQECQXwOBtcc59JU3TBnBgYAusIdEQ==";

      // Ask for camera and microphone permissions
      await [Permission.camera, Permission.microphone].request();

      // Push to the actual call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(channelName: channelName, token: token),
        ),
      );
    }
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }
}

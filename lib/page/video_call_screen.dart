import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String token;

  VideoCallScreen({required this.channelName, required this.token});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  List<int> _remoteUids = [];  // Store multiple UIDs
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: 'c1b26714d27441cf8dc2818211e87635'));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Join channel successful: ${connection.channelId}, uid: ${connection.localUid}');
          setState(() {
            _isInitialized = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('User joined: $remoteUid');
          setState(() {
            _remoteUids.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print('User offline: $remoteUid');
          setState(() {
            _remoteUids.remove(remoteUid);
          });
        },
        onError: (ErrorCodeType code, String description) {
          print('Agora Error: $code, Description: $description');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call - ${widget.channelName}'),
      ),
      body: _isInitialized
          ? Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: _localPreview(),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _localPreview() {
    return Container(
      width: 120,
      height: 160,
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: 0),
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    return _remoteUids.isEmpty
        ? Text('Waiting for user to join...', textAlign: TextAlign.center)
        : ListView.builder(
      itemCount: _remoteUids.length,
      itemBuilder: (context, index) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUids[index]),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}

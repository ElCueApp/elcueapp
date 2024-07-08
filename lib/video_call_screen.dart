// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'agora_config.dart'; // Pastikan Anda memiliki file ini dengan konfigurasi Agora yang benar
// import 'speech_to_text_provider.dart'; // Pastikan Anda memiliki provider ini untuk mengubah ucapan menjadi teks
// import 'sign_language_detector.dart'; // Pastikan Anda memiliki detector ini untuk mendeteksi bahasa isyarat
// import 'package:camera/camera.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:path/path.dart' show join;

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final String receiverId;
//   final String callerId;

//   const VideoCallScreen({required this.channelName, required this.receiverId, required this.callerId});

//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   final SpeechToTextProvider _speechToTextProvider = SpeechToTextProvider();
//   final SignLanguageDetector _signLanguageDetector = SignLanguageDetector();
//   String _recognizedText = '';
//   CameraController? _cameraController;
//   String _signLanguageText = '';
//   late RtcEngine _engine;

//   @override
//   void initState() {
//     super.initState();
//     initializeAgora();
//     initializeCamera();
//     _speechToTextProvider.addListener(() {
//       setState(() {
//         _recognizedText = _speechToTextProvider.recognizedText;
//       });
//     });
//     _signLanguageDetector.loadModel().then((_) {
//       print("Sign language model loaded");
//     });
//   }

//   Future<void> initializeAgora() async {
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(
//       appId: APP_ID,
//     ));

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           print('joinChannelSuccess ${connection.channelId} ${connection.localUid} $elapsed');
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           print('userJoined $remoteUid $elapsed');
//         },
//         onLeaveChannel: (RtcConnection connection, RtcStats stats) {
//           print('leaveChannel $stats');
//         },
//       ),
//     );

//     await _engine.enableVideo();
//     await _engine.joinChannel(
//       token: '', // Berikan token Anda jika menggunakan otentikasi token
//       channelId: widget.channelName,
//       uid: 0,
//       options: ChannelMediaOptions(),
//     );
//   }

//   Future<void> initializeCamera() async {
//     final cameras = await availableCameras();
//     final camera = cameras.first;
//     _cameraController = CameraController(
//       camera,
//       ResolutionPreset.medium,
//     );
//     await _cameraController?.initialize().then((_) {
//       if (!mounted) return;
//       setState(() {});
//     });

//     _cameraController?.startImageStream((CameraImage image) async {
//       final imagePath = await saveImage(image);
//       final result = await _signLanguageDetector.detectSignLanguage(imagePath);
//       setState(() {
//         _signLanguageText = result?.isNotEmpty == true ? result![0]['label'] : '';
//       });
//     });
//   }

//   Future<String> saveImage(CameraImage image) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final imagePath = join(directory.path, '${DateTime.now()}.png');
//     final file = File(imagePath);
//     await file.writeAsBytes(image.planes[0].bytes);
//     return imagePath;
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel();
//     _engine.release();
//     _speechToTextProvider.stopListening();
//     _cameraController?.dispose();
//     _signLanguageDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Call'),
//       ),
//       body: Stack(
//         children: [
//           _buildVideoView(),
//           _buildRecognizedTextView(),
//           _buildSignLanguageTextView(),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoView() {
//     if (_engine != null) {
//       return AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: 0),
//         ),
//       );
//     } else {
//       return Center(child: CircularProgressIndicator());
//     }
//   }

//   Widget _buildRecognizedTextView() {
//     return Positioned(
//       top: 20,
//       left: 20,
//       child: Text(
//         'Recognized Text: $_recognizedText',
//         style: TextStyle(fontSize: 18),
//       ),
//     );
//   }

//   Widget _buildSignLanguageTextView() {
//     return Positioned(
//       bottom: 20,
//       left: 20,
//       child: Text(
//         'Sign Language: $_signLanguageText',
//         style: TextStyle(fontSize: 18),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'agora_config.dart'; // Pastikan Anda memiliki file ini dengan konfigurasi Agora yang benar
import 'speech_to_text_provider.dart'; // Pastikan Anda memiliki provider ini untuk mengubah ucapan menjadi teks
import 'sign_language_detector.dart'; // Pastikan Anda memiliki detector ini untuk mendeteksi bahasa isyarat
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' show join;

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String receiverId;
  final String callerId;

  const VideoCallScreen({required this.channelName, required this.receiverId, required this.callerId});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final SpeechToTextProvider _speechToTextProvider = SpeechToTextProvider();
  final SignLanguageDetector _signLanguageDetector = SignLanguageDetector();
  String _recognizedText = '';
  CameraController? _cameraController;
  String _signLanguageText = '';
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initializeAgora();
    initializeCamera();
    _speechToTextProvider.addListener(() {
      setState(() {
        _recognizedText = _speechToTextProvider.recognizedText;
      });
    });
    _signLanguageDetector.loadModel().then((_) {
      print("Sign language model loaded");
    });
  }

  Future<void> initializeAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: APP_ID,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('joinChannelSuccess ${connection.channelId} ${connection.localUid} $elapsed');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('userJoined $remoteUid $elapsed');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print('leaveChannel $stats');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: '', // Biarkan kosong jika tidak menggunakan otentikasi token
      channelId: widget.channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    await _cameraController?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });

    _cameraController?.startImageStream((CameraImage image) async {
      final imagePath = await saveImage(image);
      final result = await _signLanguageDetector.detectSignLanguage(imagePath);
      setState(() {
        _signLanguageText = result?.isNotEmpty == true ? result![0]['label'] : '';
      });
    });
  }

  Future<String> saveImage(CameraImage image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = join(directory.path, '${DateTime.now()}.png');
    final file = File(imagePath);
    await file.writeAsBytes(image.planes[0].bytes);
    return imagePath;
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    _speechToTextProvider.stopListening();
    _cameraController?.dispose();
    _signLanguageDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
      ),
      body: Stack(
        children: [
          _buildVideoView(),
          _buildRecognizedTextView(),
          _buildSignLanguageTextView(),
        ],
      ),
    );
  }

  Widget _buildVideoView() {
    return Container(
      child: AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: 0),
        ),
      ),
    );
  }

  Widget _buildRecognizedTextView() {
    return Positioned(
      top: 20,
      left: 20,
      child: Text(
        'Recognized Text: $_recognizedText',
        style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
      ),
    );
  }

  Widget _buildSignLanguageTextView() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Text(
        'Sign Language: $_signLanguageText',
        style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
      ),
    );
  }
}


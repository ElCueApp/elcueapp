import 'package:flutter/material.dart';

class SpeechToTextProvider with ChangeNotifier {
  String recognizedText = '';

  void startListening() {
    // Start listening to the speech and update recognizedText
    notifyListeners();
  }

  void stopListening() {
    // Stop listening
    notifyListeners();
  }

  void setRecognizedText(String text) {
    recognizedText = text;
    notifyListeners();
  }
}

import 'package:tflite/tflite.dart';

class SignLanguageDetector {
  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/model.tflite',
    );
    print("Model loaded: $res");
  }

  Future<List?> detectSignLanguage(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    return recognitions;
  }

  Future<void> close() async {
    await Tflite.close();
  }
}

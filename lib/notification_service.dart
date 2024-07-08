import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> sendNotificationToDevice(String deviceToken, String title, String body) async {
    try {
      await FirebaseMessaging.instance.sendMessage(
        to: deviceToken,
        data: {
          'title': title,
          'body': body,
        },
        priority: 'high',
      );
      print('Notification sent successfully');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static void initializeFirebaseMessaging() {
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print('Device Token: $token');
        saveTokenToDatabase(token);
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (token != null) {
        print('Device Token Refreshed: $token');
        saveTokenToDatabase(token);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static void saveTokenToDatabase(String token) {
    // Example implementation to save the token to a database (e.g., Firestore)
    print('Token saved to database: $token');
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chatapp/controllers/appwrite_controllers.dart';
import 'package:chatapp/controllers/local_saved_data.dart';
import 'package:chatapp/main.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // Request notification permission
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static Future<String?> getDeviceToken({int maxRetries = 3}) async {
    try {
      String token = (await _firebaseMessaging.getToken())!;
      saveUserDeviceToken(token, LocalSavedData.getUserId());
      print("Device token: $token");
      return token;
    } catch (e) {
      print("Failed to get token: $e");
      return null;
    }
  }

  // Initialize local notifications
  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
      
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
      
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
      
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );
  }

  // Handle notification tap
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState?.pushNamed("/home");
  }

  // Show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'General notifications channel',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          enableVibration: true,
        );
        
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();
        
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
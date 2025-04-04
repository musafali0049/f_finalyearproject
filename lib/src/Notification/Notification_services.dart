import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:finalfyp/main.dart'; // To access navigatorKey.

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final Map<String, dynamic> messageData = jsonDecode(response.payload!);
          navigatorKey.currentState?.pushNamed('/notification', arguments: messageData);
        } else {
          navigatorKey.currentState?.pushNamed('/notification');
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.data}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigatorKey.currentState?.pushNamed('/notification');
      _storeBroadcastNotification(
        message.notification?.title,
        message.notification?.body,
      );
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        navigatorKey.currentState?.pushNamed('/notification');
        _storeBroadcastNotification(
          message.notification?.title,
          message.notification?.body,
        );
      }
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final String title = message.notification?.title ?? 'New Notification';
    final String body = message.notification?.body ?? 'You have a new message';
    final String payloadData = jsonEncode({'title': title, 'body': body});

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payloadData,
    );

    _storeBroadcastNotification(title, body);
  }

  /// Stores a broadcast notification for all users.
  Future<void> _storeBroadcastNotification(String? title, String? body) async {
    final broadcastData = {
      'title': title ?? 'No Title',
      'body': body ?? 'No Message',
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': <String>[]  // Initially, no one has read it.
    };

    try {
      await FirebaseFirestore.instance
          .collection('broadcast_notifications')
          .add(broadcastData);
      print("Broadcast notification stored successfully.");
    } catch (error) {
      print("Failed to store broadcast notification: $error");
    }
  }
}

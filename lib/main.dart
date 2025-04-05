// main.dart
import 'dart:convert';
import 'dart:io';
import 'package:finalfyp/src/Firebase/firebase_options.dart';
import 'package:finalfyp/src/Notification/NotificationScreen.dart';
import 'package:finalfyp/src/Notification/Notification_services.dart';
import 'package:finalfyp/src/UserRegisterationHistory/login_screen.dart';
import 'package:finalfyp/src/WelcomeHome/splash_screen.dart';
import 'package:finalfyp/src/WelcomeHome/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalfyp/src/Service/permission_services.dart';
import 'package:flutter/services.dart'; // Import for orientation lock

/// Global navigator key to allow navigation from notification callbacks.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");

  final String title = message.notification?.title ?? 'New Notification';
  final String body = message.notification?.body ?? 'You have a new message';

  // Store broadcast notification with 'readBy' field.
  try {
    await FirebaseFirestore.instance.collection('broadcast_notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': <String>[],
    });
    print("Broadcast notification stored in background.");
  } catch (error) {
    print("Failed to store broadcast notification in background: $error");
  }
}

/// Firebase initializer with a flag to prevent multiple initializations.
class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!_initialized) {
      print("Initializing Firebase...");
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _initialized = true;
        print("Firebase Initialized.");
      } catch (e) {
        print("Error initializing Firebase: $e");
      }
    } else {
      print("Firebase is already initialized.");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app orientation to portrait only.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // Agar aap portraitDown bhi allow karna chahte hain to niche uncomment karen:
    // DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase.
  await FirebaseInitializer.initialize();

  // Request storage permission immediately after Firebase initialization.
  bool storagePermissionGranted = await PermissionService.requestStoragePermission();
  if (!storagePermissionGranted) {
    print("Storage permission not granted. User may need to grant permission manually.");
  }

  // Set up background message handler.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications and Firestore storage.
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  // Subscribe all devices to the "all_users" topic for broadcast notifications.
  await FirebaseMessaging.instance.subscribeToTopic("all_users");
  print("Subscribed to all_users topic.");

  // Print FCM Token for debugging.
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/notification': (context) => const NotificationScreen(),
      },
    );
  }
}

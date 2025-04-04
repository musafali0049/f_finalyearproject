import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalfyp/src/FeedbackHelp/Reviewfeedback.dart';
import 'package:finalfyp/src/Service/auth.dart';
import 'package:finalfyp/src/WelcomeHome/home_services.dart';
import 'package:finalfyp/src/Widgets/CustomButtons.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Notification/NotificationScreen.dart';
import '../UserRegisterationHistory/login_screen.dart';
import '../Chatbot/pneumobot_screen.dart';
import '../ImageProcessUI/imageupload_screen.dart';
import '../UserRegisterationHistory/userhistory_screen.dart';
import '../Widgets/CustomAnimation.dart';
import '../User_profile_managment/user_profile.dart';

class HomeScreen extends StatefulWidget {
  final bool fromLogin;

  const HomeScreen({super.key, required this.fromLogin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    checkUnreadNotifications();
  }

  void checkUnreadNotifications() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('broadcast_notifications')
        .snapshots()
        .listen((snapshot) {
      final unread = snapshot.docs.where((doc) {
        final data = doc.data();
        final List<dynamic> readBy = data['readBy'] ?? [];
        return !readBy.contains(currentUser.uid);
      }).toList();

      setState(() {
        hasUnreadNotifications = unread.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent UI shift when keyboard appears.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          // Popup Menu Button.
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFFF1F6F6)),
            onSelected: (value) {
              if (value == 'View Profile') {
                if (FirebaseAuth.instance.currentUser != null) {
                  Navigator.push(
                    context,
                    CustomPageRoute(page: const UserProfileScreen()),
                  );
                } else {
                  home_services().showLoginPrompt(context);
                }
              } else if (value == 'Sign Out') {
                AuthMethod().signOutUser(context);
              } else if (value == 'Review') {
                Navigator.push(
                  context,
                  CustomPageRoute(page: ReviewScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'View Profile',
                  child: Text('View Profile'),
                ),
                const PopupMenuItem<String>(
                  value: 'Review',
                  child: Text('Review'),
                ),
                const PopupMenuItem<String>(
                  value: 'Sign Out',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
          // Notification Icon Button.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Color(0xFFF1F6F6), size: 24),
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    }
                  },
                ),
                if (hasUnreadNotifications)
                  const Positioned(
                    right: 6,
                    top: 6,
                    child: Icon(Icons.brightness_1, size: 10, color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: Container(
              width: double.infinity,
              height: 440,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Asset/images/body.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Pneumonia Detector',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 30, color: Color(0xFFE3F2FD)),
                  ),
                  const SizedBox(height: 250),
                  const Text(
                    'Detect Pneumonia in seconds',
                    style: TextStyle(
                      color: Color(0xFFE3F2FD),
                      fontFamily: 'Poppinsmedium',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Using advanced AI technology, we can help you detect pneumonia from chest X-ray images.',
                    style: TextStyle(
                      color: Color(0xFFE3F2FD),
                      fontFamily: 'Poppinsmedium',
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      CustomElevatedButton(
                        width: 300,
                        onPressed: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(page: const UploadImageScreen()),
                          );
                        },
                        icon: Icons.upload,
                        label: 'Upload Image',
                      ),
                      const SizedBox(height: 10),
                      CustomElevatedButton(
                        width: 300,
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser == null) {
                            home_services().showLoginPrompt(context);
                          } else {
                            Navigator.push(
                              context,
                              CustomPageRoute(page: const HistoryScreen()),
                            );
                          }
                        },
                        icon: Icons.history,
                        label: 'History',
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomElevatedButton(
                            width: 150,
                            isIconButton: false,
                            onPressed: () {
                              if (FirebaseAuth.instance.currentUser != null) {
                                home_services().showConformationPrompt(context);
                              } else {
                                Navigator.push(
                                  context,
                                  CustomPageRoute(page: const LoginScreen()),
                                );
                              }
                            },
                            icon: Icons.login,
                            label: 'Log in',
                            backgroundColor: const Color(0xFFB0BEC5),
                            labelColor: const Color(0xFF0D2962),
                            iconColor: const Color(0xFF0D2962),
                          ),
                          const SizedBox(width: 20),
                          CustomCircleAvatarButton(
                            radius: 25,
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(page: const ChatBotScreen()),
                              );
                            },
                            imagePath: 'Asset/images/chatbot.png',
                          ),
                        ],
                      ),


                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

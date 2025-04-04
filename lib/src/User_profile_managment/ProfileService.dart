
import 'package:finalfyp/src/Chatbot/pneumobot_screen.dart';
import 'package:finalfyp/src/FeedbackHelp/feedback_screen.dart';
import 'package:finalfyp/src/FeedbackHelp/help_screen.dart';
import 'package:finalfyp/src/Firebase/Database.dart';
import 'package:finalfyp/src/Service/auth.dart';
import 'package:finalfyp/src/Service/user_model.dart';
import 'package:finalfyp/src/Terms&conditions/Terms&conditions.dart';
import 'package:finalfyp/src/UserRegisterationHistory/userhistory_screen.dart';
import 'package:finalfyp/src/User_profile_managment/Edit_Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserProfileService {
  /// Fetches the user data from Firestore or directly from Firebase if it's a Google user.
  /// Returns a map with keys: 'isGoogleUser', 'name', 'email', and 'imageUrl'.
  Future<Map<String, dynamic>> fetchUserData(User? user) async {
    if (user == null) {
      throw Exception("User is null");
    }
    bool isGoogleUser = user.providerData.any((info) => info.providerId == "google.com");
    if (isGoogleUser) {
      return {
        'isGoogleUser': true,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'imageUrl': user.photoURL ?? 'assets/default_profile_pic.png',
      };
    } else {
      // Fetch user data from Firestore using DatabaseMethods.
      UserModel? userModel = await DatabaseMethods().fetchUser(user.uid);
      if (userModel != null) {
        return {
          'isGoogleUser': false,
          'name': "${userModel.firstName} ${userModel.lastName}",
          'email': user.email ?? '',
          'imageUrl': userModel.profilePic,
        };
      } else {
        return {
          'isGoogleUser': false,
          'name': "No first name No last name",
          'email': user.email ?? '',
          'imageUrl': 'assets/default_profile_pic.png',
        };
      }
    }
  }

  /// Navigates to the History screen.
  void navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryScreen()),
    );
  }

  /// Navigates to the Feedback screen.
  void navigateToFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeedbackScreen()),
    );
  }

  /// Navigates to the Help screen.
  void navigateToHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpScreen()),
    );
  }

  /// Navigates to the ChatBot screen.
  void navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatBotScreen()),
    );
  }

  /// Navigates to the Terms & Conditions screen.
  void navigateToTermsConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
    );
  }

  /// Signs out the user.
  void signOut(BuildContext context) {
    AuthMethod().signOutUser(context);
  }

  /// Navigates to the EditProfileScreen.
  /// Splits the name if the user is not a Google user.
  Future<void> navigateToEditProfile(
      BuildContext context, {
        required bool isGoogleUser,
        required String name,
        required String profilePicUrl,
      }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          firstName: isGoogleUser ? name : name.split(' ').first,
          lastName: isGoogleUser
              ? ""
              : name.split(' ').length > 1 ? name.split(' ').last : "",
          profilePicUrl: profilePicUrl,
        ),
      ),
    );
  }


}

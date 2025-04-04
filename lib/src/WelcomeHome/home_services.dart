
import 'package:finalfyp/src/Service/auth.dart';
import 'package:finalfyp/src/Widgets/ShowCustomPrompt.dart';
import 'package:flutter/material.dart';

class home_services{
  void showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialogWidget(
        title: 'Login Required',
        content: 'You need to log in to access this feature. Please log in to continue.',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0D2962),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

  }
  void showConformationPrompt(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => CustomDialogWidget(
        title: 'Logout Confirmation',
        content: 'Are you sure you want to log out?',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0D2962),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              AuthMethod().signOutUser(context);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF0D2962),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

  }
}
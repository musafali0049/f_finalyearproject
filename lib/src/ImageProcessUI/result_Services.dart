import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalfyp/src/ImageProcessUI/report_screen.dart';
import 'package:finalfyp/src/Firebase/Database.dart';
import 'package:finalfyp/src/Service/result_model.dart';
import 'package:finalfyp/src/Service/user_model.dart';
import 'package:finalfyp/src/Widgets/ShowCustomPrompt.dart';

import 'package:flutter/material.dart';


class ResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseMethods _dbMethods = DatabaseMethods();

  /// Saves result data along with user details to Firestore.
  Future<void> saveResult({
    required String userId,
    required String imageUrl,
    required String displayResult,
    required String status,
  }) async {
    try {
      if (userId != "guest") {
        // Reuse DatabaseMethods to fetch user data.
        Map<String, dynamic>? userData = await _dbMethods.getUser(userId);
        if (userData == null) {
          print("User data not found for userId: $userId");
          return;
        }
        UserModel userModel = UserModel.fromMap(userData);

        // Create a ResultModel instance.
        ResultModel newResult = ResultModel(
          result: displayResult,
          status: status,
          imageUrl: imageUrl,
          timestamp: DateTime.now(),
        );

        // Save result along with user details to Firestore.
        await _firestore
            .collection("Users")
            .doc(userId)
            .collection("Results")
            .add({
          ...newResult.toMap(),
          "user": userModel.toMap(), // Include user details.
        });
      }
    } catch (e) {
      print("Error saving result to Firestore: $e");
    }
  }
  void generateReport({
    required BuildContext context,
    required String userId,
    required String imageUrl,
    required String status,
    required String result,
    required DateTime timestamp,
  }) {
    if (userId == "guest") {
      // Show a prompt if the user is not logged in.
      showDialog(
        context: context,
        builder: (context) => CustomDialogWidget(
          title: 'Login Required',
          content: 'You must be logged in to generate a report.',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0D2962),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Navigate to the ReportScreen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            userId: userId,
            imageUrl: imageUrl,
            status: status,
            result: result,
            timestamp: timestamp.toString(),
          ),
        ),
      );
    }
  }
}
// Fetch user history from Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class userHistory_services{
  Future<List<Map<String, dynamic>>> fetchUserHistory(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return []; // Return empty list if user is not authenticated
    }

    String userId = user.uid; // Current User ID
    print("Fetching history for user: $userId"); // Debugging line

    List<Map<String, dynamic>> history = [];

    try {
      // Fetching the user's results from Firestore
      QuerySnapshot resultsSnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .collection("Results")
          .orderBy("timestamp", descending: true)
          .get();

      if (resultsSnapshot.docs.isEmpty) {
        print("No history data found for user");
      }

      // Iterating over each result document to extract relevant data
      for (var doc in resultsSnapshot.docs) {
        history.add({
          'date': doc["timestamp"].toDate().toString(), // Converting timestamp to readable date
          'result': "${doc["status"]} - ${doc["result"]}",
          'imageUrl': doc["image_url"] ?? "", // Using image_url instead of imageUrl
        });
      }
    } catch (e) {
      print("Error fetching user history: $e");
    }

    return history;
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalfyp/src/Service/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userID, Map<String, dynamic> userInfoMap) async {
    try {
      await _firestore.collection("Users").doc(userID).set(userInfoMap);
      print("User added successfully to Firestore.");
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }


  Future<UserModel?> fetchUser(String uid) async {
    try {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection("Users").doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("No user found with ID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }


  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await updateUser(uid, data);
  }

  Future<Map<String, dynamic>?> getUser(String userID) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection("Users").doc(userID).get();
      return documentSnapshot.exists ? documentSnapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error retrieving user data: $e");
      return null;
    }
  }
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User is not authenticated");
      await user.updatePassword(newPassword);
      await _auth.signOut();
    } catch (e) {
      throw Exception("Password update failed: $e");
    }
  }


  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User not found");

      DocumentReference userRef = _firestore.collection('Users').doc(user.uid);

      await _deleteSubcollection(userRef, 'Results');
      await _deleteSubcollection(userRef, 'Images');
      await _deleteSubcollection(userRef, 'Feedback');
      await _deleteSubcollection(userRef, 'notifications');
      // Delete user document
      await userRef.delete();

      // Delete user profile image if exists
      await _storage
          .ref()
          .child('UserProfileImages/${user.uid}/profile_pic.jpg')
          .delete()
          .catchError((_) {}); // Ignore errors if file doesn't exist

      await user.delete();

      // Sign out the user
      await _auth.signOut();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }


  Future<void> _deleteSubcollection(DocumentReference userRef, String subcollection) async {
    QuerySnapshot snapshots = await userRef.collection(subcollection).get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> isUserVerified(String userID) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection("Users").doc(userID).get();
      return documentSnapshot.exists ? (documentSnapshot["isEmailVerified"] ?? false) : false;
    } catch (e) {
      print("Error checking email verification status: $e");
      return false;
    }
  }

  Future<void> updateEmailVerificationStatus(String userID, bool isVerified) async {
    try {
      await _firestore.collection("Users").doc(userID).update({"isEmailVerified": isVerified});
      print("Email verification status updated successfully.");
    } catch (e) {
      print("Error updating email verification status: $e");
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('Users').doc(uid).update(data);
      print("User updated successfully.");
    } catch (e) {
      print("Failed to update user: $e");
    }
  }

  static Future<String> uploadImage(String imagePath) async {
    try {
      String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceImageUploaded;
      User? user = FirebaseAuth.instance.currentUser;

      referenceImageUploaded = user != null
          ? referenceRoot.child("Users/${user.uid}/Images/$uniqueFilename")
          : referenceRoot.child("GuestUploads/$uniqueFilename");

      await referenceImageUploaded.putFile(File(imagePath));
      String imageUrl = await referenceImageUploaded.getDownloadURL();

      if (user != null) {
        await FirebaseFirestore.instance.collection("Users").doc(user.uid).collection("Images").add({
          "imageUrl": imageUrl,
          "uploadedAt": Timestamp.now(),
        });
      }
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }
}
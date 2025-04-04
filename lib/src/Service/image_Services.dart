import 'dart:io';
import 'package:finalfyp/src/Firebase/Database.dart';
import 'package:finalfyp/src/ImageProcessUI/Result_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static Future<void> uploadImageAndNavigate(BuildContext context, String imagePath) async {
    try {
      // Call the dedicated ImageServices method for image upload.
      String imageUrl = await DatabaseMethods.uploadImage(imagePath);
      print("Download URL: $imageUrl");

      User? user = FirebaseAuth.instance.currentUser;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageUrl: imageUrl,
            userId: user?.uid ?? "guest",
          ),
        ),
      );
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
    }
  }
  final ImagePicker _picker = ImagePicker();
  Future<String?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }
}

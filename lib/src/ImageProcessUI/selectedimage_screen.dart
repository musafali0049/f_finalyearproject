
import 'package:finalfyp/src/Service/image_Services.dart';
import 'package:finalfyp/src/Widgets/CustomButtons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class SelectedImageScreen extends StatefulWidget {
  final String imagePath;

  const SelectedImageScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<SelectedImageScreen> createState() => _SelectedImageScreenState();
}

class _SelectedImageScreenState extends State<SelectedImageScreen> {
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase if not already initialized.
    Firebase.initializeApp();
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      setState(() {
        isUploading = true;
      });
      // Use the service method to perform upload and navigation.
      await ImageUploadService.uploadImageAndNavigate(context, widget.imagePath);
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Asset/images/welcome.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  const SizedBox(
                    width: 300,
                    height: 80,
                    child: Text(
                      'Selected Image',
                      style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: 320,
                    height: 270,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0BEC5),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.imagePath.isNotEmpty
                          ? Image.file(File(widget.imagePath), fit: BoxFit.cover)
                          : const Text(
                        'Selected Image Appears Here',
                        style: TextStyle(
                          fontFamily: 'Poppinsregular',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  CustomElevatedButton(
                    width: 300,
                    onPressed: _uploadImageToFirebase,
                    label: 'Diagnose Image',
                    isIconButton: false,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    textStyle: const TextStyle(
                      color: Color(0xFFB0BEC5),
                      fontSize: 16,
                    ),
                    isLoading: isUploading,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

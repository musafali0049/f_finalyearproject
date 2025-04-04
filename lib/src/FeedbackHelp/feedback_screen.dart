import 'package:finalfyp/src/Widgets/CustomButtons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../User_profile_managment/user_profile.dart';


class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    String email = _emailController.text.trim();
    String feedback = _feedbackController.text.trim();

    if (email.isEmpty || feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Save feedback to Firebase Firestore
      await FirebaseFirestore.instance.collection('Feedback').add({
        'email': email,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );

      // Clear input fields
      _emailController.clear();
      _feedbackController.clear();

      // Redirect to User Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF010713),
                Color(0xFF0D2962),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Feedback',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    color: Color(0xFFB0BEC5),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFFB0BEC5)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Color(0xFFB0BEC5)),
                      hintText: 'Enter Email',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 8,
                    style: const TextStyle(color: Color(0xFFB0BEC5)),
                    decoration: InputDecoration(
                      hintText: 'Comments/Suggestions',
                      hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  width: 200,
                  onPressed: _submitFeedback,
                  label: 'Submit',
                  isIconButton: false,
                  backgroundColor: const Color(0xFFB0BEC5),
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppinsmedium',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                CustomElevatedButton(
                  width: 200,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: "Done",
                  isIconButton: false,
                  backgroundColor: const Color(0xFF0A3065),
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

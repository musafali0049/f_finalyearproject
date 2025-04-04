import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Firebase/Database.dart';
import '../WelcomeHome/home_screen.dart';
import '../Widgets/CustomAnimation.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String uid;

  const EmailVerificationScreen({Key? key, required this.email, required this.uid}) : super(key: key);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isVerified = false;
  bool isChecking = true;
  bool emailNotVerified = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
  }

  // Function to check if the email is verified.
  Future<void> _checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Polling loop until email verification is done.
    while (user != null && !user.emailVerified) {
      await Future.delayed(const Duration(seconds: 3)); // Check every 3 seconds.
      await user.reload(); // Reload user data from Firebase.
      user = FirebaseAuth.instance.currentUser; // Re-fetch the current user after reload.

      print("Checking email verification status...");

      if (user != null && user.emailVerified) {
        // Once verified, update the user's data and navigate.
        setState(() {
          isVerified = true;
          isChecking = false;
        });

        await DatabaseMethods().updateUser(widget.uid, {"emailVerified": true});

        // Ensure immediate navigation once email is verified.
        if (mounted) {
          print("Email Verified! Navigating to HomeScreen.");
          await Navigator.pushReplacement(
            context,
            CustomPageRoute(page: HomeScreen(fromLogin: false)),
          );
        }
        break;
      }
    }

    if (user != null && !user.emailVerified) {
      setState(() {
        isChecking = false;
      });
    }
  }

  // Function to resend verification email.
  Future<void> resendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          emailNotVerified = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email resent to ${widget.email}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend email: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent UI from shifting when the keyboard appears.
      resizeToAvoidBottomInset: false,
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
          child: Center(
            child: isChecking
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Checking email verification...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isVerified
                      ? 'Email Verified! Redirecting...'
                      : 'Email not verified yet.',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFB0BEC5),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resendVerificationEmail,
                  child: const Text('Resend Verification Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

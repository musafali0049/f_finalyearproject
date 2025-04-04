import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationHelper {
  // Send email verification
  Future<void> sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print("Verification email sent to ${user.email}");
      } else {
        print("User already verified or user is null.");
      }
    } catch (e) {
      print("Error sending verification email: $e");
    }
  }

  // Check if the email is verified
  Future<bool> isEmailVerified() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload(); // Reload user data
        return user.emailVerified;
      } else {
        print("No current user.");
        return false;
      }
    } catch (e) {
      print("Error checking email verification status: $e");
      return false;
    }
  }
}

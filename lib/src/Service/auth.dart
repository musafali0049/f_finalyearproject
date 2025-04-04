import 'package:finalfyp/src/UserRegisterationHistory/EmailVerification.dart';
import 'package:finalfyp/src/UserRegisterationHistory/login_screen.dart';
import 'package:finalfyp/src/Widgets/CustomAnimation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../WelcomeHome/home_screen.dart';
import 'user_model.dart'; // Your custom user model


class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Returns the current Firebase user.
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  /// Google Sign-In using the custom UserModel.
  Future<UserModel?> loginWithGoogleUnified(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In canceled.')),
        );
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        User user = userCredential.user!;

        // Check if user document exists in Firestore.
        DocumentSnapshot userDoc =
        await _firestore.collection("Users").doc(user.uid).get();

        if (!userDoc.exists) {
          // Create a new user model instance.
          UserModel newUser = UserModel(
            uid: user.uid,
            firstName: user.displayName?.split(" ").first ?? '',
            lastName: user.displayName != null && user.displayName!.contains(" ")
                ? user.displayName!.split(" ").sublist(1).join(" ")
                : '',
            email: user.email ?? '',
            profilePic: user.photoURL ?? '',
            createdAt: DateTime.now(),
          );
          // Save user data to Firestore using model's toMap().
          await _firestore.collection("Users").doc(user.uid).set(newUser.toMap());
          userDoc = await _firestore.collection("Users").doc(user.uid).get();
        }

        // Convert Firestore document to UserModel.
        UserModel existingUser =
        UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Google Sign-In Successful: ${existingUser.firstName}'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to HomeScreen.
        Navigator.pushReplacement(
          context,
          CustomPageRoute(page: HomeScreen(fromLogin: false)),
        );

        return existingUser;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In failed: User is null.')),
        );
        return null;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Error: ${e.message}')),
      );
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      return null;
    }
  }

  /// Sign up with Email and Password using the custom UserModel.
  Future<void> signUpWithEmailPassword({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      // Create a user with email and password.
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Send email verification.
        await user.sendEmailVerification();

        // Create a new user model instance.
        UserModel newUser = UserModel(
          uid: user.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          profilePic: '', // Initially empty; update later if needed.
          createdAt: DateTime.now(),
        );

        // Save user details to Firestore.
        await _firestore.collection("Users").doc(user.uid).set(newUser.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'A verification email has been sent. Please verify your email.'),
          ),
        );

        // Navigate to Email Verification Screen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(email: email, uid: user.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = e.code == 'email-already-in-use'
          ? 'This email is already registered. Try logging in.'
          : (e.message ?? 'Sign-Up failed.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }
  Future<void> authenticateUser(String currentPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User is not authenticated");

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception("Authentication failed: $e");
    }
  }

  /// Login with Email and Password.
  Future<void> loginWithEmailPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          // Navigate to HomeScreen after successful login.
          Navigator.pushReplacement(
            context,
            CustomPageRoute(page: HomeScreen(fromLogin: false)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email before logging in.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Sign out function.
  Future<void> signOutUser(BuildContext context) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
        // Navigate to LoginScreen after sign-out.
        Navigator.pushReplacement(
          context,
          CustomPageRoute(page: const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is signed in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
}

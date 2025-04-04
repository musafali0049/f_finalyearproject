import 'package:finalfyp/src/User_profile_managment/ProfileService.dart';
import 'package:finalfyp/src/Widgets/CustomButtons.dart';
import 'package:finalfyp/src/Widgets/ProfileHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  // Fetched user data.
  bool isGoogleUser = false;
  String name = '';
  String email = '';
  String imageUrl = '';

  final UserProfileService _profileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _fetchUserData();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await _profileService.fetchUserData(user);
      setState(() {
        isGoogleUser = data['isGoogleUser'] as bool;
        name = data['name'] as String;
        email = data['email'] as String;
        imageUrl = data['imageUrl'] as String;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editProfile() async {
    await _profileService.navigateToEditProfile(
      context,
      isGoogleUser: isGoogleUser,
      name: name,
      profilePicUrl: imageUrl,
    );
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFFB0BEC5),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF010713), Color(0xFF0D2962)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                ProfileHeader(
                  isGoogleUser: isGoogleUser,
                  name: name,
                  email: email,
                  imageUrl: imageUrl,
                  onEdit: _editProfile,
                ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  width: 300,
                  onPressed: _editProfile,
                  label: 'Update Profile',
                  isIconButton: false,
                  backgroundColor: const Color(0xFF0D2962),
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  textStyle: const TextStyle(
                    fontFamily: 'YourCustomFont',
                    fontSize: 16,
                    color: Color(0xFFB0BEC5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFB0BEC5), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0D2962),
                  ),
                  child: Column(
                    children: [
                      _buildNavigationTile(
                          'History',
                          Icons.history,
                              () => _profileService.navigateToHistory(context)),
                      _buildNavigationTile(
                          'Feedback',
                          Icons.feedback_outlined,
                              () => _profileService.navigateToFeedback(context)),
                      _buildNavigationTile(
                          'Help',
                          Icons.help_outline,
                              () => _profileService.navigateToHelp(context)),
                      _buildNavigationTile(
                          'Chatbot',
                          Icons.chat_bubble,
                              () => _profileService.navigateToChat(context)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFB0BEC5), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0D2962),
                  ),
                  child: Column(
                    children: [
                      _buildNavigationTile(
                          'Terms & Conditions',
                          Icons.description,
                              () => _profileService.navigateToTermsConditions(context)),
                      _buildNavigationTile(
                          'Logout',
                          Icons.logout,
                              () => _profileService.signOut(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB0BEC5)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFB0BEC5),
          fontFamily: 'Poppinsregular',
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward, color: Color(0xFFB0BEC5)),
      onTap: onTap,
    );
  }
}

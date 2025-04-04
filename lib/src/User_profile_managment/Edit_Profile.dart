// edit_profile_screen.dart
import 'dart:io';
import 'package:finalfyp/src/Service/image_Services.dart';
import 'package:finalfyp/src/Firebase/Database.dart';
import 'package:finalfyp/src/Service/auth.dart';
import 'package:finalfyp/src/Widgets/CustomButtons.dart';
import 'package:finalfyp/src/Widgets/ProfileHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? profilePicUrl;

  const EditProfileScreen({
    Key? key,
    this.firstName,
    this.lastName,
    this.profilePicUrl,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController  = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  File? _profilePic;
  bool isPasswordFieldActive = false;
  bool isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.firstName ?? '';
    lastNameController.text  = widget.lastName ?? '';
    emailController.text     = _auth.currentUser?.email ?? '';
    isGoogleUser = _auth.currentUser?.providerData.any((info) => info.providerId == 'google.com') ?? false;
  }

  // Removed permission check since it's already requested in main.dart.
  Future<void> _pickImage() async {
    String? imagePath = await ImageUploadService().pickImageFromGallery();
    if (imagePath != null) {
      setState(() {
        _profilePic = File(imagePath);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

  Widget _buildProfilePicture() {
    return ProfileHeader(
      isGoogleUser: isGoogleUser,
      name: widget.firstName ?? '',
      email: _auth.currentUser?.email ?? '',
      imageUrl: _profilePic != null
          ? _profilePic!.path
          : (widget.profilePicUrl ?? 'assets/default_profile.png'),
      onEdit: _pickImage,
    );
  }

  Future<void> _updateProfile() async {
    try {
      String? imageUrl;
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User is not authenticated");

      if (_profilePic != null) {
        final storageRef = _storage.ref().child('UserProfileImages/${user.uid}/profile_pic.jpg');
        await storageRef.putFile(_profilePic!);
        imageUrl = await storageRef.getDownloadURL();
      } else {
        imageUrl = widget.profilePicUrl;
      }

      await DatabaseMethods().updateUserProfile(user.uid, {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'profilePic': imageUrl,
      });

      if (!isGoogleUser && isPasswordFieldActive && newPasswordController.text.trim().isNotEmpty) {
        await user.updatePassword(newPasswordController.text.trim());
        await _auth.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Future<void> _authenticateAndEnablePasswordField() async {
    try {
      await AuthMethod().authenticateUser(currentPasswordController.text.trim());
      setState(() {
        isPasswordFieldActive = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication successful! Enter new password.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid password! Try again.')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await DatabaseMethods().deleteAccount();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword,
      VoidCallback? onIconPressed, {bool enabled = true, IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      style: const TextStyle(
        fontFamily: 'Poppinsregular',
        fontSize: 15,
        fontWeight: FontWeight.w200,
        color: Color(0xFFB0BEC5),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
        ),
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFFB0BEC5)) : null,
        suffixIcon: onIconPressed != null
            ? IconButton(
          icon: const Icon(Icons.check, color: Color(0xFFB0BEC5)),
          onPressed: onIconPressed,
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          user?.providerData.any((info) => info.providerId == 'google.com') ?? false
              ? 'Edit Google Profile'
              : 'Edit Profile',
          style: const TextStyle(
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF010713), Color(0xFF0D2962)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                _buildProfilePicture(),
                const SizedBox(height: 30),
                if (!isGoogleUser) ...[
                  _buildTextField('First Name', firstNameController, false, null, enabled: true),
                  const SizedBox(height: 10),
                  _buildTextField('Last Name', lastNameController, false, null, enabled: true),
                  const SizedBox(height: 10),
                  _buildTextField('Current Password', currentPasswordController, true, () {
                    _authenticateAndEnablePasswordField();
                  }),
                  const SizedBox(height: 10),
                  _buildTextField('New Password', newPasswordController, true, null, enabled: isPasswordFieldActive),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    width: 300,
                    onPressed: _updateProfile,
                    label: 'Save Changes',
                    isIconButton: false,
                    backgroundColor: const Color(0xFF0D2962),
                    borderRadius: 30,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFB0BEC5),
                      fontFamily: 'Poppinsregular',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                CustomElevatedButton(
                  width: 300,
                  onPressed: _deleteAccount,
                  label: 'Delete Account',
                  isIconButton: false,
                  backgroundColor: const Color(0xFF010713),
                  borderRadius: 15,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFB0BEC5),
                    fontFamily: 'Poppinsregular',
                    fontWeight: FontWeight.bold,
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

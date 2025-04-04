import 'dart:io';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final bool isGoogleUser;
  final String name;
  final String email;
  final String imageUrl;
  final VoidCallback onEdit;

  const ProfileHeader({
    Key? key,
    required this.isGoogleUser,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.onEdit,
  }) : super(key: key);

  ImageProvider getProfileImage() {
    if (imageUrl.isEmpty) {
      return const AssetImage('assets/default_profile_pic.png');
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: getProfileImage(),
            ),
            // Show edit icon for non-Google users only
            if (!isGoogleUser)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.camera_alt, color: Color(0xFFB0BEC5), size: 20),
                  ),
                ),
              ),
            if (isGoogleUser)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFB0BEC5),
                    child: Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFFB0BEC5),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          email,
          style: const TextStyle(
            color: Color(0xFFB0BEC5),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

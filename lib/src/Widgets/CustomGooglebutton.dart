import 'package:flutter/material.dart';

class CustomGoogleButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomGoogleButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // No shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.grey), // Grey border
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'Asset/images/google.png',
            height: 24, // Adjust icon size
            width: 24,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'PoppinsRegular',
              fontSize: 16,
              color:Color(0xFFB0BEC5),
            ),
          ),
        ],
      ),
    );
  }
}

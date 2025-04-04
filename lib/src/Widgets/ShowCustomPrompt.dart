import 'package:flutter/material.dart';

class CustomDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const CustomDialogWidget({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0D2962),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
      actions: actions,
    );
  }
}

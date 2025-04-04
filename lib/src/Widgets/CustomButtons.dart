import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double width;
  final VoidCallback onPressed;
  final IconData? icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;
  final double borderRadius;
  final bool isIconButton;
  final EdgeInsetsGeometry? padding;  // Optional parameter
  final TextStyle? textStyle;         // Optional parameter
  final bool isLoading;               // New parameter for loading logic

  const CustomElevatedButton({
    Key? key,
    required this.width,
    required this.onPressed,
    this.icon,
    required this.label,
    this.backgroundColor = const Color(0xFF0D2962),
    this.iconColor = const Color(0xFFB0BEC5),
    this.labelColor = const Color(0xFFB0BEC5),
    this.borderRadius = 30.0,
    this.isIconButton = true,
    this.padding,
    this.textStyle,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Disable button press when loading
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      width: width,
      child: isIconButton
          ? ElevatedButton.icon(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        icon: Icon(icon, color: iconColor),
        label: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
          label,
          style: textStyle ??
              TextStyle(
                fontFamily: 'Poppinsregular',
                color: labelColor,
                fontSize: 16,
              ),
        ),
      )
          : ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
          label,
          style: textStyle ??
              TextStyle(
                fontFamily: 'Poppins',
                color: labelColor,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}



class CustomCircleAvatarButton extends StatelessWidget {
  final double radius;
  final VoidCallback onTap;
  final String imagePath;
  final Color backgroundColor;
  final double imageWidth;
  final double imageHeight;

  const CustomCircleAvatarButton({
    Key? key,
    required this.radius,
    required this.onTap,
    required this.imagePath,
    this.backgroundColor = const Color(0xFFB0BEC5),
    this.imageWidth = 30,
    this.imageHeight = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: Image.asset(
          imagePath,
          width: imageWidth,
          height: imageHeight,
        ),
      ),
    );
  }
}

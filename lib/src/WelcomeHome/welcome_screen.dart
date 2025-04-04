import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../Widgets/CustomAnimation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: const Color(0xFF010713),

      ),

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('Asset/images/welcome.jpg'), // Path to the image.
              fit: BoxFit.cover, // Covers the entire screen.
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center everything vertically.
              children: [
                const SizedBox(height: 120),
                // Title
                const Text(
                  'PneumoScan',
                  style: TextStyle(
                    fontFamily: 'Poppins', // Assuming Poppins is set up in pubspec.yaml.
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB0BEC5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10), // Reduced space between title and subtitle.
                // Subtitle
                const Text(
                  'Your Respiratory health,\n simplified',
                  style: TextStyle(
                    fontFamily: 'Poppins', // Corrected font family name.
                    fontSize: 20,
                    color: Color(0xFFB0BEC5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 150), // Reduced space before the button.
                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: const HomeScreen(fromLogin: false)), // Navigate to HomeScreen.
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0BEC5), // Button color.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color(0xFF0D2962), // Dark blue text color.
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32), // Padding at the bottom.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

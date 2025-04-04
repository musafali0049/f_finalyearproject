import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Uncomment the following two lines if you want the body to extend behind the AppBar
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, ...),
      appBar: AppBar(
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 25,
            color: Color(0xFFB0BEC5),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0BEC5),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '1. Users must be registered to save their history.\n'
                              '2. Uploaded images are analyzed by our AI model.\n'
                              '3. The app stores user feedback for service improvement.\n'
                              '4. Users can download reports in PDF format.\n'
                              '5. The app provides chatbot assistance.\n'
                              '6. Users can update their profiles anytime.\n'
                              '7. Feedback is reviewed for better user experience.\n'
                              '8. Help section is available for guidance.\n',
                          style: TextStyle(
                            fontFamily: 'Poppinsregular',
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'By using this app, you agree to these terms.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

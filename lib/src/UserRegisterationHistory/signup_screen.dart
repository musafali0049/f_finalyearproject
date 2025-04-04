import 'package:flutter/material.dart';
import '../Service/auth.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomGooglebutton.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for text fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController  = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController passwordController  = TextEditingController();

  // Instance of AuthMethod for Firebase authentication
  final AuthMethod _authMethod = AuthMethod();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Loading indicator variable
  bool isLoading = false;

  /// Calls AuthMethod.signUpWithEmailPassword to perform sign up
  Future<void> signUpWithEmailPassword() async {
    setState(() {
      isLoading = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    String firstName = firstNameController.text.trim();
    String lastName  = lastNameController.text.trim();
    String email     = emailController.text.trim();
    String password  = passwordController.text.trim();

    await _authMethod.signUpWithEmailPassword(
      context: context,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> signUpWithGoogle() async {
    await _authMethod.loginWithGoogleUnified(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent UI from shifting when the keyboard appears.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontFamily: 'PoppinsMedium',
            color: Color(0xFFB0BEC5),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            backgroundColor: const Color(0xFF010713),
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 5.0,
                color: Color(0xAA000000),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0BEC5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB0BEC5),
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      hintText: 'First Name',
                      controller: firstNameController,
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Last Name',
                      controller: lastNameController,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Enter Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Enter Password',
                      controller: passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 70),
                    SizedBox(
                      width: 280,
                      child: ElevatedButton(
                        onPressed: signUpWithEmailPassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFB0BEC5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.how_to_reg,
                              color: Color(0xFF0D2962),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0D2962),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        '_______________ or _______________',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 280,
                      child: CustomGoogleButton(
                        text: 'Sign Up with Google',
                        onPressed: signUpWithGoogle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:finalfyp/src/Service/auth.dart';
import 'package:finalfyp/src/UserRegisterationHistory/forgetpasssword.dart';
import 'package:finalfyp/src/UserRegisterationHistory/signup_screen.dart';
import 'package:finalfyp/src/Widgets/CustomAnimation.dart';
import 'package:finalfyp/src/Widgets/CustomGooglebutton.dart';
import 'package:finalfyp/src/Widgets/CustomTextField.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Auth and GoogleSignIn instances are now managed inside AuthMethod.
  final AuthMethod _authMethod = AuthMethod();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Login with Email and Password using AuthMethod.
  Future<void> _loginWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      await _authMethod.loginWithEmailPassword(
        context: context,
        email: emailController.text,
        password: passwordController.text,
      );
    }
  }

  // Login with Google using AuthMethod.
  Future<void> _loginWithGoogle() async {
    await _authMethod.loginWithGoogleUnified(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent UI from shifting when the keyboard appears.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            color: Color(0xFFE3F2FD),
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE3F2FD)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF010713),
        elevation: 0,
        centerTitle: true,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          hintText: 'Enter Email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        CustomTextField(
                          hintText: 'Enter Password',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                  SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      onPressed: _loginWithEmailPassword,
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
                            Icons.login,
                            color: Color(0xFF0D2962),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Login',
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
                      '_______________ OR _______________',
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
                      text: 'Login with Google',
                      onPressed: _loginWithGoogle,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Color(0xFFB0BEC5)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CustomPageRoute(
                              page: const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFB0BEC5),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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

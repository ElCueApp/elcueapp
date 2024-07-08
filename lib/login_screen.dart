import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:elcueapp/auth_provider.dart';
import 'package:elcueapp/signup_screen.dart';
import 'package:elcueapp/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Color(0xFFFAD7DB),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'ElCue.',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0021AC),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0021AC),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField('Email', _emailController),
            SizedBox(height: 20),
            _buildTextField('Password', _passController, obscureText: true),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authProvider.signIn(
                      _emailController.text,
                      _passController.text,
                    );
                    Fluttertoast.showToast(msg: "Login Success");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    ); // MaterialPageRoute
                  } catch (e) {
                    print(e);
                    Fluttertoast.showToast(msg: "Login Failed: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 2,
                  minimumSize: Size.fromHeight(56),
                  alignment: Alignment.center,
                  foregroundColor: Color(0xFFFAD7DB),
                  backgroundColor: Color(0xFF0021AC),
                ),
                child: Text(
                  "Masuk",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFAD7DB),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Atau masuk dengan',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF0021AC),
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 65,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authProvider.signInWithGoogle();
                    Fluttertoast.showToast(msg: "Google Sign-In Success");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    ); // MaterialPageRoute
                  } catch (e) {
                    print(e);
                    Fluttertoast.showToast(msg: "Google Sign-In Failed: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/google_logo.svg',
                  height: 50,
                  width: 50,
                  color: Color(0xFF0021AC),
                ),
              ),
            ),
            SizedBox(height: 5),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text(
                'Belum punya akun? Daftar',
                style: TextStyle(
                  color: Color(0xFF0021AC),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        labelStyle: TextStyle(
          color: Color(0xFF0021AC),
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

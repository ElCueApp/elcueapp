import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:elcueapp/auth_provider.dart';
import 'package:elcueapp/login_screen.dart';
import 'package:elcueapp/sign_language_detector.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _imageUrlController.text = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Color(0xFFFAD7DB),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAD7DB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0021AC)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 90),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'ElCue.',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0021AC),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0021AC),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField('Name', _nameController),
                      SizedBox(height: 20),
                      _buildTextField('Email', _emailController),
                      SizedBox(height: 20),
                      _buildTextField('Password', _passwordController, obscureText: true),
                      SizedBox(height: 20),
                      _buildTextField('Confirm Password', _confirmPasswordController, obscureText: true),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField('Profile Image URL', _imageUrlController),
                          ),
                          IconButton(
                            icon: Icon(Icons.photo),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                await authProvider.signUp(
                                  _emailController.text,
                                  _passwordController.text,
                                  _nameController.text,
                                  _imageUrlController.text,
                                );
                                Fluttertoast.showToast(msg: "Sign Up Success");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              } catch (e) {
                                print(e);
                                Fluttertoast.showToast(msg: "Sign Up Failed: $e");
                              }
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
                            "Daftar",
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
                        'Atau daftar dengan',
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
                          onPressed: () {
                            // Add Google sign-in logic here
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
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

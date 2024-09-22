import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Register user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Save additional user information in Firestore
      await _firestore.collection('users').doc(emailController.text).set({
        'name': nameController.text,
        'email': emailController.text,
        'age': ageController.text,
        'phone': phoneController.text,
        'createdAt': DateTime.now(),
      });

      // Show success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration successful')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          'Register Account',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                'Create an account',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person,
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                controller: emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                controller: ageController,
                label: 'Age',
                icon: Icons.cake,
              ),
              SizedBox(height: 10.h),
              _buildTextField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 30.h),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Navigate to login screen
                },
                child: Text(
                  'Already have an account? Log in',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
      ),
      style: TextStyle(fontSize: 16.sp),
    );
  }
}

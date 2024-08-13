import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  
  bool _isPasswordWeak(String password) {
    // Check password length 8 characters
    if (password.length < 8) return true;

    //  one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);

    return !(hasLetter && hasDigit);
  }

  // check the username is valid
  bool _isUsernameValid(String username) {
    //at least one letter and can include numbers,
    final usernameRegex = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9]+$');
    return usernameRegex.hasMatch(username);
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Save the username in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'username': _usernameController.text.trim(),
          });

          // Navigate to the feed screen
          Get.offAllNamed('/feed');
        }
      } catch (e) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Username TextField with validation
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  if (!_isUsernameValid(value)) {
                    return 'Username must contain letters and can include numbers, but not just numbers';
                  }
                  return null;
                },
              ),
              // Email TextField with validation
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              // Password TextField with validation
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (_isPasswordWeak(value)) {
                    return 'Password must be at least 8 characters long and include both letters and numbers.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

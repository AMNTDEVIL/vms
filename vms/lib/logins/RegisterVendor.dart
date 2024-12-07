import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterVendorScreen extends StatefulWidget {
  const RegisterVendorScreen({super.key});

  @override
  _RegisterVendorScreenState createState() => _RegisterVendorScreenState();
}

class _RegisterVendorScreenState extends State<RegisterVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to register vendor and store in Firestore
  Future<void> _registerVendor() async {
    try {
      // Create user using Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the Firebase user
      User? user = userCredential.user;

      // If registration successful, save vendor data to Firestore
      if (user != null) {
        // Prepare vendor data
        Map<String, dynamic> vendorData = {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'uid': user.uid, // Store Firebase Auth UID as a reference
          'profilePictureUrl': '', // Add default empty profile picture URL
          'createdAt': Timestamp.now(),
          'status': 'unblocked', // Set initial status to "unblocked"
        };

        // Save to Firestore in the 'vendors' collection
        await _firestore.collection('vendors').doc(user.uid).set(vendorData);

        // Show success message and navigate to another screen if needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor registered successfully!')),
        );

        // Optional: Navigate to another page (e.g., admin dashboard)
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle error (e.g., if user already exists)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Vendor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _registerVendor();
                  }
                },
                child: const Text('Register Vendor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

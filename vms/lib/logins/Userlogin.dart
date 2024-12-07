import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _checkIfUserLoggedIn();
  }

  // Check if user is already logged in
  Future<void> _checkIfUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email');
    String? userUID = prefs.getString('user_uid');

    if (userEmail != null && userUID != null) {
      // If the user is logged in, navigate to the dashboard screen
      Navigator.pushReplacementNamed(context, 'user_dashboard');
    }
  }

  // Log the user in
  Future<void> loginUser() async {
    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Once logged in, save user email and UID to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email); // Save email
      await prefs.setString('user_uid', userCredential.user!.uid); // Save UID

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Successful!')),
      );

      // Navigate to the user dashboard screen after successful login
      Navigator.pushReplacementNamed(context, 'user_dashboard');
    } on FirebaseAuthException catch (e) {
      String message;
      // Check for specific FirebaseAuth exceptions
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = 'Login failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Email input field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // Password input field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Login button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    loginUser();
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              // "Not an account? Register" link
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context,
                      'user_registration'); // Navigate to registration screen
                },
                child: const Text("Not an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

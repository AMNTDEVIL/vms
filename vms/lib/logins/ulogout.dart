import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogOutScreen extends StatelessWidget {
  const UserLogOutScreen({super.key});

  // Logout function
  Future<void> logout(BuildContext context) async {
    try {
      // Clear session data from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out the user from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Show a logout success message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logged out successfully!')));

      // Navigate back to login screen after logout
      Navigator.pushReplacementNamed(
          context, 'homepage'); // Replace with your login screen route
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Call the logout function when button is pressed
            logout(context);
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}

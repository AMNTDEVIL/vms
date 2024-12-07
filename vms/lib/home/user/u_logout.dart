import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLogOutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Clear the user data stored in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear(); // Clears all stored keys

            // Log out from Firebase
            await FirebaseAuth.instance.signOut();

            // Debugging log to confirm logout
            print("User logged out!");

            // Navigate to the homepage, replacing the current route
            Navigator.pushReplacementNamed(context, 'homepage');
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}

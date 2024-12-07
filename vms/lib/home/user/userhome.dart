import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String userStatus = ''; // To store the user status
  late String userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Get the current user ID from Firebase Authentication
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isNotEmpty) {
      _fetchUserStatus();
    }
  }

  // Fetch user status from Firestore
  Future<void> _fetchUserStatus() async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          userStatus = userDoc['status'] ?? 'unblocked';
        });

        // If the user's status is blocked, show the popup
        if (userDoc['status'] == 'blocked') {
          _showBlockedDialog();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in Firestore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user status: $e')),
      );
    }
  }

  // Function to show the blocked dialog
  void _showBlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Blocked',
              style: TextStyle(color: Colors.red)),
          content: const Text(
            'Your account is blocked.\nPlease contact our company at potatopc@gmail.com.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Log out the user and navigate to the login screen
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, 'userlogout');
            },
          ),
        ],
      ),
      body: userStatus == 'blocked'
          ? const Center(
              child: Text(
                'Account blocked. Contact support.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Services section
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.home, color: Colors.blue),
                      title: const Text('Services',
                          style: TextStyle(fontSize: 18)),
                      onTap: () {
                        Navigator.pushNamed(context, 'services_screen');
                      },
                    ),
                  ),
                  // Find Vendor section
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.search, color: Colors.blue),
                      title: const Text('Find Vendor',
                          style: TextStyle(fontSize: 18)),
                      onTap: () {
                        Navigator.pushNamed(context, 'display_vendors');
                      },
                    ),
                  ),
                  // About Us section
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.info_outline, color: Colors.blue),
                      title: const Text('About Us',
                          style: TextStyle(fontSize: 18)),
                      onTap: () {
                        Navigator.pushNamed(context, 'about_us');
                      },
                    ),
                  ),
                  // Logout section
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading:
                          const Icon(Icons.exit_to_app, color: Colors.blue),
                      title:
                          const Text('Logout', style: TextStyle(fontSize: 18)),
                      onTap: () {
                        // Log out the user
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, 'userlogout');
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

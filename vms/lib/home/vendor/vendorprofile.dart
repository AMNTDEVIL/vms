import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  _VendorProfileScreenState createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  String username = "";
  String email = "";
  String createdAt = "";
  bool isEditing = false;
  bool isChangingPassword =
      false; // To track the change password section visibility

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('vendor_email'); // Use 'vendor_email'

    if (storedEmail != null) {
      try {
        var user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Fetch the vendor profile from Firestore
          var snapshot = await FirebaseFirestore.instance
              .collection(
                  'vendors') // Ensure collection name is lowercase 'vendors'
              .doc(user.uid)
              .get();

          if (snapshot.exists) {
            setState(() {
              username = snapshot['username'] ?? '';
              email = snapshot['email'] ?? '';
              createdAt = snapshot['createdAt'] != null
                  ? (snapshot['createdAt'] as Timestamp).toDate().toString()
                  : 'Not Available';

              // Update controllers with fetched values
              usernameController.text = username;
              emailController.text = email;
            });
          } else {
            print("No document found for the current user.");
          }
        } else {
          print("No user is logged in.");
        }
      } catch (e) {
        print('Error fetching profile: $e');
      }
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        saveProfile();
      }
    });
  }

  Future<void> saveProfile() async {
    try {
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Save the updated data in Firestore
        await FirebaseFirestore.instance
            .collection('vendors')
            .doc(user.uid)
            .update({
          'username': usernameController.text,
          'email': emailController.text,
        });

        // Save the email to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('vendor_email', emailController.text);

        setState(() {
          username = usernameController.text;
          email = emailController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<void> changePassword() async {
    try {
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Reauthenticate the user before changing the password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Change password
        await user.updatePassword(newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully!')),
        );

        // Reset the controllers
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        setState(() {
          isChangingPassword = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $e')),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Profile'),
        actions: [
          isEditing
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    saveProfile();
                    setState(() {
                      isEditing = false;
                    });
                    Navigator.pushReplacementNamed(context, '/vendorDashboard');
                  },
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: toggleEditMode,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: username.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  ProfileField(
                    label: 'Username',
                    controller: usernameController,
                    isEditing: isEditing,
                  ),
                  ProfileField(
                    label: 'Email',
                    controller: emailController,
                    isEditing: isEditing,
                  ),
                  ProfileField(
                    label: 'Created At',
                    controller: TextEditingController(text: createdAt),
                    isEditing: false,
                  ),
                  // Change Password Section
                  if (isEditing || isChangingPassword)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: currentPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (newPasswordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'New password and confirm password do not match!'),
                                  ),
                                );
                              } else {
                                changePassword(); // Change password
                              }
                            },
                            child: Text('Change Password'),
                          ),
                        ],
                      ),
                    ),
                  // OK Button at the bottom
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          saveProfile(); // Save profile when pressed
                          setState(() {
                            isEditing = false; // Exit edit mode
                          });
                          Navigator.pushReplacementNamed(context,
                              "/vendor_dashboard"); // Navigate to VendorDashboard
                        },
                        child: Text("OK"),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;

  const ProfileField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: controller,
            readOnly: !isEditing,
            obscureText: label == 'Password', // Hide password if editing
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter $label',
            ),
          ),
        ],
      ),
    );
  }
}

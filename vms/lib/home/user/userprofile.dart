import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = "";
  String email = "";
  String address = "";
  String gender = "";
  bool isEditing = false;
  bool isChangingPassword = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController genderController;

  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();
    genderController = TextEditingController();

    // Initialize password change controllers
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    fetchProfile();
  }

  // Fetch user profile data from Firestore
  Future<void> fetchProfile() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Fetch user data from Firestore's 'users' collection
        var docSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (docSnapshot.exists) {
          var userData = docSnapshot.data()!;
          setState(() {
            name = userData['name'] ?? '';
            email = userData['email'] ?? '';
            address = userData['address'] ?? '';
            gender = userData['gender'] ?? '';
            nameController.text = name;
            emailController.text = email;
            addressController.text = address;
            genderController.text = gender;
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  // Toggle between editing mode
  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        saveProfile(); // Save profile if exiting edit mode
      }
    });
  }

  // Save the updated profile information to Firestore
  Future<void> saveProfile() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Update the user data in Firestore's 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': nameController.text,
          'email': emailController.text,
          'address': addressController.text,
          'gender': genderController.text,
        });

        setState(() {
          name = nameController.text;
          email = emailController.text;
          address = addressController.text;
          gender = genderController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  // Change the password
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

        // Check if new password and confirm password match
        if (newPasswordController.text == confirmPasswordController.text) {
          await user.updatePassword(newPasswordController.text);

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password changed successfully!')));

          // Reset password change form
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();

          setState(() {
            isChangingPassword = false;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Passwords do not match!')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password: $e')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    genderController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          isEditing
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    saveProfile();
                    setState(() {
                      isEditing = false;
                    });
                    Navigator.pushReplacementNamed(context, '/userDashboard');
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
        child: name.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  ProfileField(
                    label: 'Name',
                    controller: nameController,
                    isEditing: isEditing,
                  ),
                  ProfileField(
                    label: 'Email',
                    controller: emailController,
                    isEditing: isEditing,
                  ),
                  ProfileField(
                    label: 'Address',
                    controller: addressController,
                    isEditing: isEditing,
                  ),
                  ProfileField(
                    label: 'Gender',
                    controller: genderController,
                    isEditing: isEditing,
                  ),
                  // Show the password change section if in editing mode
                  if (isEditing || isChangingPassword)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Change Password',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
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
                            onPressed: changePassword,
                            child: Text('Change Password'),
                          ),
                        ],
                      ),
                    ),
                  // OK Button at the bottom to save and exit
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
                              '/userDashboard'); // Navigate to UserDashboard
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

// Widget for individual profile fields (name, email, etc.)
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

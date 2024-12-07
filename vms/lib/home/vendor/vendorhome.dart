import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VendorDashboard1 extends StatelessWidget {
  const VendorDashboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, 'logout');
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            // If user is not logged in, navigate to the login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, 'login');
            });
            return const Center(child: Text('User is not logged in.'));
          }

          // If the user is logged in, show the dashboard
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                // Profile Summary
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: const Text('Vendor Profile'),
                    subtitle: const Text('Update your profile details'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, 'vendor_profile');
                    },
                  ),
                ),

                // Product Management
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Manage Products'),
                    subtitle: const Text('Add, edit, or remove products'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, 'manage_product');
                    },
                  ),
                ),

                // Orders Management
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('View Orders'),
                    subtitle: const Text('Check order status and details'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, 'view_orders');
                    },
                  ),
                ),

                // Inventory Management
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning),
                    title: const Text('Inventory Management'),
                    subtitle: const Text(
                        'Track stock levels and low inventory alerts'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, 'inventorymgmt');
                    },
                  ),
                ),

                // Notifications
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Logout'),
                    subtitle: const Text('Logging out'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(context, 'logout');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Function to check if user is logged in
  Future<User?> _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }
}

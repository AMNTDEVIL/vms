import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_id'); // Remove admin_id from SharedPreferences
    Navigator.pushReplacementNamed(
        context, 'admin_login'); // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false, // Hide back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            const Center(
              child: Text(
                "Welcome Admin",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options List
            Expanded(
              child: ListView(
                children: [
                  // Register New Admin
                  ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.green),
                    title: const Text(
                      "Register New Admin",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, 'admin_register');
                    },
                  ),

                  // View Vendors
                  ListTile(
                    leading: const Icon(Icons.store, color: Colors.orange),
                    title: const Text(
                      "View Vendors",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, 'view_vendors');
                    },
                  ),

                  // View Users
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.blue),
                    title: const Text(
                      "View Users",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/view_users');
                    },
                  ),

                  // View Trades
                  ListTile(
                    leading: const Icon(Icons.swap_horiz, color: Colors.purple),
                    title: const Text(
                      "View Trades",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/view_trades');
                    },
                  ),

                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () => logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

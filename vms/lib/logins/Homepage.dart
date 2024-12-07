import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Add a clean background color
      appBar: AppBar(
        title: const Text("Login Options",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor:
            Colors.blueAccent, // AppBar with a color for consistency
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(
              20), // Add padding to the container for better spacing
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center items in the column
              children: <Widget>[
                const SizedBox(height: 40),

                // GestureDetector to make the text clickable and navigate to Admin login
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context,
                        'admin_login'); // Navigate to admin login screen
                  },
                  child: const Text(
                    "Choose to Login",
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent, // Set color for the main title
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Vendor Login
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'vendor_login');
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[
                              50], // Light background color for Vendor card
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.storefront, // Vendor Icon
                              size: 100,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Vendor",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // User Login
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'user_login');
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[
                              50], // Light background color for User card
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person, // User Icon
                              size: 100,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "User",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

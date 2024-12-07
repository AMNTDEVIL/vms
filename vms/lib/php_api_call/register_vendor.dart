import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterVendor extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  RegisterVendor({super.key});

  Future<void> registerVendor(BuildContext context) async {
    const String url =
        'http://localhost/flutter_api/vendor_register.php'; // Replace with your IP address if needed

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'email': emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final message = responseData['message'] ?? 'Registration successful';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      // Optionally, clear the fields or navigate to another page
      usernameController.clear();
      passwordController.clear();
      emailController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to register. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Registration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Username",
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Password",
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Email",
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  registerVendor(context); // Pass context for Snackbar
                },
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

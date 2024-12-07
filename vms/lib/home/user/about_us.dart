import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Title
            Text(
              'Vendor Management System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Description
            Text(
              'The Vendor Management System is designed to help businesses efficiently manage their vendors. The system enables easy addition, updating, and tracking of vendor information. Our platform offers intuitive tools for vendor selection, performance tracking, and contract management. Whether you are managing a few or hundreds of vendors, this system streamlines the process and ensures transparency and efficiency.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),

            // Image 1
            Image.asset('images/pic1.png'),
            SizedBox(height: 20),

            // Image 2
            Image.asset('images/pic2.png'),
            SizedBox(height: 20),

            // Image 3
            Image.asset('images/pic3.png'),
            SizedBox(height: 20),

            // Additional Description
            Text(
              'A Vendor Management System (VMS) is a software platform or process that helps businesses effectively manage their relationships with external vendors or suppliers. It streamlines vendor operations and optimizes the entire lifecycle of a vendor relationship, from selection and onboarding to performance monitoring and contract management.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            Container(
              color: Colors.blueGrey[100],
              padding: EdgeInsets.all(8.0),
              child: Text(
                'For more information, contact us at: pratikmaharjan323@gmail.com',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

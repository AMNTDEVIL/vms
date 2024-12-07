import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vms/home/user/display_products.dart';

class DisplayVendorsScreen extends StatelessWidget {
  const DisplayVendorsScreen({super.key});

  // Method to fetch vendor data from Firestore
  Future<List<Map<String, dynamic>>> fetchVendors() async {
    try {
      // Fetching vendor data from the correct Firestore collection
      var querySnapshot = await FirebaseFirestore.instance
          .collection('vendors') // Ensure this is the correct collection name
          .get();

      // Convert the querySnapshot to a list of Map objects
      List<Map<String, dynamic>> vendors = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return vendors;
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Vendors'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVendors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vendors available.'));
          }

          // If vendors data is available
          List<Map<String, dynamic>> vendors = snapshot.data!;

          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              var vendor = vendors[index];
              return ListTile(
                leading: const Icon(Icons.store), // Icon for the vendor
                title: Text(vendor['username'] ?? 'No Name'),
                subtitle: Text(vendor['email'] ??
                    'No Email'), // Adjust field names as needed
                onTap: () {
                  // Navigate to DisplayVendorProductsScreen with the vendor's username
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorProductsScreen(
                        vendorUsername: vendor['username'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

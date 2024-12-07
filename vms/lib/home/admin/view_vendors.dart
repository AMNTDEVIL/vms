import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewVendorsPage extends StatefulWidget {
  const ViewVendorsPage({super.key});

  @override
  _ViewVendorsPageState createState() => _ViewVendorsPageState();
}

class _ViewVendorsPageState extends State<ViewVendorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Vendors"),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vendors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No vendors found."),
            );
          }

          final vendors = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              var vendor = vendors[index];
              String vendorId = vendor.id;
              String username = vendor['username'] ?? 'Unknown';
              String email = vendor['email'] ?? 'No email';
              String status = vendor['status'] ?? 'unblocked';
              Timestamp createdAt = vendor['createdAt'];
              String formattedDate = DateFormat('dd MMM yyyy')
                  .format(createdAt.toDate()); // Format createdAt timestamp

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(username),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: $email"),
                      Text("Created At: $formattedDate"),
                      Text("Status: ${status.toUpperCase()}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          status == 'blocked' ? Colors.green : Colors.red,
                    ),
                    onPressed: () => toggleVendorStatus(vendorId, status),
                    child: Text(
                      status == 'blocked' ? "Unblock" : "Block",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Toggle vendor status between 'blocked' and 'unblocked'
  Future<void> toggleVendorStatus(String vendorId, String currentStatus) async {
    try {
      String newStatus = currentStatus == 'blocked' ? 'unblocked' : 'blocked';
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vendor status updated to $newStatus."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

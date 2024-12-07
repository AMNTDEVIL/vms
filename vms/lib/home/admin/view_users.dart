import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  _ViewUsersScreenState createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to toggle user status
  Future<void> _toggleUserStatus(String uid, String currentStatus) async {
    try {
      // Update status field in Firestore
      await _firestore.collection('users').doc(uid).update({
        'status': currentStatus == 'unblocked' ? 'blocked' : 'unblocked',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User status updated to ${currentStatus == 'unblocked' ? 'blocked' : 'unblocked'}'),
        ),
      );

      // Trigger UI update
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Users')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          // Get user documents
          var userDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              var user = userDocs[index].data() as Map<String, dynamic>;
              String uid = userDocs[index].id; // Document ID
              String status = user['status'] ?? 'unblocked';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    user['name'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user['email'] ?? 'N/A'}'),
                      Text('Gender: ${user['gender'] ?? 'N/A'}'),
                      Text('Address: ${user['address'] ?? 'N/A'}'),
                      Text(
                          'Created At: ${(user['createdAt'] as Timestamp).toDate()}'),
                      Text('Status: ${status.toUpperCase()}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _toggleUserStatus(uid, status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          status == 'unblocked' ? Colors.red : Colors.green,
                    ),
                    child: Text(
                      status == 'unblocked' ? 'Block' : 'Unblock',
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
}

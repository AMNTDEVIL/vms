import 'package:flutter/material.dart';

class DeleteProductScreen extends StatelessWidget {
  const DeleteProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Implement delete product functionality
            TextField(
              decoration:
                  InputDecoration(labelText: 'Enter Product ID to Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement product deletion functionality here
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product deleted successfully!')));
              },
              child: const Text('Delete Product'),
            ),
          ],
        ),
      ),
    );
  }
}

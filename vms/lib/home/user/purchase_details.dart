import 'package:flutter/material.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final String productId;
  final double quantity;
  final double total;
  final String userName;

  const PurchaseDetailsScreen({
    super.key,
    required this.productId,
    required this.quantity,
    required this.total,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product ID: $productId',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Quantity: $quantity', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Total Price: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Vendor: $userName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
                child: const Text('Back to Products'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

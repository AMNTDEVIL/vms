import 'package:flutter/material.dart';

class OrderStore extends StatelessWidget {
  final String productId;
  final double quantity;
  final double total;
  final String userName;
  final String name;

  const OrderStore({
    super.key,
    required this.productId,
    required this.quantity,
    required this.total,
    required this.userName,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Product ID: $productId'),
            Text('Quantity: $quantity'),
            Text('Total: \$${total.toStringAsFixed(2)}'),
            Text('User Name: $name'),
            Text('Vendor: $userName'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back or go to the home screen
                Navigator.pop(context);
              },
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

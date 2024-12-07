import 'package:flutter/material.dart';

class OrderLogDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> logDetails;

  const OrderLogDetailsScreen({Key? key, required this.logDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Log Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${logDetails['orderId']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Product Name: ${logDetails['productName']}"),
            Text("Quantity: ${logDetails['quantity']}"),
            Text("Status: ${logDetails['status']}"),
            Text("Timestamp: ${logDetails['timestamp'].toDate()}"),
            Text("Total Price: \$${logDetails['totalPrice']}"),
            Text("User Name: ${logDetails['userName']}"),
            Text("Vendor Name: ${logDetails['vendorName']}"),
          ],
        ),
      ),
    );
  }
}

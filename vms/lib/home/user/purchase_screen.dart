import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchaseScreen extends StatefulWidget {
  final String productId;
  final int productPrice;
  final String name; // User's name
  final String vendorName; // Vendor's name (new parameter)

  const PurchaseScreen({
    super.key,
    required this.productId,
    required this.productPrice,
    required this.name,
    required this.vendorName, // Receive vendor name here
  });

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController quantityController = TextEditingController();
  double total = 0.0;

  void calculateTotal() {
    double quantity = double.tryParse(quantityController.text) ?? 0.0;
    setState(() {
      total = quantity * widget.productPrice.toDouble();
    });
  }

  Future<void> purchaseProduct() async {
    double quantity = double.tryParse(quantityController.text) ?? 0.0;

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    try {
      // Add order to Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'productId': widget.productId,
        'userName': widget.name, // Using 'name' here
        'vendorName': widget.vendorName, // Saving vendor's name
        'quantity': quantity,
        'total': total,
        'purchaseDate': Timestamp.now(),
        'status': 'pending', // Set the status as 'pending' initially
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase successful")),
      );

      Navigator.pop(
          context); // Go back to the previous screen or add navigation logic
    } catch (e) {
      print("Error during purchase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during purchase: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Product'),
      ),
      resizeToAvoidBottomInset:
          true, // This is critical for preventing overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Quantity', style: TextStyle(fontSize: 18)),
              TextField(
                controller: quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter quantity',
                ),
                onChanged: (value) => calculateTotal(),
              ),
              const SizedBox(height: 20),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: purchaseProduct,
                  child: const Text('Confirm Purchase'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

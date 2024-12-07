import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewProductScreen extends StatefulWidget {
  @override
  _ViewProductScreenState createState() => _ViewProductScreenState();
}

class _ViewProductScreenState extends State<ViewProductScreen> {
  // This list will hold the filtered products (quantity < 15)
  List<QueryDocumentSnapshot> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Fetch products from Firestore
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      // Filter products where quantity is less than 15
      List<QueryDocumentSnapshot> filtered = snapshot.docs.where((doc) {
        return doc['quantity'] < 15;
      }).toList();

      setState(() {
        _filteredProducts = filtered;
      });
    } catch (e) {
      // Handle error if fetching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products with less quantity'),
      ),
      body: _filteredProducts.isEmpty
          ? Center(
              child: Text('No products available with quantity less than 15'))
          : ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                var product = _filteredProducts[index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text('Quantity: ${product['quantity']}'),
                  trailing: Text('\$${product['price']}'),
                );
              },
            ),
    );
  }
}

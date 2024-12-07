import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(); // Controller for quantity
  String? _selectedCategory; // Selected category

  // List of categories to choose from
  final List<String> _categories = [
    'Laptops',
    'Computers',
    'Fruits',
    'Vegetables',
    'Watches'
  ];

  Future<void> addProduct() async {
    try {
      String name = _nameController.text.trim();
      String description = _descriptionController.text.trim();
      String priceText = _priceController.text.trim();
      String quantityText =
          _quantityController.text.trim(); // Get quantity input

      // Input validation
      if (name.isEmpty ||
          description.isEmpty ||
          priceText.isEmpty ||
          quantityText.isEmpty ||
          _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      double price;
      int quantity;
      try {
        price = double.parse(priceText);
        quantity = int.parse(quantityText); // Parse quantity as an integer
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid price or quantity format')),
        );
        return;
      }

      // Debugging: Print values to the console
      print(
          'Name: $name, Description: $description, Price: $price, Quantity: $quantity, Category: $_selectedCategory');

      // Add product to Firestore with category and quantity
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity, // Add quantity
        'category': _selectedCategory, // Add selected category
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added successfully!')),
      );
      Navigator.pop(context); // Go back after adding
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            SizedBox(height: 20),
            // Dropdown to select category
            DropdownButton<String>(
              hint: Text('Select Category'),
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}

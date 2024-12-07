import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vms/home/vendor/inventory/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  String? _selectedCategory; // Store the selected category

  // List of categories
  final List<String> _categories = [
    'Laptops',
    'Computers',
    'Fruits',
    'Vegetables',
    'Watches',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with product data or empty strings
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(
        text: widget.product?.toMap()['quantity']?.toString() ?? '');
    _selectedCategory = widget.product?.category ??
        (_categories.isNotEmpty
            ? _categories[0]
            : null); // Default to first category
  }

  Future<void> updateProduct() async {
    try {
      // Collect and validate input
      String name = _nameController.text.trim();
      String description = _descriptionController.text.trim();
      String priceText = _priceController.text.trim();
      String quantityText = _quantityController.text.trim();

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
        quantity = int.parse(quantityText);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid price or quantity format')),
        );
        return;
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product?.id)
          .update({
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': _selectedCategory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pop(context); // Navigate back after successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              DropdownButton<String>(
                hint: Text('Select Category'),
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProduct,
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

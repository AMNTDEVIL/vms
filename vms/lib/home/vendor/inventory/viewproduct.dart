import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vms/home/vendor/inventory/editproduct.dart';
import 'package:vms/home/vendor/inventory/product.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Stream<QuerySnapshot> productStream =
      FirebaseFirestore.instance.collection('products').snapshots();

  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String sortOption = 'name';

  List<Product> filterAndSortProducts(List<Product> products) {
    var filteredProducts = products
        .where((product) =>
            product.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // Sort products based on the selected option
    if (sortOption == 'price') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == 'name') {
      filteredProducts.sort((a, b) => a.name.compareTo(b.name));
    }

    return filteredProducts;
  }

  // Method to delete a product
  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          DropdownButton<String>(
            value: sortOption,
            onChanged: (newValue) {
              setState(() {
                sortOption = newValue!;
              });
            },
            items: [
              DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
              DropdownMenuItem(value: 'price', child: Text('Sort by Price')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available.'));
                }

                var products = snapshot.data!.docs.map((doc) {
                  return Product.fromFirestore(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                var displayedProducts = filterAndSortProducts(products);

                return ListView.builder(
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    var product = displayedProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                          'Price: \$${product.price}\nCategory: ${product.category}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProductScreen(product: product),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteProduct(product.id);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProductScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

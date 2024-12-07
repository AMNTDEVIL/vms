import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vms/home/user/purchase_screen.dart';

class VendorProductsScreen extends StatelessWidget {
  final String vendorUsername;

  const VendorProductsScreen({super.key, required this.vendorUsername});

  Future<List<Map<String, dynamic>>> fetchVendorProducts() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('put_by',
              isEqualTo: vendorUsername) // Fetch products by vendor
          .get();

      List<Map<String, dynamic>> products = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add product ID
        return data;
      }).toList();

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Function to get the user's name from SharedPreferences or Firestore
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUID = prefs.getString('user_uid');
    if (userUID != null) {
      // If UID is available, fetch user info from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .get();
      return userDoc['name'] ?? 'Unknown'; // Retrieve the name of the user
    }
    return 'Unknown'; // Return default name if UID is not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$vendorUsername\'s Products'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVendorProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          List<Map<String, dynamic>> products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(product['name'] ?? 'No Name'),
                subtitle: Text('Price: \$${product['price'] ?? 0}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    String userName =
                        await getUserName(); // Get user name from SharedPreferences or Firestore
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseScreen(
                          productId: product['id'], // Product ID
                          productPrice: product['price'], // Product price
                          name: userName, // Pass the user's name here
                          vendorName: vendorUsername, // Pass vendor's name here
                        ),
                      ),
                    );
                  },
                  child: const Text('Purchase'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String userEmail = ''; // Store user email
  String userName = ''; // Store user name

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
  }

  // Fetch user orders based on userEmail from SharedPreferences
  Future<void> fetchUserOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('user_email') ??
        ''; // Retrieve userEmail from SharedPreferences

    if (userEmail.isNotEmpty) {
      try {
        // Fetch user name from the 'users' collection where user_email matches
        var userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Assuming user name is in the 'name' field of the user document
          userName = userSnapshot.docs.first['name'];

          // Now fetch orders from the 'orders' collection where userName matches
          var orderSnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('userName',
                  isEqualTo: userName) // Query orders where userName matches
              .get();

          print(
              'Fetched ${orderSnapshot.docs.length} orders for user: $userName');

          if (orderSnapshot.docs.isNotEmpty) {
            setState(() {
              orders = orderSnapshot.docs.map((doc) {
                return doc.data() as Map<String, dynamic>;
              }).toList();
              isLoading = false;
            });
          } else {
            setState(() {
              orders = [];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
          });
          print('No user found for email: $userEmail');
        }
      } catch (e) {
        print('Error fetching user data or orders: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('No userEmail found in SharedPreferences.');
    }
  }

  // Helper method to format the date
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    return ListTile(
                      title: Text('Product ID: ${order['productId']}'),
                      subtitle: Text(
                        'Purchase Date: ${formatDate(order['purchaseDate'])}\nQuantity: ${order['quantity']}\nStatus: ${order['status']}\nTotal: \$${order['total']}\nVendor: ${order['vendorName']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        // Navigate to order details on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderId: order['orderId'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  // Helper method to format the date
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(dateTime); // Adjust format as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('orders').doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product ID: ${orderData['productId']}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Purchase Date: ${formatDate(orderData['purchaseDate'])}'),
                SizedBox(height: 10),
                Text('Quantity: ${orderData['quantity']}'),
                SizedBox(height: 10),
                Text('Status: ${orderData['status']}'),
                SizedBox(height: 10),
                Text('Total: \$${orderData['total']}'),
                SizedBox(height: 20),
                Text('Vendor Name: ${orderData['vendorName']}',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}

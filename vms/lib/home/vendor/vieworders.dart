import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({Key? key}) : super(key: key);

  @override
  _VendorOrdersScreenState createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  bool isLoading = true;
  String vendorName = '';
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchVendorNameAndOrders();
  }

  // Fetch Vendor's Name from SharedPreferences and Orders from Firestore
  Future<void> _fetchVendorNameAndOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vendorUID = prefs.getString('vendor_uid');

    if (vendorUID != null) {
      try {
        // Fetch vendor name
        DocumentSnapshot vendorDoc = await FirebaseFirestore.instance
            .collection('vendors')
            .doc(vendorUID)
            .get();

        if (vendorDoc.exists) {
          vendorName =
              vendorDoc['username']; // Assuming the field is 'username'

          // Fetch vendor's orders
          QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('vendorName', isEqualTo: vendorName)
              .get();

          if (orderSnapshot.docs.isNotEmpty) {
            List<Map<String, dynamic>> fetchedOrders = [];

            for (var doc in orderSnapshot.docs) {
              String productId = doc['productId'];
              // Fetch product name dynamically from products collection
              DocumentSnapshot productDoc = await FirebaseFirestore.instance
                  .collection('products')
                  .doc(productId)
                  .get();

              String productName = productDoc.exists
                  ? productDoc['name'] // Assuming field is 'name'
                  : 'Unknown Product';

              fetchedOrders.add({
                'productId': productId,
                'productName': productName,
                'purchaseDate': doc['purchaseDate'].toDate(),
                'quantity': doc['quantity'],
                'total': doc['total'],
                'userName': doc['userName'],
                'orderId': doc.id,
                'status': doc['status']?.toString() ?? 'pending',
              });
            }

            setState(() {
              orders = fetchedOrders;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No orders found for $vendorName")),
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vendor not found")),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching vendor or orders: $e")),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vendor UID not found")),
      );
    }
  }

  // Function to handle Accept and Reject actions
  Future<void> _updateOrderStatus(
      String orderId, String newStatus, Map<String, dynamic> order) async {
    try {
      // Update order status in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'actionTakenBy': vendorName,
        'actionDate': Timestamp.now(),
      });

      String message =
          "Vendor $vendorName ${newStatus.toLowerCase()} user ${order['userName']}'s order of ${order['productName']} (Quantity: ${order['quantity']}) at price \$${order['total']}.";

      await FirebaseFirestore.instance.collection('order_logs').add({
        'orderId': orderId,
        'vendorName': vendorName,
        'userName': order['userName'],
        'productName': order['productName'],
        'quantity': order['quantity'],
        'totalPrice': order['total'],
        'status': newStatus,
        'message': message,
        'timestamp': Timestamp.now(),
      });

      setState(() {
        orders = orders.map((orderItem) {
          if (orderItem['orderId'] == orderId) {
            orderItem['status'] = newStatus;
          }
          return orderItem;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Order ${newStatus == 'Accepted' ? 'Accepted' : 'Rejected'}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating order status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Orders"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No Orders Found"))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Name: ${order['productName']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text('User: ${order['userName']}'),
                            Text('Quantity: ${order['quantity']}'),
                            Text('Total: \$${order['total']}'),
                            Text('Date: ${order['purchaseDate']}'),
                            Text('Status: ${order['status']}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: order['status'] == 'pending'
                                      ? () => _updateOrderStatus(
                                          order['orderId'], 'Accepted', order)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text("Accept"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: order['status'] == 'pending'
                                      ? () => _updateOrderStatus(
                                          order['orderId'], 'Rejected', order)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text("Reject"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

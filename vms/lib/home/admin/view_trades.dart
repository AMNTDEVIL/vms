import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vms/home/admin/order_logsdetails.dart';

class OrderLogsScreen extends StatefulWidget {
  const OrderLogsScreen({Key? key}) : super(key: key);

  @override
  _OrderLogsScreenState createState() => _OrderLogsScreenState();
}

class _OrderLogsScreenState extends State<OrderLogsScreen> {
  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderLogs();
  }

  // Fetch logs from Firestore
  Future<void> _fetchOrderLogs() async {
    try {
      QuerySnapshot logSnapshot = await FirebaseFirestore.instance
          .collection('order_logs')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        logs = logSnapshot.docs.map((doc) {
          return {
            'orderId': doc['orderId'],
            'message': doc['message'],
            'productName': doc['productName'],
            'quantity': doc['quantity'],
            'status': doc['status'],
            'timestamp': doc['timestamp'],
            'totalPrice': doc['totalPrice'],
            'userName': doc['userName'],
            'vendorName': doc['vendorName'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching logs: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Logs"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(child: Text("No Logs Found"))
              : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      title: Text(log['message']),
                      subtitle: Text(
                        "Timestamp: ${log['timestamp'].toDate()}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        // Navigate to log details
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderLogDetailsScreen(
                              logDetails: log,
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

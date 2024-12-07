import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class test extends StatefulWidget {
  const test({super.key});

  @override
  _HttpTestPageState createState() => _HttpTestPageState();
}

class _HttpTestPageState extends State<test> {
  String data = '';

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));

    if (response.statusCode == 200) {
      // If the server returns an OK response, parse the JSON
      final jsonResponse = json.decode(response.body);
      setState(() {
        data = jsonResponse['title']; // Example: Get the title of the post
      });
    } else {
      // If the server does not return an OK response, throw an exception
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Call fetchData when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP Test'),
      ),
      body: Center(
        child: data.isEmpty
            ? const CircularProgressIndicator() // Show loading indicator while fetching data
            : Text(data), // Display fetched data
      ),
    );
  }
}

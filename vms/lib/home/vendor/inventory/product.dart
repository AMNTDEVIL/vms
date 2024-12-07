class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
  });

  /// Factory method to create a `Product` instance from Firestore data
  /// Handles mixed data types for the `price` field and provides default values for missing fields.
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    // Ensure all fields have fallback values if they are missing or null.
    String name = data['name'] ?? 'Unknown';
    String description = data['description'] ?? 'No description available';
    double price = 0.0;
    String category = data['category'] ?? 'Uncategorized';

    // Handle mixed data types for `price`.
    if (data['price'] != null) {
      if (data['price'] is int) {
        price = (data['price'] as int).toDouble();
      } else if (data['price'] is double) {
        price = data['price'];
      }
    }

    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
    );
  }

  /// Converts the `Product` instance to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
    };
  }
}

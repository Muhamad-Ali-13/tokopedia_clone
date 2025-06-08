class Product {
  final String id;
  final String name;
  final double price;
  final String imageURL;
  final double rating;
  final int soldCount;
  final String location;
  final int? discount;

  double get priceBeforeDiscount {
    if (discount != null && discount! > 0) {
      return price / (1 - discount! / 100);
    }
    return price;
  }

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageURL,
    required this.rating,
    required this.soldCount,
    required this.location,
    this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    print('Parsing product with ID: $id, Data: $json');
    // Handle tags as a string or list
    List<String> parseTags(dynamic tagsValue) {
      if (tagsValue is String) {
        try {
          // Remove quotes and brackets, then split by comma
          String cleaned = tagsValue
              .replaceAll('"', '')
              .replaceAll('[', '')
              .replaceAll(']', '');
          return cleaned
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } catch (e) {
          print('Error parsing tags string: $e');
          return [];
        }
      } else if (tagsValue is List) {
        return (tagsValue as List<dynamic>).map((e) => e.toString()).toList();
      }
      return [];
    }

    // Handle discount as string or int
    int? parseDiscount(dynamic discountValue) {
      if (discountValue is String) {
        try {
          return int.tryParse(discountValue) ??
              0; // Convert string to int, default to 0 if invalid
        } catch (e) {
          print('Error parsing discount string: $e');
          return null;
        }
      } else if (discountValue is int) {
        return discountValue;
      }
      return null;
    }

    return Product(
      id: id,
      name: json['name'] as String? ?? 'Unnamed Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageURL:
          json['imgURL'] as String? ?? '', // Matches 'imgURL' from your data
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      soldCount: (json['soldCount'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? 'Unknown',
      discount: parseDiscount(json['discount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imgURL': imageURL,
      'rating': rating,
      'soldCount': soldCount,
      'location': location,
      'discount': discount,
    };
  }
}

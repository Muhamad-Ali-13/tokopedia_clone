class Product {
  final String id;
  final String name;
  final double price;
  final String imageURL;
  final double rating;
  final int soldCount;
  final String location;
  final List<String> tags;
  final double? discount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageURL,
    required this.rating,
    required this.soldCount,
    required this.location,
    required this.tags,
    this.discount,
  });
}
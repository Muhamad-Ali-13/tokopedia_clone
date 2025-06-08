import 'package:tokopedia_clone/models/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  // Add a price getter or field
  double get price => product.price;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required double price,
  });
}

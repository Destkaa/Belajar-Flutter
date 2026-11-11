
import '../models/product.dart';

class CartItem {
  final Product product;
  final String size;
  String? imagePath;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    required this.quantity,
    this.imagePath,
  });

  int get subtotal => product.price * quantity;
}

final List<CartItem> cartItems = [];

void addToCart({
  required Product product,
  required String size,
  required int quantity,
  String? imagePath,
}) {
  final index = cartItems.indexWhere(
    (item) =>
        item.product.id == product.id &&
        item.size == size,
  );

  if (index != -1) {
    cartItems[index].quantity += quantity;
    cartItems[index].imagePath = imagePath;
  } else {
    cartItems.add(
      CartItem(
        product: product,
        size: size,
        quantity: quantity,
        imagePath: imagePath,
      ),
    );
  }
}

int get cartItemCount {
  return cartItems.fold(
    0,
    (total, item) => total + item.quantity,
  );
}

int get cartTotal {
  return cartItems.fold(
    0,
    (total, item) => total + item.subtotal,
  );
}

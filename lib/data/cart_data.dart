import '../models/product.dart';

class CartItem {
  final Product product;
  final List<String> sizes;
  final List<String?> imagePaths;
  int quantity;

  CartItem({
    required this.product,
    required this.sizes,
    required this.imagePaths,
    required this.quantity,
  });

  int get subtotal => product.price * quantity;

  bool get hasSize => product.name.toLowerCase() != 'backpack';

  String? imageAt(int index) {
    if (index >= 0 && index < imagePaths.length) {
      return imagePaths[index];
    }

    return product.images.isNotEmpty ? product.images.first : null;
  }

  String sizeAt(int index) {
    if (index >= 0 && index < sizes.length) {
      return sizes[index];
    }

    return hasSize ? getDefaultSize(product) : '';
  }
}

final List<CartItem> cartItems = [];

String getDefaultSize(Product product) {
  final name = product.name.toLowerCase();

  if (name == 'backpack') return '';
  if (name == 'socks' || name == 'kaos kaki') return '39-42';

  return 'M';
}

List<String> getAvailableSizes(Product product) {
  final name = product.name.toLowerCase();

  if (name == 'socks' || name == 'kaos kaki') {
    return ['35-38', '39-42', '43-46'];
  }

  if (name == 'backpack') return [];

  return ['S', 'M', 'L', 'XL', 'XXL'];
}

void addToCart({
  required Product product,
  required List<String> sizes,
  required List<String?> imagePaths,
  required int quantity,
}) {
  final validSizes = List<String>.generate(
    quantity,
    (index) => index < sizes.length
        ? sizes[index]
        : getDefaultSize(product),
  );

  final validImages = List<String?>.generate(
    quantity,
    (index) {
      if (index < imagePaths.length) {
        return imagePaths[index];
      }

      return product.images.isNotEmpty
          ? product.images.first
          : null;
    },
  );

  final index = cartItems.indexWhere(
    (item) => item.product.id == product.id,
  );

  if (index != -1) {
    cartItems[index].quantity += quantity;
    cartItems[index].sizes.addAll(validSizes);
    cartItems[index].imagePaths.addAll(validImages);
  } else {
    cartItems.add(
      CartItem(
        product: product,
        sizes: validSizes,
        imagePaths: validImages,
        quantity: quantity,
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
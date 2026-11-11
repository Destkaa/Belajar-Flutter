
import 'package:flutter/material.dart';

import '../data/cart_data.dart';
import '../utils/currency_format.dart';
import 'payment_page.dart';

const Color navy = Color(0xFF102A43);
const Color blue = Color(0xFF1455A3);
const Color background = Color(0xFFF5F7FA);

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get subtotal => cartTotal;

  int get shippingCost => cartItems.isEmpty ? 0 : 15000;

  int get total => subtotal + shippingCost;

  void increaseQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  Future<void> confirmRemove(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text(
          'Apakah kamu yakin ingin menghapus produk ini dari keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      removeItem(index);
    }
  }

  Future<void> checkout() async {
    if (cartItems.isEmpty) return;

    final orderItems = cartItems.map((item) {
      return CartItem(
        product: item.product,
        size: item.size,
        quantity: item.quantity,
        imagePath: item.imagePath,
      );
    }).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage.fromCart(
          items: orderItems,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildProductImage(CartItem item) {
    final image = item.imagePath ??
        (item.product.images.isNotEmpty
            ? item.product.images.first
            : null);

    if (image == null) {
      return const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 35,
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Widget buildCartItem(int index) {
    final item = cartItems[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 95,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1F8),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: buildProductImage(item),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  item.product.category,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Ukuran: ${item.size}',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  formatRupiah(item.product.price),
                  style: const TextStyle(
                    color: blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    IconButton(
                      onPressed: () => decreaseQuantity(index),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: navy,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => increaseQuantity(index),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: navy,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () => confirmRemove(index),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      tooltip: 'Hapus produk',
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Subtotal: ${formatRupiah(item.subtotal)}',
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          summaryRow('Jumlah Produk', '$cartItemCount'),
          const SizedBox(height: 12),
          summaryRow('Subtotal', formatRupiah(subtotal)),
          const SizedBox(height: 12),
          summaryRow('Ongkos Kirim', formatRupiah(shippingCost)),

          const Divider(height: 25),

          summaryRow(
            'Total Pembayaran',
            formatRupiah(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget summaryRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isTotal ? navy : Colors.black54,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? blue : navy,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 17 : 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Keranjang Saya'),
      ),

      body: cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 85,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Keranjang Masih Kosong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Yuk, temukan produk favoritmu!',
                      style: TextStyle(color: Colors.black54),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 13,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali Belanja'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Text(
                        'Keranjang (${cartItems.length} item)',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),

                      const SizedBox(height: 18),

                      ...List.generate(
                        cartItems.length,
                        (index) => buildCartItem(index),
                      ),

                      const SizedBox(height: 5),

                      buildSummary(),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lanjut ke Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

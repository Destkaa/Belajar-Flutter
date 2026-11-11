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
      final item = cartItems[index];

      item.quantity++;
      item.imagePaths.add(
        item.product.images.isNotEmpty
            ? item.product.images.first
            : null,
      );
      item.sizes.add(getDefaultSize(item.product));
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      final item = cartItems[index];

      if (item.quantity > 1) {
        item.quantity--;
        item.imagePaths.removeLast();
        item.sizes.removeLast();
      }
    });
  }

  void removeItem(int index) {
    setState(() => cartItems.removeAt(index));
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
        sizes: List<String>.from(item.sizes),
        imagePaths: List<String?>.from(item.imagePaths),
        quantity: item.quantity,
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

    if (mounted) setState(() {});
  }

  String imageName(String? path) {
    if (path == null) return 'Foto tidak tersedia';

    return path
        .split('/')
        .last
        .replaceAll('.jpg', '')
        .replaceAll('.jpeg', '')
        .replaceAll('.png', '')
        .replaceAll('_', ' ');
  }

  Widget buildUnitImage(CartItem item, int unitIndex) {
    final image = item.imageAt(unitIndex);

    if (image == null) {
      return const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 35,
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return const Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        );
      },
    );
  }

  Widget buildUnitOptions(CartItem item, int unitIndex) {
    final images = item.product.images;
    final selectedImage = item.imageAt(unitIndex);

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unit ${unitIndex + 1}',
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 60,
                height: 65,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: buildUnitImage(item, unitIndex),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: images.contains(selectedImage)
                      ? selectedImage
                      : (images.isNotEmpty ? images.first : null),
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Foto produk',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  items: images.map((image) {
                    return DropdownMenuItem<String>(
                      value: image,
                      child: Text(
                        imageName(image),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      item.imagePaths[unitIndex] = value;
                    });
                  },
                ),
              ),
            ],
          ),
          if (item.hasSize) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: item.sizeAt(unitIndex),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Ukuran',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              items: getAvailableSizes(item.product).map((size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  item.sizes[unitIndex] = value;
                });
              },
            ),
          ],
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 65,
                height: 75,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: buildUnitImage(item, 0),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Text(
                      item.product.category,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatRupiah(item.product.price),
                      style: const TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
          const SizedBox(height: 12),
          const Divider(),
          ...List.generate(
            item.quantity,
            (unitIndex) => buildUnitOptions(item, unitIndex),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => decreaseQuantity(index),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: navy,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(5),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                padding: const EdgeInsets.all(5),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatRupiah(item.subtotal),
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                        'Keranjang ($cartItemCount item)',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...List.generate(
                        cartItems.length,
                        buildCartItem,
                      ),
                      const SizedBox(height: 5),
                      buildSummary(),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  color: Colors.white,
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
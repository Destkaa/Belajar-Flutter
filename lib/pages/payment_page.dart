
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../data/cart_data.dart';
import '../utils/currency_format.dart';

import 'store_page.dart';

const Color navy = Color(0xFF102A43);
const Color blue = Color(0xFF1455A3);
const Color background = Color(0xFFF5F7FA);

class PaymentPage extends StatefulWidget {
  final Product? product;
  final List<String>? sizes;
  final List<String?>? imagePaths;
  final int? quantity;
  final List<CartItem>? items;

  // Checkout langsung dari detail produk.
  const PaymentPage({
    super.key,
    required Product product,
    required List<String> sizes,
    required List<String?> imagePaths,
    required int quantity,
  })  : product = product,
        sizes = sizes,
        imagePaths = imagePaths,
        quantity = quantity,
        items = null;

  // Checkout dari keranjang atau Beli Sekarang.
  const PaymentPage.fromCart({
    super.key,
    required List<CartItem> items,
  })  : product = null,
        sizes = null,
        imagePaths = null,
        quantity = null,
        items = items;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late List<CartItem> orderItems;

  bool isPaid = false;
  String selectedPayment = 'Cash (Tunai)';

  static const int shippingCost = 15000;

  @override
  void initState() {
    super.initState();

    if (widget.items != null) {
      orderItems = widget.items!.map((item) {
        return CartItem(
          product: item.product,
          sizes: List<String>.from(item.sizes),
          imagePaths: List<String?>.from(item.imagePaths),
          quantity: item.quantity,
        );
      }).toList();
    } else {
      orderItems = [
        CartItem(
          product: widget.product!,
          sizes: List<String>.from(widget.sizes!),
          imagePaths: List<String?>.from(widget.imagePaths!),
          quantity: widget.quantity!,
        ),
      ];
    }
  }

  int get subtotal {
    return orderItems.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  int get total => subtotal + shippingCost;

  int get totalQuantity {
    return orderItems.fold(
      0,
      (total, item) => total + item.quantity,
    );
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

  Widget buildUnitImage(CartItem item, int index) {
    final image = item.imageAt(index);

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

  // Tampilan setiap produk dan unit.
  Widget buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.product.name,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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

          const SizedBox(height: 12),

          ...List.generate(item.quantity, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 65,
                    height: 75,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: buildUnitImage(item, index),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit ${index + 1}',
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          imageName(item.imageAt(index)),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),

                        if (item.hasSize) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Ukuran: ${item.sizeAt(index)}',
                            style: const TextStyle(
                              color: navy,
                              fontSize: 12,
                            ),
                          ),
                        ],

                        const SizedBox(height: 4),

                        Text(
                          formatRupiah(item.product.price),
                          style: const TextStyle(
                            color: blue,
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
          }),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah: ${item.quantity}',
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                ),
              ),

              Text(
                'Subtotal: ${formatRupiah(item.subtotal)}',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isTotal ? navy : Colors.black54,
                fontWeight: isTotal
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isTotal ? blue : navy,
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 17 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Metode pembayaran.
  Widget buildPaymentMethod() {
    final methods = [
      {
        'name': 'Cash (Tunai)',
        'icon': Icons.payments_outlined,
        'description':
            'Pembayaran tunai saat pesanan diterima.',
      },
      {
        'name': 'QRIS',
        'icon': Icons.qr_code_2,
        'description':
            'Pembayaran menggunakan scan kode QRIS.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),

          const SizedBox(height: 12),

          ...methods.map((method) {
            final name = method['name'] as String;
            final icon = method['icon'] as IconData;
            final description =
                method['description'] as String;

            final isSelected = selectedPayment == name;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPayment = name;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEAF1F8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? blue
                        : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: navy,
                      size: 28,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? blue : Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Konfirmasi pembayaran.
  void confirmPayment() {
    if (orderItems.isEmpty || isPaid) return;

    // Simpan status pembayaran.
    setState(() {
      isPaid = true;
    });

    // Keranjang hanya dikosongkan setelah konfirmasi.
    // Checkout dari detail produk biasa tidak menghapus keranjang.
    if (widget.items != null) {
      cartItems.clear();
    }
  }

  void backToStore() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const StorePage(),
      ),
      (route) => false,
    );
  }

  // Bukti pembayaran.
  Widget buildReceipt() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 75,
              ),

              const SizedBox(height: 15),

              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Terima kasih telah berbelanja di PERSIB STORE.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),

              const Divider(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detail Produk yang Dibeli',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navy,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              ...orderItems.map(buildOrderItem),

              const Divider(height: 25),

              summaryRow(
                'Total Unit',
                '$totalQuantity produk',
              ),

              summaryRow(
                'Subtotal',
                formatRupiah(subtotal),
              ),

              summaryRow(
                'Ongkos Kirim',
                formatRupiah(shippingCost),
              ),

              const Divider(height: 20),

              summaryRow(
                'Total Pembayaran',
                formatRupiah(total),
                isTotal: true,
              ),

              const SizedBox(height: 10),

              summaryRow(
                'Metode Pembayaran',
                selectedPayment,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: backToStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.storefront_outlined,
                  ),
                  label: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPaid) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: navy,
          foregroundColor: Colors.white,
          title: const Text('Bukti Pembayaran'),
        ),
        body: buildReceipt(),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Payment Gateway'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 15),

            ...orderItems.map(buildOrderItem),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  summaryRow(
                    'Total Unit',
                    '$totalQuantity produk',
                  ),

                  summaryRow(
                    'Subtotal',
                    formatRupiah(subtotal),
                  ),

                  summaryRow(
                    'Ongkos Kirim',
                    formatRupiah(shippingCost),
                  ),

                  const Divider(height: 25),

                  summaryRow(
                    'Total Pembayaran',
                    formatRupiah(total),
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            buildPaymentMethod(),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.lock_outline),
                label: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

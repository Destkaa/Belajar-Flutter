
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../data/cart_data.dart';
import '../utils/currency_format.dart';
import 'payment_page.dart';
import 'cart_page.dart';

const Color navy = Color(0xFF102A43);
const Color blue = Color(0xFF1455A3);
const Color background = Color(0xFFF5F7FA);

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({
    super.key,
    required this.product,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String selectedSize = 'M';
  int quantity = 1;
  int currentImage = 0;

  late final PageController imageController;

  // ==========================================
  // CHECK PRODUCT TYPE
  // ==========================================

  bool get isSocks {
    final name = widget.product.name.toLowerCase();

    return name == 'socks' || name == 'kaos kaki';
  }

  bool get isBackpack {
    final name = widget.product.name.toLowerCase();

    return name == 'backpack';
  }

  bool get hasSize {
    return !isBackpack;
  }

  // ==========================================
  // AVAILABLE SIZES
  // ==========================================

  List<String> get availableSizes {
    if (isSocks) {
      return ['35-38', '39-42', '43-46'];
    }

    if (isBackpack) {
      return [];
    }

    return ['S', 'M', 'L', 'XL', 'XXL'];
  }

  // ==========================================
  // INIT STATE
  // ==========================================

  @override
  void initState() {
    super.initState();

    imageController = PageController();

    if (isSocks) {
      selectedSize = '39-42';
    } else if (isBackpack) {
      selectedSize = '-';
    } else {
      selectedSize = 'M';
    }
  }

  @override
  void dispose() {
    imageController.dispose();
    super.dispose();
  }

  // ==========================================
  // PREVIOUS IMAGE
  // ==========================================

  void previousImage() {
    final imageCount = widget.product.images.length;

    if (imageCount <= 1 || !imageController.hasClients) return;

    final previousIndex =
        currentImage > 0 ? currentImage - 1 : imageCount - 1;

    imageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================================
  // NEXT IMAGE
  // ==========================================

  void nextImage() {
    final imageCount = widget.product.images.length;

    if (imageCount <= 1 || !imageController.hasClients) return;

    final nextIndex =
        currentImage < imageCount - 1 ? currentImage + 1 : 0;

    imageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ==========================================
  // OPEN CART
  // ==========================================

  Future<void> openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartPage(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================
  // GET SELECTED IMAGE
  // ==========================================

  String? get selectedImage {
    if (widget.product.images.isEmpty) return null;

    return widget.product.images[currentImage];
  }

  // ==========================================
  // ADD TO CART
  // ==========================================

  void addProductToCart() {
    addToCart(
      product: widget.product,
      size: selectedSize,
      quantity: quantity,
      imagePath: selectedImage,
    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: navy,
        behavior: SnackBarBehavior.floating,
        content: Text(
          '${widget.product.name} berhasil ditambahkan ke keranjang.',
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // ==========================================
  // BUY NOW
  // ==========================================

  void buyNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          product: widget.product,
          size: selectedSize,
          quantity: quantity,
          imagePath: selectedImage,
        ),
      ),
    );
  }

  // ==========================================
  // BUILD SIZE SELECTION
  // ==========================================

  Widget buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Ukuran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: navy,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          isSocks
              ? 'Ukuran berdasarkan nomor sepatu'
              : 'Pilih ukuran pakaian',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSizes.map((size) {
            final isSelected = selectedSize == size;

            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              selectedColor: blue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : navy,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedSize = size;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: background,

      // ==========================================
      // APP BAR
      // ==========================================

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Detail Produk'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: IconButton(
                tooltip: 'Keranjang',
                onPressed: openCart,
                icon: Badge(
                  label: Text('$cartItemCount'),
                  isLabelVisible: cartItemCount > 0,
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // ==========================================
      // BODY
      // ==========================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PRODUCT IMAGE SLIDER

            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1F8),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: product.images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: imageController,
                          itemCount: product.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentImage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              product.images[index],
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Center(
                                  child: Text(
                                    'Foto gagal dimuat',
                                    style: TextStyle(color: navy),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // PREVIOUS BUTTON

                        if (product.images.length > 1)
                          Positioned(
                            left: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                onPressed: previousImage,
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.9),
                                  foregroundColor: navy,
                                  fixedSize: const Size(42, 42),
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                        // NEXT BUTTON

                        if (product.images.length > 1)
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: IconButton(
                                onPressed: nextImage,
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.9),
                                  foregroundColor: navy,
                                  fixedSize: const Size(42, 42),
                                ),
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),

                        // IMAGE INDICATOR

                        if (product.images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 250,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: currentImage == index ? 20 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: currentImage == index
                                          ? blue
                                          : Colors.grey.shade400,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Foto produk belum tersedia',
                        style: TextStyle(color: navy),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // PRODUCT INFORMATION

            Text(
              product.category.toUpperCase(),
              style: const TextStyle(
                color: blue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              formatRupiah(product.price),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: blue,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Deskripsi Produk',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.description,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 25),

            // SIZE SELECTION
            // BACKPACK TIDAK MENAMPILKAN BAGIAN INI

            if (hasSize) ...[
              buildSizeSelection(),
              const SizedBox(height: 25),
            ],

            // QUANTITY

            const Text(
              'Jumlah',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: navy,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: navy,
                  ),
                ),

                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: navy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ADD TO CART

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: navy,
                  side: const BorderSide(
                    color: navy,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: addProductToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // BUY NOW

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text(
                  'Beli Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: buyNow,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

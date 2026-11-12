
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
  List<String> selectedSizes = [];
  List<String?> selectedImages = [];

  int quantity = 1;
  int currentImage = 0;

  late final PageController imageController;

  bool get isBackpack {
    return widget.product.name.toLowerCase() == 'backpack';
  }

  bool get hasSize => !isBackpack;

  List<String> get availableSizes {
    return getAvailableSizes(widget.product);
  }

  String get defaultSize => getDefaultSize(widget.product);

  String? get firstImage {
    if (widget.product.images.isEmpty) return null;
    return widget.product.images.first;
  }

  @override
  void initState() {
    super.initState();

    imageController = PageController();

    selectedImages = List<String?>.filled(
      quantity,
      firstImage,
    );

    selectedSizes = List<String>.filled(
      quantity,
      defaultSize,
    );
  }

  @override
  void dispose() {
    imageController.dispose();
    super.dispose();
  }

  // Memperbarui jumlah dan pilihan setiap unit.
  void changeQuantity(int value) {
    if (value < 1 || value == quantity) return;

    setState(() {
      final oldImages = List<String?>.from(selectedImages);
      final oldSizes = List<String>.from(selectedSizes);

      selectedImages = List<String?>.generate(
        value,
        (index) {
          if (index < oldImages.length) {
            return oldImages[index];
          }

          return firstImage;
        },
      );

      selectedSizes = List<String>.generate(
        value,
        (index) {
          if (index < oldSizes.length) {
            return oldSizes[index];
          }

          return defaultSize;
        },
      );

      quantity = value;
    });
  }

  void increaseQuantity() {
    changeQuantity(quantity + 1);
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      changeQuantity(quantity - 1);
    }
  }

  void previousImage() {
    final count = widget.product.images.length;

    if (count <= 1 || !imageController.hasClients) return;

    final index = currentImage > 0
        ? currentImage - 1
        : count - 1;

    imageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void nextImage() {
    final count = widget.product.images.length;

    if (count <= 1 || !imageController.hasClients) return;

    final index = currentImage < count - 1
        ? currentImage + 1
        : 0;

    imageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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

  // Menambahkan produk ke keranjang.
  void addProductToCart() {
    addToCart(
      product: widget.product,
      sizes: selectedSizes,
      imagePaths: selectedImages,
      quantity: quantity,
    );

    setState(() {});

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: navy,
        behavior: SnackBarBehavior.floating,
        content: Text(
          '$quantity ${widget.product.name} berhasil ditambahkan ke keranjang.',
        ),
      ),
    );
  }

  // Membeli produk sekarang beserta seluruh isi keranjang.
  void buyNow() {
    // Salin seluruh isi keranjang.
    final List<CartItem> checkoutItems = cartItems.map((item) {
      return CartItem(
        product: item.product,
        sizes: List<String>.from(item.sizes),
        imagePaths: List<String?>.from(item.imagePaths),
        quantity: item.quantity,
      );
    }).toList();

    // Cari apakah produk sudah ada di keranjang.
    final existingIndex = checkoutItems.indexWhere(
      (item) => item.product.id == widget.product.id,
    );

    if (existingIndex == -1) {
      checkoutItems.add(
        CartItem(
          product: widget.product,
          sizes: List<String>.from(selectedSizes),
          imagePaths: List<String?>.from(selectedImages),
          quantity: quantity,
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage.fromCart(
          items: checkoutItems,
        ),
      ),
    );
  }

  String imageName(String? path) {
    if (path == null) return 'Foto tidak tersedia';

    final fileName = path.split('/').last;

    return fileName
        .replaceAll('.jpg', '')
        .replaceAll('.jpeg', '')
        .replaceAll('.png', '')
        .replaceAll('_', ' ');
  }

  // Pilihan foto untuk setiap unit.
  Widget buildUnitImageSelection(int index) {
    final images = widget.product.images;

    if (images.isEmpty) {
      return const Text(
        'Foto produk belum tersedia',
        style: TextStyle(color: Colors.black54),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Foto',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Container(
              width: 65,
              height: 65,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                selectedImages[index] ?? images.first,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.broken_image_outlined,
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedImages[index] ?? images.first,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    selectedImages[index] = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Pilihan foto dan ukuran setiap unit.
  Widget buildUnitSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilihan Setiap Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: navy,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Atur foto dan ukuran untuk setiap unit secara terpisah.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 14),

        ...List.generate(quantity, (index) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.product.name} ${index + 1}',
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                buildUnitImageSelection(index),

                if (hasSize) ...[
                  const SizedBox(height: 15),

                  const Text(
                    'Pilih Ukuran',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSizes.map((size) {
                      final selected =
                          selectedSizes[index] == size;

                      return ChoiceChip(
                        label: Text(size),
                        selected: selected,
                        selectedColor: blue,
                        backgroundColor:
                            const Color(0xFFF5F7FA),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : navy,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedSizes[index] = size;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // Slider foto produk.
  Widget buildImageSlider() {
    final images = widget.product.images;

    if (images.isEmpty) {
      return const Center(
        child: Text('Foto produk belum tersedia'),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: imageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              currentImage = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.asset(
              images[index],
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Text('Foto gagal dimuat'),
                );
              },
            );
          },
        ),

        if (images.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: previousImage,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.9),
                  foregroundColor: navy,
                ),
              ),
            ),
          ),

          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                onPressed: nextImage,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.9),
                  foregroundColor: navy,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
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
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Pengatur jumlah produk.
  Widget buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: navy,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            IconButton(
              onPressed: quantity > 1
                  ? decreaseQuantity
                  : null,
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
                color: navy,
              ),
            ),

            IconButton(
              onPressed: increaseQuantity,
              icon: const Icon(
                Icons.add_circle_outline,
                color: navy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Detail Produk'),

        // Ikon keranjang digeser sedikit ke kiri.
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: openCart,
              icon: Badge(
                label: Text('$cartItemCount'),
                isLabelVisible: cartItemCount > 0,
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1F8),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: buildImageSlider(),
            ),

            const SizedBox(height: 24),

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

            buildQuantitySelector(),

            const SizedBox(height: 20),

            buildUnitSelection(),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: addProductToCart,
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
                icon: const Icon(
                  Icons.add_shopping_cart,
                ),
                label: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: buyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                ),
                label: const Text(
                  'Beli Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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

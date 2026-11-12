
import 'dart:async';
import 'package:flutter/material.dart';

import '../data/product_data.dart';
import '../data/cart_data.dart';
import '../models/product.dart';
import '../utils/currency_format.dart';
import 'detail_page.dart';
import 'cart_page.dart';

const Color navy = Color(0xFF102A43);
const Color blue = Color(0xFF1455A3);
const Color background = Color(0xFFF5F7FA);

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {

  // ==========================================
  // OPEN DETAIL PAGE
  // ==========================================

  Future<void> openDetail(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(product: product),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ==========================================
  // OPEN CART PAGE
  // ==========================================

  Future<void> openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartPage(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,

        title: Row(
          children: [
            Image.asset(
              'assets/Icon.jpg',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),

            SizedBox(width: 10),

            Text(
              'PERSIB STORE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Badge(
                label: Text('$cartItemCount'),
                isLabelVisible: cartItemCount > 0,
                backgroundColor: Colors.red,
                child: IconButton(
                  onPressed: openCart,
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 5),
              child: Text(
                'Shop Products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Find your favorite Persib merchandise.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.70,
                ),

                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onTap: () => openDetail(products[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PRODUCT CARD
// ==========================================

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: ProductImageCarousel(
                  product: product,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: blue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: navy,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: blue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: const Center(
                      child: Text(
                        'Lihat Produk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PRODUCT IMAGE CAROUSEL
// ==========================================

class ProductImageCarousel extends StatefulWidget {
  final Product product;

  const ProductImageCarousel({
    super.key,
    required this.product,
  });

  @override
  State<ProductImageCarousel> createState() =>
      _ProductImageCarouselState();
}

class _ProductImageCarouselState
    extends State<ProductImageCarousel> {

  late final PageController controller;

  Timer? timer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    controller = PageController();

    if (widget.product.images.length > 1) {
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (timer) {
          if (!mounted || !controller.hasClients) return;

          final nextIndex =
              (currentIndex + 1) % widget.product.images.length;

          controller.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFFEAF1F8),
      );
    }

    return Stack(
      children: [

        PageView.builder(
          controller: controller,
          itemCount: images.length,

          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          itemBuilder: (context, index) {
            return Image.asset(
              images[index],
              width: double.infinity,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFEAF1F8),
                );
              },
            );
          },
        ),

        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: currentIndex == index ? 18 : 6,
                  height: 6,

                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? blue
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

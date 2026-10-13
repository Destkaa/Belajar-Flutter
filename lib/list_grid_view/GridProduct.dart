import 'package:flutter/material.dart';

class GridProductPage extends StatelessWidget {
  const GridProductPage({super.key});

  final List<Map<String, dynamic>> products = const [
    {
      'name': 'Kaos Flutter',
      'price': 'Rp100.000',
      'image': 'https://picsum.photos/200?1',
    },
    {
      'name': 'Hoodie Dart',
      'price': 'Rp150.000',
      'image': 'https://picsum.photos/200?2',
    },
    {
      'name': 'Sticker UI',
      'price': 'Rp200.000',
      'image': 'https://picsum.photos/200?3',
    },
    {
      'name': 'Totebag Dev',
      'price': 'Rp250.000',
      'image': 'https://picsum.photos/200?4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Product'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar produk
                  Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),

                  // Gradasi transparan di bagian bawah gambar
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(190, 0, 0, 0),
                        ],
                        stops: [0.45, 1.0],
                      ),
                    ),
                  ),

                  // Nama dan harga produk
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['price'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
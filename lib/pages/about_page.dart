import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Halaman About'),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Kembali ke Home'),
          ),
        ],
      ),
    );
  }
}

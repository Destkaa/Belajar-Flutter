import 'package:flutter/material.dart';

class ContohGridView extends StatelessWidget {
  const ContohGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contoh GridView Basic'),
        backgroundColor: Colors.blue,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: const [
          Card(
            color: Colors.blue,
            child: Center(
              child: Text(
                'Kaka Viangi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Card(
            color: Colors.green,
            child: Center(
              child: Text(
                'Andi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Card(
            color: Colors.orange,
            child: Center(
              child: Text(
                'Budi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Card(
            color: Colors.red,
            child: Center(
              child: Text(
                'Siti',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
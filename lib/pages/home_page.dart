import 'package:flutter/material.dart';
import 'package:rpl2/list_grid_view/Instagram.dart';
import 'about_page.dart';
import 'package:rpl2/list_grid_view/ListView.dart';
import 'package:rpl2/list_grid_view/GridView.basic.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Halaman Home'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const AboutPage();
                  },
                ),
              );
            },
            child: const Text('Pergi ke About'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ContohListView();
                  },
                ),
              );
            },
            child: const Text('Pergi ke ListView'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ContohGridView();
                  },
                ),
              );
            },
            child: const Text('Pergi ke GridView Basic'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const BerandaInstagram();
                  },
                ),
              );
            },
            child: const Text('Pergi ke Instagram'),
          ),
        ],
      ),
    );
  }
}

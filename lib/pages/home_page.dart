
import 'package:flutter/material.dart';
import 'package:rpl2/list_grid_view/Instagram.dart';
import 'package:rpl2/pages/formulir.dart';
import 'package:rpl2/pages/input_page.dart';
import 'package:rpl2/pages/about_page.dart';
import 'package:rpl2/list_grid_view/ListView.dart';
import 'package:rpl2/list_grid_view/GridView.basic.dart';
import 'package:rpl2/pages/store_page.dart';

const Color navy = Color(0xFF102A43);
const Color blue = Color(0xFF1455A3);
const Color background = Color(0xFFF5F7FA);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.dashboard_rounded, size: 23),
            SizedBox(width: 10),
            Text(
              'My Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Halo, Kaka!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Selamat datang di halaman utama aplikasi.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Row(
                    children: [
                      Icon(
                        Icons.apps_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Learning Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section Title
            const Text(
              'Menu Aplikasi',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Pilih halaman yang ingin kamu kunjungi.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            // Menu Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                MenuCard(
                  title: 'About',
                  subtitle: 'Tentang aplikasi',
                  icon: Icons.person_outline_rounded,
                  color: const Color(0xFF1455A3),
                  onTap: () {
                    navigate(context, const AboutPage());
                  },
                ),

                MenuCard(
                  title: 'ListView',
                  subtitle: 'Daftar data',
                  icon: Icons.view_list_rounded,
                  color: const Color(0xFF087E8B),
                  onTap: () {
                    navigate(context, const ContohListView());
                  },
                ),

                MenuCard(
                  title: 'GridView',
                  subtitle: 'Tampilan grid',
                  icon: Icons.grid_view_rounded,
                  color: const Color(0xFF7353BA),
                  onTap: () {
                    navigate(context, const ContohGridView());
                  },
                ),

                MenuCard(
                  title: 'Instagram',
                  subtitle: 'UI Instagram',
                  icon: Icons.camera_alt_outlined,
                  color: const Color(0xFFD65A7A),
                  onTap: () {
                    navigate(context, const BerandaInstagram());
                  },
                ),

                MenuCard(
                  title: 'Formulir',
                  subtitle: 'Input data',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFFDA8B24),
                  onTap: () {
                    navigate(context, Formulir());
                  },
                ),

                MenuCard(
                  title: 'Input Form',
                  subtitle: 'Belajar form',
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF27845B),
                  onTap: () {
                    navigate(context, BelajarForm());
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Persib Store Section
            const Text(
              'Featured Application',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 14),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                navigate(context, const StorePage());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF102A43),
                      Color(0xFF1455A3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Persib Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Explore merchandise Maung Bandung',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Footer
            Center(
              child: Text(
                'MY APPLICATION • 2026',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void navigate(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}

// Reusable Menu Card
class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 23,
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LatihanTiga(),
    );
  }
}

class LatihanTiga extends StatelessWidget {
  const LatihanTiga({super.key});

  Widget topButton(Widget child) {
    return Container(
      width: 55,
      height: 55,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // ================= COVER =================
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Image.asset(
                    'assets/genshin.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                // Lapisan gelap
                Container(
                  width: double.infinity,
                  height: 260,
                  color: Colors.black.withOpacity(0.15),
                ),

                // ================= TOMBOL ATAS =================
                Positioned(
                  left: 20,
                  top: 30,
                  child: topButton(
                    const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),

                Positioned(
                  right: 20,
                  top: 30,
                  child: Row(
                    children: [
                      // ================= GROK =================
                      topButton(
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/grok.jpg',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 28,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ================= SEARCH =================
                      topButton(
                        const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ================= MORE =================
                      topButton(
                        const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= FOTO PROFIL =================
                Positioned(
                  left: 35,
                  bottom: -85,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 7,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/foto.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Jarak foto profil
            const SizedBox(height: 105),

            // ================= PROFIL =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  const Text(
                    "Kaka Viangi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Username
                  const Text(
                    "@destkaa_13",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ================= LOKASI =================
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Bandung, Jawa Barat",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ================= GITHUB =================
                  Row(
                    children: const [
                      Icon(
                        Icons.link,
                        color: Colors.blue,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "github.com/Destkaa",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ================= LAHIR & JOINED =================
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(
                              Icons.cake_outlined,
                              color: Colors.grey,
                              size: 25,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                "Born October 13, 2008",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Row(
                          children: const [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.grey,
                              size: 25,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                "Joined 2026",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 25,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // ================= PEMBATAS =================
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.shade900,
                  ),

                  const SizedBox(height: 25),

                  // ================= ABOUT =================
                  const Text(
                    "About",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Frontend Developer Student\n"
                    "Photography • UI Design • Technology",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ================= FOLLOW =================
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Follow",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
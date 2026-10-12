import 'package:flutter/material.dart';

class LatihanDua extends StatelessWidget {
  const LatihanDua({super.key});

  @override
  Widget build(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

              Container(
                  width: 450,
                  height: 70,
                  color: const Color.fromARGB(255, 49, 79, 176),
                  alignment: Alignment.center,
                  child: const Text(
                    "CHELSEA F.C",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),


          // Dua Kotak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              // Kotak 1
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    color: const Color.fromARGB(255, 76, 73, 222),
                    alignment: Alignment.center,
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    color: const Color.fromARGB(255, 102, 225, 102),
                    alignment: Alignment.center,
                    child: const Text(
                      "Kotak 1",
                      style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ],
              ),

              // Kotak 2
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    color: const Color.fromARGB(255, 76, 73, 222),
                    alignment: Alignment.center,
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    color: const Color.fromARGB(255, 102, 225, 102),
                    alignment: Alignment.center,
                    child: const Text(
                    "Kotak 2",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Persegi panjang Kaka
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 450,
              height: 150,
              color: const Color.fromARGB(255, 76, 73, 222),
            ),
            Container(
              width: 400,
              height: 100,
              color: Colors.green,
              alignment: Alignment.center,
              child: const Text(
                "Eden Hazard",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        // Persegi panjang Destkaa
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 450,
              height: 150,
              color: const Color.fromARGB(255, 76, 73, 222),
            ),
            Container(
              width: 400,
              height: 100,
              color: Colors.green,
              alignment: Alignment.center,
              child: const Text(
                "Reece James",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
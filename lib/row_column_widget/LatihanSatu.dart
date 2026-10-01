import 'package:flutter/material.dart';

class LatihanSatu extends StatelessWidget {
  const LatihanSatu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 300,
        color: Colors.blueAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(width: 100, height: 100, color: Colors.red),
            Column(
              children: [
                Text("Nama: Kaka Viangi"),
                Text("Kelas: XII RPL 2"),
                Text("NIS: 123456789"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

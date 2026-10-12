import 'package:flutter/material.dart';

class SizeBoxWidget extends StatelessWidget {
  const SizeBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
         Text("Baris 1"),
         SizedBox(height: 10),
         Text("Baris 2"),
         SizedBox(
          width: 150,
          height: 25,
          child: ElevatedButton(onPressed: () {}, child: const Text("Button")),
         ),
       ],
      ),
    );
  }
}
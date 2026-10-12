import 'package:flutter/material.dart';

class Expandedwidget extends StatelessWidget {
  const Expandedwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(color: Colors.black, width: 100,),
        Expanded(
          flex: 1,
          child: Container(color: Colors.red, height: 50, child: Text("Satu"),),
        ),
        Expanded(
          flex: 2,
          child: Container(color: Colors.green, height: 50, child: Text("Dua"),),
        ),
        Expanded(
          flex: 3,
          child: Container(color: Colors.blue, height: 50, child: Text("Tiga"),),
        ),
      ],
    );
  }
}
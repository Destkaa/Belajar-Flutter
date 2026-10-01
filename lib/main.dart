import 'package:flutter/material.dart';
import 'package:rpl2/container_widget/LatihanContainer.dart';
import 'package:rpl2/row_column_widget/ColumnWidget.dart';
import 'package:rpl2/row_column_widget/RowWidget.dart';
import 'package:rpl2/row_column_widget/RowColumnWidget.dart';
import 'package:rpl2/row_column_widget/LatihanSatu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Pertamaku",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("RPL 2"),
          backgroundColor: const Color.fromARGB(255, 24, 112, 194),
          centerTitle: true,
        ),
        body:  LatihanSatu(),
      ),
    );
  }
}

class HelloWidget extends StatelessWidget {
  const HelloWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Hello Flutter",
        style: TextStyle(
          color: Colors.indigo,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.yellowAccent,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:rpl2/container_widget/LatihanContainer.dart';
import 'package:rpl2/row_column_widget/ColumnWidget.dart';
import 'package:rpl2/row_column_widget/RowWidget.dart';
import 'package:rpl2/row_column_widget/RowColumnWidget.dart';
import 'package:rpl2/row_column_widget/LatihanSatu.dart';
import 'package:rpl2/row_column_widget/LatihanDua.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: const LatihanDua(),
      ),
    );
  }
}
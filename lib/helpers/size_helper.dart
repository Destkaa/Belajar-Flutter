import 'package:flutter/widgets.dart';

// Fungsi untuk mendapatkan lebar layar
double displayWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

// Fungsi untuk mendapatkan tinggi layar
double displayHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
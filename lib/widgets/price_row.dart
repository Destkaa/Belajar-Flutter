
import 'package:flutter/material.dart';
import '../utils/currency_format.dart';

class PriceRow extends StatelessWidget {
  final String title;
  final int price;
  final bool isTotal;

  const PriceRow({
    super.key,
    required this.title,
    required this.price,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            formatRupiah(price),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? const Color(0xFF1455A3)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

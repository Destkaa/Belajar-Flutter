
import '../models/product.dart';

const List<Product> products = [
  Product(
    id: 1,
    name: 'Jersey',
    category: 'Jersey',
    price: 450000,
    description: 'Koleksi jersey Persib Bandung.',
    images: [
      'assets/home_jersey.jpg',
      'assets/away_jersey.jpg',
      'assets/third_jersey.jpg',
    ],
  ),

  Product(
    id: 2,
    name: 'Socks',
    category: 'Apparel',
    price: 350000,
    description: 'Kaos kaki resmi Persib Bandung.',
    images: [
      'assets/socks.jpg',
    ],
  ),

  Product(
    id: 3,
    name: 'Backpack',
    category: 'Accessories',
    price: 125000,
    description: 'Backpack Persib Bandung.',
    images: [
      'assets/backpack.jpg',
    ],
  ),

  Product(
    id: 4,
    name: 'T-shirt',
    category: 'Accessories',
    price: 150000,
    description: 'T-shirt Persib Bandung.',
    images: [
      'assets/tshirt1.jpg',
      'assets/tshirt2.jpg',
      'assets/tshirt3.jpg',
    ],
  ),
];

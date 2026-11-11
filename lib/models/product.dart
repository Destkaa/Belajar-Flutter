
class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final String description;
  final List<String> images;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.images = const [],
  });
}

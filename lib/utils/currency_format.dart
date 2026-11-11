
String formatRupiah(int price) {
  final result = price.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  return 'Rp $result';
}

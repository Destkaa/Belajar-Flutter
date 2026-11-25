class ApiConstants {
  // Android emulator: 10.0.2.2
  // iOS simulator: 127.0.0.1
  // HP asli: IP laptop yang menjalankan Laravel

  static const String baseUrl = 'http://10.10.8.99:8000/api';

  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String user = '$baseUrl/user';
  static const String articles = '$baseUrl/articles';
}
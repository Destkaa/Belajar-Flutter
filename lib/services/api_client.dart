import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_exception.dart';

class ApiClient {
  static const _tokenKey = 'access_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ---------------- REQUEST JSON (surat) ----------------
  /// [method] = 'GET' | 'POST' | 'PUT' | 'DELETE'
  Future<Map<String, dynamic>> request(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(url);
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final encoded = body == null ? null : jsonEncode(body);

    final response = await _guard(switch (method) {
      'GET' => http.get(uri, headers: headers),
      'POST' => http.post(uri, headers: headers, body: encoded),
      'PUT' => http.put(uri, headers: headers, body: encoded),
      'DELETE' => http.delete(uri, headers: headers),
      _ => throw ArgumentError('Method tidak dikenal: $method'),
    });

    return _handle(response, '$method $url');
  }

  // ---------------- REQUEST MULTIPART (paket + file) ----------------
  /// Selalu memakai POST (lihat penjelasan _method=PUT di backend).
  ///
  /// [fileField] harus sama persis dengan nama field file yang dibaca
  /// backend (mis. `$request->file('image')` di Laravel).
  Future<Map<String, dynamic>> multipart(
    String url, {
    required Map<String, String> fields,
    XFile? file,
    String fileField = 'image',
  }) async {
    final token = await _getToken();

    // Jangan set Content-Type manual! http akan mengisi boundary otomatis.
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields.addAll(fields);

    if (file != null) {
      // Dibaca sebagai bytes agar jalan di mobile maupun web.
      final bytes = await file.readAsBytes();
      final name = file.name.isNotEmpty ? file.name : 'upload.jpg';
      debugPrint(
        'UPLOAD file: $name (${(bytes.length / 1024).toStringAsFixed(0)} KB), '
        'field: $fileField',
      );
      request.files.add(
        http.MultipartFile.fromBytes(fileField, bytes, filename: name),
      );
    }

    // Upload foto butuh waktu lebih lama, jadi timeout 60 detik
    final response = await _guard(
      request.send().then(http.Response.fromStream),
      timeout: const Duration(seconds: 60),
    );

    return _handle(response, 'POST(multipart) $url');
  }

  // ---------------- ALAT BANTU ----------------

  /// Menunggu response dengan batas waktu + menangani error koneksi.
  ///
  /// Catatan: package `http` membungkus SocketException menjadi
  /// `ClientException`, jadi `on SocketException` saja tidak cukup.
  /// Itu sebabnya upload yang terputus sebelumnya lolos sebagai
  /// "kesalahan tak terduga".
  Future<http.Response> _guard(
    Future<http.Response> future, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      return await future.timeout(timeout);
    } on TimeoutException {
      throw ApiException('Koneksi timeout, coba lagi');
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      throw ApiException('Tidak ada koneksi atau server tidak terjangkau');
    } on HandshakeException catch (e) {
      debugPrint('HandshakeException: $e');
      throw ApiException('Koneksi aman (SSL) ke server gagal');
    } on http.ClientException catch (e) {
      debugPrint('ClientException: ${e.message}');
      throw ApiException(
        'Koneksi ke server terputus. Jika sedang mengunggah foto, '
        'ukuran file mungkin melebihi batas server.',
      );
    } on HttpException catch (e) {
      debugPrint('HttpException: ${e.message}');
      throw ApiException('Koneksi ke server terputus');
    }
  }

  /// Membaca response dan menerjemahkan status code.
  Future<Map<String, dynamic>> _handle(
    http.Response response,
    String label,
  ) async {
    final status = response.statusCode;
    final ok = status >= 200 && status < 300;

    if (!ok) {
      // Log agar penyebab bisa dibaca di konsol `flutter run`.
      debugPrint('API ERROR [$label] status=$status');
      debugPrint(
        'BODY: ${response.body.length > 800 ? response.body.substring(0, 800) : response.body}',
      );
    }

    // Saat sukses, body harus JSON valid. Saat gagal, body boleh bukan JSON
    // (mis. halaman HTML 413/500 dari nginx atau PHP), jadi dibaca longgar
    // supaya status code tetap diterjemahkan dengan benar.
    final data = _decode(response, strict: ok);

    if (ok) return data;

    switch (status) {
      case 401:
        await _clearToken();
        throw ApiException('Sesi habis, silakan login lagi', 401);
      case 403:
        throw ApiException('Anda tidak punya akses ke data ini', 403);
      case 404:
        throw ApiException('Data tidak ditemukan', 404);
      case 413:
        throw ApiException('Ukuran file terlalu besar', 413);
      case 422:
        throw ApiException(_parseErrors(data), 422);
      default:
        throw ApiException(
          data['message']?.toString() ??
              'Terjadi kesalahan pada server (kode $status)',
          status,
        );
    }
  }

  Map<String, dynamic> _decode(http.Response response, {required bool strict}) {
    if (response.body.isEmpty) return {};
    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : {};
    } on FormatException {
      if (strict) {
        throw ApiException('Response server tidak valid', response.statusCode);
      }
      return {};
    }
  }

  String _parseErrors(Map<String, dynamic> body) {
    final source = body['errors'] is Map ? body['errors'] as Map : body;
    final messages = source.values
        .expand((e) => e is List ? e : [e])
        .map((e) => e.toString())
        .toList();
    return messages.isEmpty ? 'Data tidak valid' : messages.join('\n');
  }
}
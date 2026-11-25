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

  Map<String, String> _headers(String? token) {
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ---------------- REQUEST JSON ----------------
  /// [method] = GET | POST | PUT | DELETE
  Future<Map<String, dynamic>> request(
    String method,
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse(url);
    final headers = {
      ..._headers(token),
      'Content-Type': 'application/json',
    };
    final encoded = body == null ? null : jsonEncode(body);

    final response = await _guard(
      switch (method.toUpperCase()) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(uri, headers: headers, body: encoded),
        'PUT' => http.put(uri, headers: headers, body: encoded),
        'DELETE' => http.delete(uri, headers: headers),
        _ => throw ArgumentError('Method tidak dikenal: $method'),
      },
    );

    return _handle(response, '${method.toUpperCase()} $url');
  }

  // ---------------- REQUEST MULTIPART ----------------
  /// Mengirim field teks dan file gambar.
  /// Backend Laravel dapat membaca gambar dengan $request->file('image').
  ///
  /// Untuk update, backend perlu mendukung POST dengan _method=PUT.
  Future<Map<String, dynamic>> multipart(
    String url, {
    required Map<String, String> fields,
    XFile? file,
    String fileField = 'image',
  }) async {
    final token = await _getToken();

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(_headers(token))
      ..fields.addAll(fields);

    if (file != null) {
      final bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty ? file.name : 'upload.jpg';

      debugPrint(
        'UPLOAD file: $filename '
        '(${(bytes.length / 1024).toStringAsFixed(0)} KB)',
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          bytes,
          filename: filename,
        ),
      );
    }

    final response = await _guard(
      request.send().then(http.Response.fromStream),
      timeout: const Duration(seconds: 60),
    );

    return _handle(response, 'POST(multipart) $url');
  }

  // ---------------- PENANGANAN KONEKSI ----------------

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
        'Koneksi ke server terputus. Periksa koneksi dan ukuran file.',
      );
    } on HttpException catch (e) {
      debugPrint('HttpException: ${e.message}');
      throw ApiException('Koneksi ke server terputus');
    }
  }

  // ---------------- PENANGANAN RESPONSE ----------------

  Future<Map<String, dynamic>> _handle(
    http.Response response,
    String label,
  ) async {
    final status = response.statusCode;
    final ok = status >= 200 && status < 300;

    if (!ok) {
      debugPrint('API ERROR [$label] status=$status');
      debugPrint(
        'BODY: ${response.body.length > 800 ? response.body.substring(0, 800) : response.body}',
      );
    }

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

  Map<String, dynamic> _decode(
    http.Response response, {
    required bool strict,
  }) {
    if (response.body.isEmpty) return {};

    try {
      final data = jsonDecode(response.body);
      return data is Map<String, dynamic> ? data : {};
    } on FormatException {
      if (strict) {
        throw ApiException(
          'Response server tidak valid',
          response.statusCode,
        );
      }
      return {};
    }
  }

  String _parseErrors(Map<String, dynamic> body) {
    final source = body['errors'] is Map
        ? body['errors'] as Map
        : body;

    final messages = source.values
        .expand((value) => value is List ? value : [value])
        .map((value) => value.toString())
        .toList();

    return messages.isEmpty ? 'Data tidak valid' : messages.join('\n');
  }
}